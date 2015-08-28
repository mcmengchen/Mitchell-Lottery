//
//  ViewController.m
//  Mitchell彩票
//
//  Created by MENGCHEN on 15/8/27.
//  Copyright (c) 2015年 Mcking. All rights reserved.
//

#import "ViewController.h"
#import "MitchellView.h"
@interface ViewController ()
/**
 *
 */
@property(nonatomic,weak)MitchellView * vi;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MitchellView *view = [MitchellView view];
    view.center = self.view.center;
    [self.view addSubview:view];
    _vi = view;
    

}
- (IBAction)stop:(id)sender {
    [_vi stop];
    
}
- (IBAction)start:(id)sender {
    [_vi start];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
