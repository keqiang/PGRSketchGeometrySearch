//
//  PGRRectangle.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-25.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRRectangle.h"

@implementation PGRRectangle

@synthesize p1, p2, p3, p4;


- (id)initWithPoint1:(DollarPoint *)point1 point2:(DollarPoint *)point2 point3:(DollarPoint *)point3 point4:(DollarPoint *)point4
{
    self = [super initWithType:TYPE_RECTANGLE];
    if (self) {
        [self setP1:point1];
        [self setP2:point2];
        [self setP3:point3];
        [self setP4:point4];
    }
    return self;
}

@end
