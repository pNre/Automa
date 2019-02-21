#import <UIKit/UIKit.h>

#import <SpringBoard/SBAlertItemsController.h>

@interface SBAlertItem : NSObject

+ (SBAlertItemsController *)_alertItemsController;

- (void)dismiss;
- (void)dismiss:(NSInteger)reason;

- (void)buttonDismissed;

- (UIAlertView *)alertSheet;
- (UIAlertController *)alertController;

- (id)prepareNewAlertSheetWithLockedState:(BOOL)lockedState requirePasscodeForActions:(BOOL)requirePasscode;

@end
