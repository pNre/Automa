@interface SBBulletinBannerController : NSObject

+ (instancetype)sharedInstance;
- (id)newBannerViewForContext:(id)context;
- (id)_bannerContextForBulletin:(id)bulletin;

- (void)_queueBulletin:(id)bulletin;

@end
