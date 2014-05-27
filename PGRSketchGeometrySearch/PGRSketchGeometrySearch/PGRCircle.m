//
//  PGRCircle.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-11.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRCircle.h"
#import "PGRShape.h"

@implementation PGRCircle

@synthesize center, radius;

- (id)initWithCenter:(CGPoint)centerValue andRadius:(float)radiusValue
{
    self = [super initWithType:TYPE_CIRCLE];
    if (self) {
        [self setRadius:radiusValue];
        [self setCenter:centerValue];
    }
    return self;
}

@end
