#import <Foundation/Foundation.h>

@interface DollarPoint : NSObject

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float timeStamp;
@property (nonatomic) id id;

+ (DollarPoint *)origin;

- (id)initWithId:(id)id x:(float)x y:(float)y;
- (id)initWithStamp:(id)id x:(float)x y:(float)y stamp:(float)timeStamp;

@end