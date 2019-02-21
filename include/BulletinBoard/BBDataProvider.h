#import <BulletinBoard/BBBulletin.h>

void BBDataProviderAddBulletin(id dataProvider, BBBulletin *bulletin);
void BBDataProviderInvalidateBulletins(id dataProvider, NSArray *bulletins);
void BBDataProviderWithdrawBulletinsWithRecordID(id dataProvider, NSString *recordID);

@interface BBDataProvider : NSObject
- (id)sortKey;
- (void)dealloc;
- (id)init;
- (NSString *)description;
- (NSString *)debugDescription;
- (void)invalidate;
- (id)sortDescriptors;
- (id)sectionIdentifier;
- (void)dataProviderDidLoad;
- (void)bulletinsWithRequestParameters:(id)arg1 lastCleared:(id)arg2 completion:(void (^)(id))arg3 ;
- (void)clearedInfoAndBulletinsForClearingAllBulletinsWithLimit:(id)arg1 lastClearedInfo:(id)arg2 completion:(/*^block*/id)arg3 ;
- (void)clearedInfoForBulletins:(id)arg1 lastClearedInfo:(id)arg2 completion:(/*^block*/id)arg3 ;
- (void)attachmentPNGDataForRecordID:(id)arg1 sizeConstraints:(id)arg2 completion:(/*^block*/id)arg3 ;
- (void)attachmentAspectRatioForRecordID:(id)arg1 completion:(/*^block*/id)arg2 ;
- (void)noteSectionInfoDidChange:(id)arg1 ;
- (void)deliverMessageWithName:(id)arg1 userInfo:(id)arg2 ;
- (id)debugDescriptionWithChildren:(unsigned long long)arg1 ;
- (id)universalSectionIdentifier;
- (BOOL)syncsBulletinDismissal;
- (BOOL)canClearAllBulletins;
- (id)sectionParameters;
- (id)parentSectionIdentifier;
- (void)updateClearedInfoWithClearedInfo:(id)arg1 handler:(/*^block*/id)arg2 completion:(/*^block*/id)arg3 ;
- (void)updateSectionInfoWithSectionInfo:(id)arg1 handler:(/*^block*/id)arg2 completion:(/*^block*/id)arg3 ;
- (id)defaultSectionInfo;
- (id)sectionDisplayName;
- (id)sectionIcon;
- (void)deliverResponse:(id)arg1 forBulletinRequest:(id)arg2 ;
- (BOOL)isPushDataProvider;
- (id)defaultSubsectionInfos;
- (id)displayNameForSubsectionID:(id)arg1 ;
- (BOOL)migrateSectionInfo:(id)arg1 oldSectionInfo:(id)arg2 ;
- (BOOL)initialized;
- (void)startWatchdog;
- (void)reloadIdentityWithCompletion:(/*^block*/id)arg1 ;
- (BOOL)canPerformMigration;
@end
