//
//  PGRWebResultViewController.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-26.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRWebResultViewController.h"

@interface PGRWebResultViewController ()

@end

@implementation PGRWebResultViewController 

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIWebView *wv = [[UIWebView alloc] initWithFrame:screenFrame];
    wv.delegate = self;
    [wv setScalesPageToFit:YES];
    
    [self.navigationItem setTitle:@"Search Results"];
    
    [self setView:wv];
}

- (UIWebView *)webView
{
    return (UIWebView *)[self view];
}

- (void)viewDidAppear:(BOOL)animated
{
    // show a indicator
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = indicator.frame;
    frame.origin.x = 500;
    frame.origin.y = 350;
    indicator.frame = frame;
    indicator.transform = CGAffineTransformMakeScale(2.5, 2.5);
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [indicator startAnimating];
    
    // load the data
    NSURL *url = [NSURL URLWithString:@"http://www.askleaf.com/result1.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *) portal{
   
    [indicator stopAnimating];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
