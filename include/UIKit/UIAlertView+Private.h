@interface UIAlertView (PrivateN)

- (UIAlertController *)_alertController;

- (BOOL)_currentlyRunningModal;

- (void)dismissForTappedIndex:(NSInteger)index;

@end
