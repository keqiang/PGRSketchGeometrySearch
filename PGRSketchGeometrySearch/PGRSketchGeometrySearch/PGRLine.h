//
//  PGRLine.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-12.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRShape.h"
#import "DollarPoint.h"

@interface PGRLine : PGRShape

@property (nonatomic) DollarPoint *start;
@property (nonatomic) DollarPoint *end;

-(id)initWithStartPoint:(DollarPoint *)startPoint endPoint:(DollarPoint *)endPoint;

@end
