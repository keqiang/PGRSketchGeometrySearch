//
//  PGRStroke.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-10.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//
#import "PGRShape.h"

@interface PGRStroke : NSObject

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) id id;
@property (nonatomic) BOOL isBeautified;
@property (nonatomic) ShapeType belongToShape;

- (float)strokeLength;

@end
