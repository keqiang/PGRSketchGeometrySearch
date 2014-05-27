//
//  PGRCircle.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-11.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGRShape.h"

@interface PGRCircle : PGRShape

@property (nonatomic) CGPoint center;
@property (nonatomic) float radius;

- (id)initWithCenter:(CGPoint)centerValue andRadius:(float)radiusValue;

@end
