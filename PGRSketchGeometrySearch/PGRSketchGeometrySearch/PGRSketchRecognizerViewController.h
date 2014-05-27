//
//  PGRSketchRecognizerViewController.h
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-22.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGRSketchRecognizerView.h"

@class PGRWebResultViewController;

@interface PGRSketchRecognizerViewController : UIViewController
{
    PGRSketchRecognizerView *sView;
}

@property (nonatomic, strong) PGRWebResultViewController *webResultViewController;

- (IBAction)cleanCanvas:(id)sender;
- (IBAction)searchSketch:(id)sender;

@end
