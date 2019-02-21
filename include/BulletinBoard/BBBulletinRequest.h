#import <BulletinBoard/BBBulletin.h>

@interface BBBulletinRequest : BBBulletin

@property (nonatomic, copy) NSString * bulletinID;
@property (nonatomic, copy) NSString * sectionID;
@property (nonatomic, copy) NSSet * subsectionIDs;
@property (nonatomic, copy) NSString * recordID;
@property (nonatomic, copy) NSString * publisherBulletinID;
@property (nonatomic, copy) NSString * dismissalID;
@property (assign, nonatomic) long long addressBookRecordID;
@property (assign, nonatomic) long long sectionSubtype;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, copy) NSString * message;
@property (assign, nonatomic) BOOL hasEventDate;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * recencyDate;
@property (assign, nonatomic) long long dateFormatStyle;
@property (assign, nonatomic) BOOL dateIsAllDay;
@property (nonatomic, retain) NSTimeZone * timeZone;
@property (assign, nonatomic) BOOL clearable;
@property (assign, nonatomic) long long primaryAttachmentType;
@property (assign, nonatomic) BOOL wantsFullscreenPresentation;
@property (nonatomic, copy) NSSet * alertSuppressionContexts;
@property (nonatomic, copy) NSArray * supplementaryActions;
@property (nonatomic, retain) NSDate * expirationDate;
@property (assign, nonatomic) unsigned long long expirationEvents;
@property (assign, nonatomic) BOOL usesExternalSync;
@property (nonatomic, copy) NSArray * buttons;
@property (assign, nonatomic) BOOL expiresOnPublisherDeath;
@property (nonatomic, copy) NSString * section;
@property (assign, nonatomic) unsigned long long realertCount;
@property (assign, nonatomic) BOOL showsUnreadIndicator;
@property (assign, nonatomic) BOOL tentative;

- (BOOL)hasContentModificationsRelativeTo:(id)arg1 ;
- (id)publisherMatchID;
- (void)generateNewBulletinID;
- (BOOL)tentative;
- (void)setTentative:(BOOL)arg1 ;
- (void)publish;
- (unsigned long long)expirationEvents;
- (void)setExpirationEvents:(unsigned long long)arg1 ;
- (void)addAttachmentOfType:(long long)arg1 ;
- (void)publish:(BOOL)arg1 ;
- (void)setSupplementaryActions:(id)arg1 forLayout:(long long)arg2 ;
- (void)_updateSupplementaryAction:(id)arg1 ;
- (void)setContextValue:(id)arg1 forKey:(id)arg2 ;
- (void)setPrimaryAttachmentType:(long long)arg1 ;
- (void)addButton:(id)arg1 ;
- (void)withdraw;
- (void)setSupplementaryActions:(NSArray *)arg1 ;
- (void)setUnlockActionLabel:(id)arg1 ;
- (unsigned long long)realertCount;
- (void)setRealertCount:(unsigned long long)arg1 ;
- (void)addAlertSuppressionAppID:(id)arg1 ;
- (void)generateBulletinID;
- (void)setShowsUnreadIndicator:(BOOL)arg1 ;
- (BOOL)showsUnreadIndicator;

@end
