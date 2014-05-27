//
//  PGRShape.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-3-12.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TYPE_CIRCLE = 0,
    TYPE_SQUARE = 1,
    TYPE_RECTANGLE = 2,
    TYPE_TRIANGLE = 3,
    TYPE_LINE = 4
} ShapeType;

@interface PGRShape : NSObject

@property (nonatomic) ShapeType type;

-(id)initWithType:(ShapeType)typeName;

@end
