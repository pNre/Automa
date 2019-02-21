#import <substrate.h>

#import <CoreFoundation/CoreFoundation.h>

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
#import <BulletinBoard/BBDataProviderManager.h>
#import <BulletinBoard/BBDataProvider.h>
#import <BulletinBoard/BBServer.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>

#import <UIKit/UIKit.h>
#import <UIKit/UIAlertController+Private.h>
#import <UIKit/UIAlertView+Private.h>

#import <NAAlert.h>
#import <Automa.h>
#import <AutomaProvider.h>

%group SpringBoard

%hook SBBulletinBannerItem

- (id)iconImage {
    if ([[[self seedBulletin] sectionID] isEqualToString:kBundle] && [[self title] isEqualToString:@"Automa"]) {
        return [UIImage imageWithContentsOfFile:[Automa.sharedInstance.bundle pathForResource:@"Automa" ofType:@"png"]];
    }

    return %orig;
}

%end

/*
%hook BBDataProviderManager

- (void)loadAllDataProviders
{
    %orig;

    PNLog(@"Data providers");

    BBLocalDataProviderStore * _localDataProviderStore = MSHookIvar<BBLocalDataProviderStore *>(self, "_localDataProviderStore");

    AutomaProvider * provider = [[AutomaProvider alloc] init];
    [_localDataProviderStore addDataProvider:provider];
    [provider release];
}

%end
*/

%end

%ctor {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    if (InSpringBoard()) {
        %init(SpringBoard);
    }

    [pool release];

}
