@interface BBSectionIconVariant : NSObject

@property (assign,nonatomic) long long format;                                   //@synthesize format=_format - In the implementation block
@property (nonatomic,copy) NSData * imageData;                                   //@synthesize imageData=_imageData - In the implementation block
@property (nonatomic,copy) NSString * imagePath;                                 //@synthesize imagePath=_imagePath - In the implementation block
@property (nonatomic,copy) NSString * imageName;                                 //@synthesize imageName=_imageName - In the implementation block
@property (nonatomic,copy) NSString * bundlePath;                                //@synthesize bundlePath=_bundlePath - In the implementation block
@property (assign,getter=isPrecomposed, nonatomic) BOOL precomposed;              //@synthesize precomposed=_precomposed - In the implementation block

+ (id)_variantWithFormat:(long long)arg1;
+ (id)variantWithFormat:(long long)arg1 imageData:(id)arg2;
+ (id)variantWithFormat:(long long)arg1 imagePath:(id)arg2;
+ (id)variantWithFormat:(long long)arg1 imageName:(id)arg2 inBundle:(id)arg3;

@end
