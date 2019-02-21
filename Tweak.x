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

static LMConnection connection = {
    MACH_PORT_NULL,
    "automa.service"
};

static void ReloadSettingsNotification(CFNotificationCenterRef notificationCenterRef, void * arg1, CFStringRef arg2, const void * arg3, CFDictionaryRef dictionary)
{
    [Automa.sharedInstance loadSettings];
}

NSDictionary * AutomaSpringBoardClientReadPreferences() {
    LMResponseBuffer buffer;
    if (LMConnectionSendTwoWay(&connection, AutomaSpringBoardServerMessagePreferences, NULL, 0, &buffer))
        return nil;
    id result = LMResponseConsumePropertyList(&buffer);
    return [result isKindOfClass:[NSDictionary class]] ? result : nil;
}

void AutomaSpringBoardClientSendMessage(enum AutomaSpringBoardServerMessageTypes type, NSDictionary * params) {
    if (!LMConnectionSendOneWayData(&connection, type, params ? (CFDataRef)[NSPropertyListSerialization dataFromPropertyList:params format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL] : NULL))
        PNLog(@"Error sending notification data");
}

enum AutomaLicenseCheckStatus AutomaSpringBoardClientReadLicense() {
    LMResponseBuffer buffer;
    if (LMConnectionSendTwoWay(&connection, AutomaSpringBoardServerMessageLicense, NULL, 0, &buffer))
        return AutomaLicenseCheckStatusWAIT;
    int32_t result = LMResponseConsumeInteger(&buffer);
    return (enum AutomaLicenseCheckStatus)result;
}

void AutomaDisplayBulletin(NSDictionary * params) {

    if (!%c(SBApplicationController)) {
        AutomaSpringBoardClientSendMessage(AutomaSpringBoardServerMessageNotification, params);
        return;
    }

    BBBulletinRequest * bulletin = [[%c(BBBulletinRequest) alloc] init];
    bulletin.message = params[@"message"];
    bulletin.date = [NSDate date];
    bulletin.lastInterruptDate = [NSDate date];
    bulletin.clearable = NO;

    if ([params[@"bundleID"] isEqualToString:@"*"] ||
        [params[@"bundleID"] caseInsensitiveCompare:@"com.apple.springboard"] == NSOrderedSame) {
        bulletin.title = @"Automa";
        bulletin.sectionID = kBundle;
        bulletin.bulletinID = kBundle;
        bulletin.publisherBulletinID = kBundle;
        bulletin.recordID = kBundle;
    } else {
        SBApplication * app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:params[@"bundleID"]];
        bulletin.title = params[@"title"] ?: [app displayName];
        bulletin.sectionID = params[@"bundleID"];
        bulletin.bulletinID = params[@"bundleID"];
        bulletin.publisherBulletinID = params[@"bundleID"];
        bulletin.recordID = params[@"bundleID"];
    }

    SBBulletinBannerController * bulletinBannerController = [%c(SBBulletinBannerController) sharedInstance];

    if (bulletinBannerController)
        [bulletinBannerController _queueBulletin:bulletin];

}

static void AutomaSpringBoardServerHandleMessage(SInt32 messageId, mach_port_t replyPort, CFDataRef data)
{
    NSDictionary * params = nil;

    switch (messageId) {
        case AutomaSpringBoardServerMessageNotification:
            if (!data)
                break;

            params = [NSPropertyListSerialization propertyListFromData:(NSData *)data mutabilityOption:0 format:NULL errorDescription:NULL];
            if (![params isKindOfClass:[NSDictionary class]])
                break;

            PNLog(@"Notification %@", params);

            AutomaDisplayBulletin(params);
        break;
        case AutomaSpringBoardServerMessagePreferences:
            PNLog(@"SpringBoard server is sending %@", [Automa.sharedInstance settingsDictionary]);
            OSSpinLockLock(&AutomaSpinLock);
            LMSendPropertyListReply(replyPort, [Automa.sharedInstance settingsDictionary]);
            OSSpinLockUnlock(&AutomaSpinLock);
            return;
        break;
        case AutomaSpringBoardServerMessageLicense:
            PNLog(@"Reading license %tu", AP_Licensed());
            LMSendIntegerReply(replyPort, AP_Licensed());
            return;
        break;
    }

    LMSendReply(replyPort, NULL, 0);
}

static void MachPortCallback(CFMachPortRef port, void * bytes, CFIndex size, void * info)
{
    LMMessage * request = (LMMessage *)bytes;
    if (size < sizeof(LMMessage)) {
        LMSendReply(request->head.msgh_remote_port, NULL, 0);
        LMResponseBufferFree((LMResponseBuffer *)bytes);
        return;
    }
    // Send Response
    const void * data = LMMessageGetData(request);
    size_t length = LMMessageGetDataLength(request);
    mach_port_t replyPort = request->head.msgh_remote_port;
    CFDataRef cfdata = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)(data ?: &data), length, kCFAllocatorNull);
    AutomaSpringBoardServerHandleMessage(request->head.msgh_id, replyPort, cfdata);

    if (cfdata)
        CFRelease(cfdata);

    LMResponseBufferFree((LMResponseBuffer *)bytes);
}

%ctor {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettingsNotification, CFSTR("co.pNre.automa/settingsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);

    if (InSpringBoard()) {
        //  Messaging server: start
        kern_return_t err = LMStartService(connection.serverName, CFRunLoopGetCurrent(), MachPortCallback);
        if (err) {
            PNLog(@"Unable to register mach server with error %x", err);
        }
    }

    if ([UIApplication sharedApplication] || InSpringBoard()) {
        PNLog(@"%@, %@", [[NSBundle mainBundle] bundleIdentifier], [UIApplication sharedApplication]);
        [Automa.sharedInstance loadSettings];
        %init;
    }

    [pool release];

}
