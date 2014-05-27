//
//  PGRSketchRecognizerViewController.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-22.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRSketchRecognizerViewController.h"
#import "PGRWebResultViewController.h"


@interface PGRSketchRecognizerViewController ()

@end

@implementation PGRSketchRecognizerViewController

@synthesize webResultViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    sView = [[PGRSketchRecognizerView alloc] initWithFrame:CGRectZero];
    [self setView:sView];
}

- (IBAction)cleanCanvas:(id)sender
{
    [sView clearAll];
    [sView setNeedsDisplay];
}

- (IBAction)searchSketch:(id)sender
{
    [sView searchShape];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
