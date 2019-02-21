#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NAAlertBlockingMode) {
    BlockingModeRemember,
    BlockingModeAsBanner,

    BlockingModesCount
};

@interface NAAlert : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * message;
@property (nonatomic, assign) NAAlertBlockingMode blockingMode;
@property (nonatomic, copy) NSString * bundleID;
@property (nonatomic, copy) NSString * actionTitle;
@property (nonatomic, copy) NSArray * actionTitles;
@property (nonatomic, assign) BOOL matchingSpringBoard;

//+ (instancetype)alertFromSet:(NSSet *)set withAlertController:(UIAlertController *)alertController;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithActionTitles:(NSArray *)actionTitles;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)anObject;

- (NSDictionary *)dictionaryRepresentation;

@end
