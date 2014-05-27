//
//  PGRControlPoint.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-7.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRControlPoint.h"

@implementation PGRControlPoint

- (id)initWithCGPoint:(CGPoint)cgPoint
{
    self = [super init];
    if (self) {
        [self setCoordinates:cgPoint];
        [self setReferredStroke:[[NSMutableDictionary alloc] init]];
        [self setConnectedControlPoints:[[NSMutableDictionary alloc] init]];
    }
    
    return self;
}

- (int)referenceCount
{
    return [[self referredStroke] count];
}

- (NSValue *)getKey
{
    return [NSValue valueWithCGPoint:[self coordinates]];
}



@end
