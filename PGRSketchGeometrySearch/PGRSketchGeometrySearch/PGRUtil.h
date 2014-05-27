//
//  PGRUtil.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-16.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGRControlPoint.h"
#import "DollarPoint.h"
@interface PGRUtil : NSObject

- (NSNumber *)meanOf:(NSArray *)array;

- (NSNumber *)standardDeviationOf:(NSArray *)array;

+ (BOOL)isLineSegment:(NSArray *)points;
+ (PGRControlPoint *)findNearestControllPoint:(DollarPoint *)newControlPoint in:(NSDictionary *)allControlPoints;
+ (PGRControlPoint *)createNewControlPointAt:(DollarPoint *)location in:(NSMutableDictionary *)allControlPoints;
+ (CGFloat)distance:(CGPoint)a from:(CGPoint)b;
+ (float)calculateLength:(NSArray *)points;
+ (BOOL)refineStartAndEnd:(DollarPoint *)point in:(NSMutableDictionary *)allControlPoints;

@end
