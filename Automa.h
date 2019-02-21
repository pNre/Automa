#import <Foundation/Foundation.h>

#import <SpringBoard/FBSDisplay.h>
#import <SpringBoard/FBDisplayManager.h>
#import <SpringBoard/FBScene.h>
#import <SpringBoard/FBProcess.h>

#import <SpringBoard/SBSceneManager.h>
#import <SpringBoard/SBSceneManagerController.h>

#import <UIKit/UIKit.h>

#define kBundle @"co.pNre.automa"
#define kCFBundle CFSTR("co.pNre.automa")

#define kBlockedAlerts  @"BlockedAlerts"
#define kAlertsFile     @"/var/mobile/Library/Preferences/co.pNre.automa.alerts.plist"

#import <substrate.h>
#import <Logging.h>

#define ROCKETBOOTSTRAP_LOAD_DYNAMIC
#import <LightMessaging/LightMessaging.h>
#import <libkern/OSAtomic.h>

#import <NAAlert.h>
#import <AutomaUtils.h>

@interface Automa : NSObject

@property (nonatomic, assign) BOOL Shake;
@property (nonatomic, assign) BOOL Tint;
@property (nonatomic, assign) float PressDuration;

@property (nonatomic, assign) BOOL DragToCloseAlerts;

@property (nonatomic, retain) NSBundle * bundle;

+ (instancetype)sharedInstance;

+ (BOOL)canHook;
- (BOOL)canHook;

- (void)saveAlerts;

- (void)loadSettings;

- (NSDictionary *)settingsDictionary;

- (BOOL)hasAlert:(NAAlert *)alert;
- (void)addAlert:(NAAlert *)alert;

- (NAAlert *)alertWithAlertController:(UIAlertController *)alertController;

@end

static inline NSString * LocalizedString(NSString * key, NSString * value) {
    NSString * language = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
    NSString * path = [Automa.sharedInstance.bundle pathForResource:language ofType:@"lproj"];
    NSString * string = [[NSBundle bundleWithPath:path] localizedStringForKey:key value:value table:nil];
    return string ?: value;
}
