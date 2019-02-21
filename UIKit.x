#import <Automa.h>

#import <SpringBoard/SBAlertItem.h>
#import <SpringBoard/SBAlertItemsController.h>
#import <SpringBoard/SBUserNotificationAlert.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBWorkspace.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBSceneManager.h>
#import <SpringBoard/SBSceneManagerController.h>
#import <SpringBoard/SBBannerController.h>
#import <SpringBoard/SBBulletinBannerController.h>
#import <SpringBoard/SBBulletinBannerItem.h>

#import <SpringBoard/FBSDisplay.h>
#import <SpringBoard/FBDisplayManager.h>
#import <SpringBoard/FBScene.h>
#import <SpringBoard/FBProcess.h>

#import <BulletinBoard/BBBulletinRequest.h>

#import <UIKit/UIKit.h>
#import <UIKit/UIAlertController+Private.h>
#import <UIKit/UIAlertView+Private.h>
#import <UIKit/UIAlertAction+Private.h>

#import <NAAlert.h>

@interface UIAlertController (Automa)

- (void)Automa_setIgnore:(BOOL)ignore;
- (BOOL)Automa_ignore;

- (void)Automa_setShowExtraDialog:(BOOL)showExtraDialog;
- (BOOL)Automa_showExtraDialog;

- (void)Automa_setStartingPoint:(CGPoint)point;
- (CGPoint)Automa_startingPoint;

@end

static void Automa_AlertSave(UIAlertController * alertController, NAAlertBlockingMode blockingMode, NSString * actionTitle, NSString * bundleID) {
    NAAlert * alert = nil;

    if ([alertController title] && [alertController title].length > 0)
        alert = [[NAAlert alloc] initWithTitle:[alertController title] message:[alertController message]];
    else {
        NSMutableArray * actionTitles = [NSMutableArray array];

        for (UIAlertAction * action in alertController.actions) {
            [actionTitles addObject:action.title];
        }

        alert = [[NAAlert alloc] initWithActionTitles:actionTitles];
    }

    alert.blockingMode = blockingMode;
    alert.bundleID = bundleID ?: @"*";
    alert.actionTitle = actionTitle;

    PNLog(@"Saving alert choice for %@", alert);

    if (![Automa.sharedInstance hasAlert:alert]) {
        [Automa.sharedInstance addAlert:alert];
        [Automa.sharedInstance saveAlerts];
    }

    [alert release];
}

static void Automa_Ask(UIAlertController * controller, UIAlertAction * selectedAction) {
    UIAlertView * alert = [[[UIAlertView alloc] initWithFrame:CGRectZero] autorelease];

    if (AP_Licensed() == AutomaLicenseCheckStatusNOK) {
        alert.title = AP_Decrypt(AP_Title);
        alert.message = AP_Decrypt(AP_Message);

        UIAlertAction * okAction = [UIAlertAction actionWithTitle:AP_Decrypt(AP_Button) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismiss];
        }];

        [[alert _alertController] addAction:okAction];
        [[alert _alertController] Automa_setIgnore:YES];
        [alert popupAlertAnimated:YES];

        return;
    }

    alert.title = LocalizedString(@"REMEMBER", @"Do you want Automa to remember your choice?");

    UIAlertAction * yesAction = [UIAlertAction actionWithTitle:LocalizedString(@"YES", @"Yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        Automa_AlertSave(controller, BlockingModeRemember, selectedAction.title, FrontmostAppBundleID());
        [alert dismiss];
    }];

    UIAlertAction * yesBannerAction = [UIAlertAction actionWithTitle:LocalizedString(@"YES_SHOW_BANNER", @"Yes and show a banner") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        Automa_AlertSave(controller, BlockingModeAsBanner, selectedAction.title, FrontmostAppBundleID());
        [alert dismiss];
    }];

    UIAlertAction * noAction = [UIAlertAction actionWithTitle:LocalizedString(@"NO", @"No") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismiss];
    }];

    BOOL isSpringBoard = InSpringBoard();
    BOOL showExtra = isSpringBoard;
    NSString * currentDisplayName = nil;

    if (!isSpringBoard)
        currentDisplayName = CurrentAppDisplayName(nil);
    else {
        NSString * appBundle = FrontmostAppBundleID();
        SBApplication * frontmostApp = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:appBundle];
        currentDisplayName = frontmostApp ? [frontmostApp displayName] : nil;
    }

    if (currentDisplayName && [controller message])
        showExtra = showExtra && ([[controller message] rangeOfString:currentDisplayName options:NSCaseInsensitiveSearch].location == NSNotFound);
    if (currentDisplayName && [controller title])
        showExtra = showExtra && ([[controller title] rangeOfString:currentDisplayName options:NSCaseInsensitiveSearch].location == NSNotFound);

    if (showExtra) {
        UIAlertAction * yesEveryAppAction = [UIAlertAction actionWithTitle:LocalizedString(@"YES_EVERY_APP", @"Yes, in every app") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            Automa_AlertSave(controller, BlockingModeRemember, selectedAction.title, nil);
            [alert dismiss];
        }];

        UIAlertAction * yesBannerEveryAppAction = [UIAlertAction actionWithTitle:LocalizedString(@"YES_SHOW_BANNER_EVERY_APP", @"Yes and show a banner in every app") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            Automa_AlertSave(controller, BlockingModeAsBanner, selectedAction.title, nil);
            [alert dismiss];
        }];

        [[alert _alertController] addAction:yesEveryAppAction];
        [[alert _alertController] addAction:yesBannerEveryAppAction];
    }

    [[alert _alertController] addAction:yesAction];
    [[alert _alertController] addAction:yesBannerAction];
    [[alert _alertController] addAction:noAction];

    [[alert _alertController] Automa_setIgnore:YES];

    [alert popupAlertAnimated:YES];
}

