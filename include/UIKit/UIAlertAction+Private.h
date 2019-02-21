@interface UIAlertAction (Private)

@property (setter=_setIsDefault:) BOOL _isDefault;
@property (setter=_setIsPreferred:) BOOL _isPreferred;

- (BOOL)_isChecked;

- (void)_setTitleTextColor:(id)color;

@end
