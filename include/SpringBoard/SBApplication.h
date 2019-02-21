@interface SBApplication : NSObject

- (NSString *)bundleIdentifier;
- (NSString *)displayName;

- (BOOL)statusBarHidden;
- (BOOL)statusBarHiddenForCurrentOrientation;

- (void)_fireNotification:(id)notification;

- (id)initWithApplicationInfo:(id)arg1 bundle:(NSBundle *)bundle infoDictionary:(NSDictionary *)info;

@end
