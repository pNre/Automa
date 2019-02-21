@interface BBDataProviderManager : NSObject

- (void)loadAllDataProviders;
- (id)_configureDataProvider:(id)arg1;

- (id)dataProviderForSectionID:(NSString *)sectionID;

@end
