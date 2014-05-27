//
//  PGRShape.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-12.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRShape.h"

@implementation PGRShape

@synthesize type;

-(id)initWithType:(ShapeType)typeName
{
    self = [super init];
    if (self) {
        [self setType:typeName];
    }
    return self;
}

@end
