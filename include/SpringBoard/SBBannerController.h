@interface SBBannerController : NSObject

+ (instancetype)sharedInstance;
- (void)_presentBannerForContext:(id)context reason:(long long)reason;
- (id)_newBannerViewForContext:(id)context;
- (id)_newBannerContextViewController;
- (id)_bannerContext;
- (id)currentBannerContextForSource:(id)arg1;

@end
