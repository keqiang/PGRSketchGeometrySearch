//
//  PGRTriangle.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-25.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRTriangle.h"


@implementation PGRTriangle

@synthesize p1, p2, p3;


- (id)initWithPoint1:(DollarPoint *)point1 point2:(DollarPoint *)point2 point3:(DollarPoint *)point3
{
    self = [super initWithType:TYPE_TRIANGLE];
    if (self) {
        [self setP1:point1];
        [self setP2:point2];
        [self setP3:point3];
    }
    return self;
}

@end
