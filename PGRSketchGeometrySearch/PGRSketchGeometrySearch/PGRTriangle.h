//
//  PGRTriangle.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-25.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRShape.h"
#import "DollarPoint.h"

@interface PGRTriangle : PGRShape

@property (nonatomic) DollarPoint *p1;
@property (nonatomic) DollarPoint *p2;
@property (nonatomic) DollarPoint *p3;

-(id)initWithPoint1:(DollarPoint *)point1 point2:(DollarPoint *)point2 point3:(DollarPoint *)point3;

@end
