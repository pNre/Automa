#import <Foundation/Foundation.h>
#import <BulletinBoard/BBDataProvider.h>

@interface AutomaProvider : BBDataProvider

+ (AutomaProvider *)sharedProvider;

- (void)setParams:(NSDictionary *)params;

@end
