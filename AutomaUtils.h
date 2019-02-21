#import <Foundation/Foundation.h>

#import <SpringBoard/FBSDisplay.h>
#import <SpringBoard/FBDisplayManager.h>
#import <SpringBoard/FBScene.h>
#import <SpringBoard/FBProcess.h>

#import <SpringBoard/SBSceneManager.h>
#import <SpringBoard/SBSceneManagerController.h>

#import <MobileGestalt/MobileGestalt.h>

#import <UIKit/UIKit.h>

#import <substrate.h>
#import <Logging.h>

#import <LRResty/LRResty.h>

#define ROCKETBOOTSTRAP_LOAD_DYNAMIC
#import <LightMessaging/LightMessaging.h>
#import <libkern/OSAtomic.h>

#import <NAAlert.h>

enum AutomaSpringBoardServerMessageTypes {
    AutomaSpringBoardServerMessageNotification = 0,
    AutomaSpringBoardServerMessagePreferences,
    AutomaSpringBoardServerMessageLicense
};

enum AutomaLicenseCheckStatus {
    AutomaLicenseCheckStatusDidNotCheck,
    AutomaLicenseCheckStatusOK,
    AutomaLicenseCheckStatusNOK,
    AutomaLicenseCheckStatusWAIT
};

extern OSSpinLock AutomaSpinLock;
void AutomaSaveAlerts();

NSDictionary * AutomaSpringBoardClientReadPreferences();
void AutomaDisplayBulletin(NSDictionary * params);
enum AutomaLicenseCheckStatus AutomaSpringBoardClientReadLicense();

static inline NSString * FrontmostAppBundleID() {

    if (!NSClassFromString(@"SBSceneManagerController") || !NSClassFromString(@"FBDisplayManager")) {
        return [UIApplication sharedApplication] ? [[NSBundle mainBundle] bundleIdentifier] : nil;
    }

    SBSceneManager * sceneManager = [[NSClassFromString(@"SBSceneManagerController") sharedInstance] sceneManagerForDisplay:[NSClassFromString(@"FBDisplayManager") mainDisplay]];
    NSSet * scenes = [sceneManager externalForegroundApplicationScenes];
    FBScene * topScene = [scenes anyObject];
    return [[topScene clientProcess] bundleIdentifier] ?: ([UIApplication sharedApplication] ? [[NSBundle mainBundle] bundleIdentifier] : nil);

}

static inline NSString * CurrentAppDisplayName(NSBundle * appBundle) {
    appBundle = appBundle ?: [NSBundle mainBundle];
    return [[appBundle localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
}

static inline BOOL InSpringBoard() {
    NSString * currentApplication = [[NSBundle mainBundle] bundleIdentifier];

    if (!currentApplication)
        return NO;

    return ([currentApplication caseInsensitiveCompare:@"com.apple.springboard"] == NSOrderedSame);
}
