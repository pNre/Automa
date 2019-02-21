#import <BulletinBoard/BBBulletin.h>

@interface SBBulletinBannerItem : NSObject

+ (instancetype)itemWithBulletin:(id)bulletin andObserver:(id)observer;

- (NSString *)title;
- (NSString *)message;

- (BBBulletin *)seedBulletin;

@end