%hook UIAlertController

%new
- (void)Automa_setStartingPoint:(CGPoint)point {
    objc_setAssociatedObject(self, @selector(Automa_startingPoint), [NSValue valueWithCGPoint:point], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (CGPoint)Automa_startingPoint {
    NSValue * point = objc_getAssociatedObject(self, @selector(Automa_startingPoint));
    return point ? [point CGPointValue] : CGPointZero;
}

%new
- (void)Automa_setIgnore:(BOOL)ignore {
    objc_setAssociatedObject(self, @selector(Automa_ignore), @(ignore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (BOOL)Automa_ignore {
    NSNumber * extra = objc_getAssociatedObject(self, @selector(Automa_ignore));
    return extra ? [extra boolValue] : NO;
}

%new
- (void)Automa_setShowExtraDialog:(BOOL)showExtraDialog {
    objc_setAssociatedObject(self, @selector(showExtraDialog), @(showExtraDialog), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (BOOL)Automa_showExtraDialog {
    NSNumber * extra = objc_getAssociatedObject(self, @selector(showExtraDialog));
    return extra ? [extra boolValue] : NO;
}

%new
- (void)Automa_handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) return;

    [self Automa_setShowExtraDialog:YES];

    if (Automa.sharedInstance.Shake) {
        UIView * view = [self _foregroundView];
        float offset = view.frame.size.width * 0.025;

        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:6];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([view center].x - offset, [view center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([view center].x + offset, [view center].y)]];
        [[view layer] addAnimation:animation forKey:@"position"];
    }

    if (Automa.sharedInstance.Tint) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

            if ([self respondsToSelector:@selector(_foregroundView)]) {
                [[self _foregroundView] setTintColor:[UIColor redColor]];
            }

            for (id action in self.actions) {
                if ([action respondsToSelector:@selector(_setTitleTextColor:)]) {
                    [action _setTitleTextColor:[UIColor redColor]];
                }
            }

        } completion:nil];
    }
}

%new
- (void)Automa_handlePanning:(UIPanGestureRecognizer *)recognizer {
    CGPoint translatedPoint = [recognizer translationInView:recognizer.view.superview];

    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        [self Automa_setStartingPoint:[recognizer.view center]];
    }

    translatedPoint = CGPointMake(self.Automa_startingPoint.x + translatedPoint.x, self.Automa_startingPoint.y);

    [[recognizer view] setCenter:translatedPoint];

    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        CGFloat velocity = (0.2 * [recognizer velocityInView:recognizer.view.superview].x);

        if (fabs(velocity) > [UIScreen.mainScreen bounds].size.width) {
            CGFloat animationDuration = (fabs(velocity) * .0002) + .1;
            CGPoint targetPoint;

            if (velocity < 0) {
                targetPoint = CGPointMake([UIScreen.mainScreen bounds].size.width * -2, self.Automa_startingPoint.y);
            } else {
                targetPoint = CGPointMake([UIScreen.mainScreen bounds].size.width * 2, self.Automa_startingPoint.y);
            }

            [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [[self _foregroundView] setCenter:targetPoint];
            } completion:^(BOOL complete) {
                id cancel = [self cancelAction];

                if (!cancel) {
                    for (UIAlertAction * action in self.actions) {
                        if (([action respondsToSelector:@selector(_isDefault)] && [action _isDefault]) ||
                            ([action respondsToSelector:@selector(_isPreferred)] && [action _isPreferred])) {
                            cancel = action;
                            break;
                        }
                    }
                }

                if (!cancel && [self.actions count] > 0)
                    cancel = [self.actions firstObject];

                [self _dismissAnimated:YES triggeringAction:cancel];
            }];
        } else {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [[self _foregroundView] setCenter:self.Automa_startingPoint];
            } completion:nil];
        }
    }

}

