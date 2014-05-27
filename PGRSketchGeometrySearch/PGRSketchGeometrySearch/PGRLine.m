//
//  PGRLine.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-12.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRLine.h"
#import "PGRShape.h"

@implementation PGRLine

@synthesize start, end;

-(id)initWithStartPoint:(DollarPoint *)startPoint endPoint:(DollarPoint *)endPoint
{
    self = [super initWithType:TYPE_LINE];
    if (self) {
        [self setStart:startPoint];
        [self setEnd:endPoint];
    }
    return self;
}

@end
