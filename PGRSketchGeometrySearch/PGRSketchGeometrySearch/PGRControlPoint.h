//
//  PGRControlPoint.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-7.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGRControlPoint : NSObject

@property (nonatomic) CGPoint coordinates;
@property (strong, nonatomic) NSMutableDictionary *referredStroke;

// ISSUE: double strong reference
@property (strong, nonatomic) NSMutableDictionary *connectedControlPoints;

// designated init method
- (id)initWithCGPoint:(CGPoint)cgPoint;
- (int)referenceCount;

- (NSValue *)getKey;

@end
