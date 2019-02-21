#import <Preferences/Preferences.h>

@interface PSTableCell (Settings)

- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
- (UIView *)contentView;

@end

@interface AutomaHeader : PSTableCell {
    UILabel * _titleLabel;
    UIImageView * _iconView;
}
@end
