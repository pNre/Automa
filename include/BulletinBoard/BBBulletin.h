@interface BBBulletin : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, copy) NSString * message;
@property (nonatomic, copy) NSString * sectionID;

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * recencyDate;

@property (nonatomic, retain) NSDate * lastInterruptDate;

@end
