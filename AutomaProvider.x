#import <AutomaProvider.h>

#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBDataProviderManager.h>
#import <BulletinBoard/BBDataProvider.h>
#import <BulletinBoard/BBServer.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBSectionIcon.h>
#import <BulletinBoard/BBSectionIconVariant.h>

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

#import <Logging.h>
#import <Automa.h>

@implementation AutomaProvider: BBDataProvider

static BBBulletinRequest * _bulletin;

static AutomaProvider * sharedProvider;

+ (AutomaProvider *) sharedProvider{
  return [[sharedProvider retain] autorelease];
}

- (void)dealloc
{
    if (_bulletin)
        [_bulletin release];

    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        sharedProvider = self;
    }
    return self;
}

- (NSString *)sectionIdentifier
{
    return kBundle;
    //return _bulletin.sectionID ?: kBundle;
}

- (NSArray *)sortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
}

- (NSArray *)bulletinsFilteredBy:(unsigned)by count:(unsigned)count lastCleared:(id)cleared
{
    return nil;
}

/*
- (void)bulletinsWithRequestParameters:(id)params lastCleared:(id)cleared completion:(void (^)(id))completion {
    PNLog(@"%@", params);
    completion(nil);
}*/

- (void)startWatchdog {

}

- (NSString *)sectionDisplayName {
    return @"Automa";
    //return _bulletin.title ?: @"Automa";
}

- (BBSectionInfo *)defaultSectionInfo
{
    BBSectionInfo * sectionInfo = [BBSectionInfo defaultSectionInfoForType:0];
    sectionInfo.notificationCenterLimit = 10;
    sectionInfo.sectionID = [self sectionIdentifier];
    sectionInfo.displayName = [self sectionDisplayName];
    return sectionInfo;
}

- (void)setParams:(NSDictionary *)params {

    if (!_bulletin) {
        _bulletin = [[%c(BBBulletinRequest) alloc] init];
    }

    _bulletin.message = params[@"message"];
    _bulletin.date = [NSDate date];
    _bulletin.lastInterruptDate = [NSDate date];
    _bulletin.clearable = NO;

    if ([params[@"bundleID"] isEqualToString:@"*"] ||
        [params[@"bundleID"] caseInsensitiveCompare:@"com.apple.springboard"] == NSOrderedSame) {
        _bulletin.title = @"Automa";
        _bulletin.sectionID = kBundle;
        _bulletin.bulletinID = kBundle;
        _bulletin.publisherBulletinID = kBundle;
        _bulletin.recordID = kBundle;
    } else {
        SBApplication * app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:params[@"bundleID"]];
        _bulletin.title = params[@"title"] ?: [app displayName];
        _bulletin.sectionID = kBundle;
        _bulletin.bulletinID = params[@"bundleID"];
        _bulletin.publisherBulletinID = params[@"bundleID"];
        _bulletin.recordID = kBundle;
    }

    BBDataProviderWithdrawBulletinsWithRecordID(self, kBundle);
    BBDataProviderAddBulletin(self, _bulletin);
}

- (void)dataProviderDidLoad {

}

@end
