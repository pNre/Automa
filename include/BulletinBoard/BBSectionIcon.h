@interface BBSectionIcon : NSObject

@property (nonatomic, copy) NSSet * variants;

+ (BOOL)supportsSecureCoding;
- (void)dealloc;
- (id)initWithCoder:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (id)_bestVariantForFormat:(long long)arg1;
- (id)_bestVariantForUIFormat:(int)arg1;
- (NSSet *)variants;
- (void)setVariants:(NSSet *)arg1;
- (void)addVariant:(id)arg1;

@end
