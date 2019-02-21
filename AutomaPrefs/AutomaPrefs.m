#import <Preferences/Preferences.h>
#import "AutomaPrefs.h"

@implementation AutomaPrefsListController

- (id)specifiers {

	if (_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"Automa" target:self] retain];

	return _specifiers;
}

@end
