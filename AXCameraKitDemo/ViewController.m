//
//  ViewController.m
//  AXCameraKitDemo
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import "ViewController.h"
#import <AXCameraKit/AXCameraKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadCameraKit];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    [self presentCameraVC:nil];
}

- (void)cameraDidTakePicture:(UIImage *)image{
    NSLog(@"%@",image);
}
- (void)cameraDidPresented{
    NSLog(@"pre");
}
- (void)cameraDidDismissed{
    NSLog(@"dismiss");
}
@end
