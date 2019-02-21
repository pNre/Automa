#import <Automa.h>

#import "NAAlert.h"

@implementation NAAlert

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [super init];

    if (self) {
        self.title = title;
        self.message = message;
    }

    return self;
}

- (id)initWithActionTitles:(NSArray *)actionTitles {
    self = [super init];

    if (self) {
        self.actionTitles = actionTitles;
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@> Title: %@, Message: %@, Bundle: %@, Action title: %@, Action titles: %@, Mode: %@", self.class, _title, _message, _bundleID, _actionTitle, _actionTitles, @(_blockingMode)];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        self.title = dictionary[@"title"] && ((NSString *)dictionary[@"title"]).length > 0 ? dictionary[@"title"] : nil;
        self.message = dictionary[@"message"] && ((NSString *)dictionary[@"message"]).length > 0 ? dictionary[@"message"] : nil;
        self.bundleID = dictionary[@"bundleID"] && ((NSString *)dictionary[@"bundleID"]).length > 0 ? dictionary[@"bundleID"] : @"*";
        self.blockingMode = [dictionary[@"blockingMode"] unsignedIntegerValue];
        self.actionTitle = dictionary[@"actionTitle"];
        self.actionTitles = dictionary[@"actionTitles"] && ((NSArray *)dictionary[@"actionTitles"]).count > 0 ? dictionary[@"actionTitles"] : nil;
    }

    return self;
}

- (BOOL)isEqual:(id)anObject {
    if (!anObject || ![anObject isKindOfClass:[NAAlert class]])
        return NO;

    NAAlert * anAlert = (NAAlert *)anObject;

    if (_title == anAlert.title && _title == nil) {
        return [self.actionTitles isEqualToArray:anAlert.actionTitles];
    } else {
        BOOL messageEqual = (_message ? [_message isEqualToString:anAlert.message] : _message == anAlert.message);
        BOOL titleEqual = [_title isEqualToString:anAlert.title];

        if (!_matchingSpringBoard)
            return titleEqual && messageEqual && [_bundleID isEqualToString:anAlert.bundleID];
        else
            return titleEqual && messageEqual;
    }
}

- (NSUInteger)hash {
    NSUInteger bundleIDHash = _bundleID ? _bundleID.hash : 0;

    if (_title) {
        NSUInteger titleHash = _title.hash;
        NSUInteger messageHash = _message ? _message.hash : 0;

        return titleHash ^ messageHash ^ bundleIDHash;
    } else {
        NSUInteger hash = bundleIDHash;

        for (NSString * title in _actionTitles) {
            hash ^= title.hash;
        }

        return hash;
    }
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"title":           _title ?: @"",
        @"message":         _message ?: @"",
        @"blockingMode":    @(_blockingMode),
        @"bundleID":        _bundleID ?: @"*",
        @"actionTitle":     _actionTitle,
        @"actionTitles":    _actionTitles ?: @[]
    };
}

- (void)dealloc {
    if (_title)
        [_title release];

    if (_message)
        [_message release];

    if (_bundleID)
        [_bundleID release];

    if (_actionTitle)
        [_actionTitle release];

    if (_actionTitles)
        [_actionTitles release];

    [super dealloc];
}

@end
