#import "AutomaHeader.h"

@implementation AutomaHeader

- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AutomaHeader" specifier:specifier];

    if (self) {

        CGRect frame = [self.contentView frame];
        frame.size.height *= 0.8;

        _titleLabel = [[UILabel alloc] initWithFrame:frame];
//        _iconView = [[UIImageView alloc] initWithFrame:frame];

        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
/*
        _iconView.contentMode = UIViewContentModeCenter;
        _iconView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
*/
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setText:@"Automa"];
        [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:30]];
        [_titleLabel setNumberOfLines:0];

        [self.contentView addSubview:_titleLabel];
/*
        NSBundle * Automa.sharedInstance.bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AutomaPrefs.bundle"];
        _iconView.image = [UIImage imageWithContentsOfFile:[Automa.sharedInstance.bundle pathForResource:@"Automa60" ofType:@"png"]];
        [self.contentView addSubview:_iconView];
*/

        [_titleLabel release];
        //[_iconView release];
    }

    return self;
}

- (float)preferredHeightForWidth:(float)arg1
{
    return 80.f;
}

@end
