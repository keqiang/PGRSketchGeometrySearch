//
//  PGRStroke.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-10.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRStroke.h"
#import "DollarPoint.h"

@implementation PGRStroke

@synthesize points, color, id;

// calculate the stroke length by iterate all the points on the stroke
- (float)strokeLength
{
    float length = 0;
    for (int i = 0; i < [points count] - 1; ++i) {
        DollarPoint *a = [points objectAtIndex:i];
        DollarPoint *b = [points objectAtIndex:i+1];
        length += sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
    }
    return length;
}

@end