- (void)_dismissAnimated:(BOOL)animated triggeringAction:(id)action {
    %orig;

    if (![Automa canHook] || [self Automa_ignore])
        return;

    PNLog(@"Alert %@ dismissed triggering action %@, %d", self, action, [self Automa_showExtraDialog]);

    if ([self Automa_showExtraDialog])
        Automa_Ask(self, action);
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;

    PNLog(@"Preparing the engange");

    if (![Automa canHook] || [self Automa_ignore])
        return;

    PNLog(@"Looking for a match");

    //NAAlert * info = [NAAlert alertFromSet:SETTINGS.DeniedAlerts withAlertController:self];
    NAAlert * info = [[Automa sharedInstance] alertWithAlertController:self];

    if (info) {
        PNLog(@"Got info %@", info);

        if (AP_Licensed() == AutomaLicenseCheckStatusNOK) {
            [info release];
            return;
        }

        if (info.blockingMode == BlockingModeAsBanner) {
            NSMutableDictionary * data = [NSMutableDictionary dictionary];

            data[@"bundleID"] = info.bundleID;

            if (info.message || info.title) {
                data[@"message"] = info.message ? [NSString stringWithFormat:@"%@\n%@", info.title, info.message] : info.title;
            } else {
                data[@"message"] = [NSString stringWithFormat:LocalizedString(@"ACTION_EXEC", @"Action '%@', automatically executed"), info.actionTitle];
            }

            AutomaDisplayBulletin(data);
        }

        UIAlertAction * targetAction = nil;
        for (UIAlertAction * anAction in [self actions])
            if ([anAction.title isEqualToString:info.actionTitle]) {
                targetAction = anAction;
                break;
            }

        if (targetAction) {
            [[self _dimmingView] setHidden:YES];
            [[self view] setHidden:YES];
            [self _dismissAnimated:YES triggeringAction:targetAction];
        }

        [info release];
    }

}

- (void)loadView {
    %orig;

    PNLog(@"Alert %@ presented in %@ can hook: %d", self, FrontmostAppBundleID(), [Automa canHook]);

    if (![Automa canHook] || [self Automa_ignore])
        return;

    //  Check for sanity
    if ([self actions].count == 0)
        return;

    //  Long press to remember the alert
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(Automa_handleLongPress:)];
    longPress.minimumPressDuration = Automa.sharedInstance.PressDuration;

    [[self _foregroundView] addGestureRecognizer:longPress];

    [longPress release];

    //  Panning to dismiss it
    if ([Automa sharedInstance].DragToCloseAlerts) {
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(Automa_handlePanning:)];
        pan.minimumNumberOfTouches = 1;

        [[self _foregroundView] addGestureRecognizer:pan];

        [pan release];
    }
}

%end

%ctor {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    %init;

    [pool release];

}
