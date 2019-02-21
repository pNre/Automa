#import <Automa.h>

OSSpinLock AutomaSpinLock;

@implementation Automa {
    BOOL _GloballyEnabled;
    NSMutableArray * _blacklistedApps;
    NSMutableSet * _alerts;
}

+ (id)sharedInstance
{
    static dispatch_once_t token = 0;
    __strong static id _sharedObject = nil;

    dispatch_once(&token, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

- (id)init {
    if ((self = [super init])) {
        _GloballyEnabled    = YES;
        _Shake              = YES;
        _Tint               = YES;
        _PressDuration      = 1.f;
        _DragToCloseAlerts  = YES;
        _alerts             = [[NSMutableSet alloc] init];
        _blacklistedApps    = [[NSMutableArray alloc] init];

        _bundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/AutomaPrefs.bundle"] retain];

        [self loadSettings];
    }

    return self;
}

- (void)dealloc {
    if (_bundle)
        [_bundle release];

    if (_alerts)
        [_alerts release];

    [super dealloc];
}

+ (BOOL)canHook {
    return [[Automa sharedInstance] canHook];
}

- (BOOL)canHook {

    NSString * currentApplication = [[NSBundle mainBundle] bundleIdentifier];

    if ([currentApplication caseInsensitiveCompare:@"com.apple.springboard"] == NSOrderedSame)
        currentApplication = FrontmostAppBundleID();

    if (!currentApplication)
        return _GloballyEnabled;

    PNLog(@"%d, %@", _GloballyEnabled && ![_blacklistedApps containsObject:[currentApplication lowercaseString]], currentApplication);

    return _GloballyEnabled && ![_blacklistedApps containsObject:[currentApplication lowercaseString]];

}

- (void)loadSettings {

    PNLog(@"Loading settings");

    OSSpinLockLock(&AutomaSpinLock);

    [_blacklistedApps removeAllObjects];
    [_alerts removeAllObjects];

    if (!InSpringBoard()) {

        NSDictionary * preferences = AutomaSpringBoardClientReadPreferences();

        [_blacklistedApps addObjectsFromArray:preferences[@"BlacklistedApps"]];

        _GloballyEnabled    = [preferences[@"GloballyEnabled"] boolValue];
        _Shake              = [preferences[@"Shake"] boolValue];
        _PressDuration      = [preferences[@"PressDuration"] floatValue];
        _Tint               = [preferences[@"Tint"] boolValue];
        _DragToCloseAlerts  = [preferences[@"DragToCloseAlerts"] floatValue];

    } else {
        Boolean found = false;

        Boolean value = CFPreferencesGetAppBooleanValue(CFSTR("GloballyEnabled"), kCFBundle, &found);
        _GloballyEnabled = found ? value : YES;

        value = CFPreferencesGetAppBooleanValue(CFSTR("Shake"), kCFBundle, &found);
        _Shake = found ? value : YES;

        value = CFPreferencesGetAppBooleanValue(CFSTR("Tint"), kCFBundle, &found);
        _Tint = found ? value : YES;

        value = CFPreferencesGetAppBooleanValue(CFSTR("DragToCloseAlerts"), kCFBundle, &found);
        _DragToCloseAlerts = found ? value : YES;

        CFPropertyListRef ref = CFPreferencesCopyAppValue(CFSTR("PressDuration"), kCFBundle);
        if (ref)
            _PressDuration = [(NSNumber *)ref floatValue];

        CFArrayRef keyList = CFPreferencesCopyKeyList(kCFBundle, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        if (keyList) {
            for (NSString * key in (NSArray *)keyList) {
                if (![key hasPrefix:@"BlacklistedApps-"])
                    continue;

                if ([key hasPrefix:@"BlacklistedApps-"]) {
                    if ([(NSNumber *)CFPreferencesCopyAppValue((CFStringRef)key, kCFBundle) boolValue]) {
                        [_blacklistedApps addObject:[[key substringFromIndex:[@"BlacklistedApps-" length]] lowercaseString]];
                    }
                }
            }

            CFRelease(keyList);
        }
    }

    OSSpinLockUnlock(&AutomaSpinLock);

    NSDictionary * _alertsDictionary = [NSDictionary dictionaryWithContentsOfFile:kAlertsFile];

    if (_alertsDictionary[kBlockedAlerts]) {
        for (NSDictionary * entry in _alertsDictionary[kBlockedAlerts]) {
            if (!entry[@"title"] && !entry[@"message"])
                continue;

            NAAlert * alert = [[NAAlert alloc] initWithDictionaryRepresentation:entry];
            [self addAlert:alert];
            [alert release];
        }
    }

    PNLog(@"Done loading settings");

}

- (void)saveAlerts {
    NSMutableDictionary * _alertsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:kAlertsFile] ?: [NSMutableDictionary dictionary];
    NSMutableArray * _blockedAlertsArray = [NSMutableArray array];

    OSSpinLockLock(&AutomaSpinLock);
    for (NAAlert * alert in _alerts) {
        [_blockedAlertsArray addObject:[alert dictionaryRepresentation]];
    }
    OSSpinLockUnlock(&AutomaSpinLock);

    _alertsDictionary[kBlockedAlerts] = _blockedAlertsArray;
    [_alertsDictionary writeToFile:kAlertsFile atomically:YES];
}

- (NSDictionary *)settingsDictionary {
    return @{
        @"GloballyEnabled":     @(_GloballyEnabled),
        @"Shake":               @(_Shake),
        @"PressDuration":       @(_PressDuration),
        @"BlacklistedApps":     _blacklistedApps,
        @"Tint":                @(_Tint),
        @"DragToCloseAlerts":   @(_DragToCloseAlerts)
    };
}

- (BOOL)hasAlert:(NAAlert *)alert {
    OSSpinLockLock(&AutomaSpinLock);
    BOOL contains = [_alerts containsObject:alert];
    OSSpinLockUnlock(&AutomaSpinLock);
    return contains;
}

- (void)addAlert:(NAAlert *)alert {
    OSSpinLockLock(&AutomaSpinLock);
    [_alerts addObject:alert];
    OSSpinLockUnlock(&AutomaSpinLock);
}

- (NAAlert *)alertWithAlertController:(UIAlertController *)alertController {
    NAAlert * alert = nil;

    //  If the alertController has a title, it's probably an UIAlertView
    if ([alertController title] && [alertController title].length > 0) {
        alert = [[NAAlert alloc] initWithTitle:[alertController title] message:[alertController message]];

        //  Check if matching a springboard alert
        alert.matchingSpringBoard = %c(SpringBoard) != nil;
        PNLog(@"%d", alert.matchingSpringBoard);
    } else {    //
        //  Map the action to any array of titles
        NSMutableArray * actionTitles = [NSMutableArray array];

        for (UIAlertAction * action in alertController.actions) {
            [actionTitles addObject:action.title];
        }

        //  and alloc and alert
        alert = [[NAAlert alloc] initWithActionTitles:actionTitles];
    }

    //  Try the frontmost app
    alert.bundleID = FrontmostAppBundleID();
    NAAlert * result = [_alerts member:alert];

    //  if it's not found, try matching any app
    if (!result) {
        alert.bundleID = @"*";
        result = [_alerts member:alert];
    }

    [alert release];

    return result ? [result retain] : nil;
}

@end
