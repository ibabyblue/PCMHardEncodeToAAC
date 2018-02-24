//
//  ViewController.m
//  PCMHardEncodeToAAC
//
//  Created by ibabyblue on 2018/2/23.
//  Copyright © 2018年 ibabyblue. All rights reserved.
//

#import "ViewController.h"
#import "BBAudioCapture.h"
#import "BBAudioConfig.h"

@interface ViewController ()
@property (nonatomic, strong) BBAudioCapture *capture;
@end

@implementation ViewController

- (BBAudioCapture *)capture{
    if (_capture == nil) {
        _capture = [[BBAudioCapture alloc] init];
    }
    return _capture;
}

- (IBAction)stop:(id)sender {
    [self.capture stopRunning];
}

- (IBAction)start:(id)sender {
    self.capture.config = [BBAudioConfig defaultConfig];
    [self.capture startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
