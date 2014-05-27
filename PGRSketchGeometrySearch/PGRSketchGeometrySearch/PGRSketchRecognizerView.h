//
//  PGRSketchRecognizerView.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-22.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DollarP.h"

extern const float IGNORED_STROKE_LENGTH;

@interface PGRSketchRecognizerView : UIView
{
    NSMutableArray *touchPoints;
    NSMutableDictionary *controlPoints;
    NSMutableArray *recognizedShape;
    NSMutableDictionary *strokes;
    
    DollarP *dollarP;
    int strokeID;
}

-(void)clearAll;
-(void)searchShape;

@end
