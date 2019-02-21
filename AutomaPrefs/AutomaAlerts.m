#import <Preferences/Preferences.h>
#import <AppList/AppList.h>

#import <Automa.h>

#import "AutomaAlerts.h"
#import "AutomaAlertsTableViewManager.h"

@implementation AutomaAlertsSettingsListController {
	UITableView * _tableView;
    AutomaAlertsTableViewManager * _tableViewManager;
}

- (void)editMode:(id)sender {
    _tableView.editing = !_tableView.editing;

    UIBarButtonItem * barButton;

    if (!_tableView.editing) {
        barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editMode:)];
        [_tableViewManager save];
    } else {
        barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(editMode:)];
    }

	[_tableView reloadData];
    [[self navigationItem] setRightBarButtonItem:barButton];
    [barButton release];
}

- (id)initForContentSize:(CGSize)size
{
    self = [super init];

	if (self) {
		CGRect frame;
		frame.origin = CGPointZero;
		frame.size = size;
		_tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
		_tableViewManager = [[AutomaAlertsTableViewManager alloc] init];
		[_tableView setDataSource:_tableViewManager];
	    [_tableView setDelegate:_tableViewManager];
		[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

        UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editMode:)];
        [[self navigationItem] setRightBarButtonItem:editButton];
        [editButton release];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconLoadedFromNotification:) name:ALIconLoadedNotification object:nil];
	}

	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_tableViewManager release];

	[_tableView setDelegate:nil];
	[_tableView setDataSource:nil];
	[_tableView release];

	[super dealloc];
}

- (void)iconLoadedFromNotification:(NSNotification *)notification
{
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:_tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (UIView *)view
{
	UIView * result = [super view];
	if (!_tableView.superview) {
		_tableView.frame = result.bounds;
		[_tableView setScrollsToTop:YES];
		[result addSubview:_tableView];
		if ([result respondsToSelector:@selector(setScrollsToTop:)]) {
			[(UIScrollView *)result setScrollsToTop:NO];
		}
		if ([result respondsToSelector:@selector(setScrollEnabled:)]) {
			[(UIScrollView *)result setScrollEnabled:NO];
		}
		UIViewController * vc = (UIViewController *)self;
		if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
			[vc setAutomaticallyAdjustsScrollViewInsets:NO];
		}

	}
	return result;
}

static UIEdgeInsets EdgeInsetsForViewController(UIViewController *vc)
{
	UIEdgeInsets result;
	if ([vc respondsToSelector:@selector(topLayoutGuide)]) {
		result.top = vc.topLayoutGuide.length;
		result.bottom = vc.bottomLayoutGuide.length;
	} else {
		result.top = 0.0f;
		result.bottom = 0.0f;
	}
	result.left = 0.0f;
	result.right = 0.0f;
	return result;
}

- (void)viewDidLayoutSubviews
{
	UIEdgeInsets insets = EdgeInsetsForViewController((UIViewController *)self);
	_tableView.contentInset = insets;
	_tableView.scrollIndicatorInsets = insets;
}

- (CGSize)contentSize
{
	return [_tableView frame].size;
}

@end
