@interface UIAlertController (Private)

@property (readonly) UIView * _dimmingView;

- (UIViewController *)contentViewController;
- (UIView *)_foregroundView;

- (void)_dismissAnimated:(BOOL)animated triggeringAction:(UIAlertAction *)action;
- (void)_fireOffActionOnTargetIfValidForAction:(UIAlertAction *)action;

- (id)_alertControllerContainer;
- (UIView *)_alertControllerView;

- (id)cancelAction;

@end
