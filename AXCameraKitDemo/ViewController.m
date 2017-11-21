//
//  ViewController.m
//  AXCameraKitDemo
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import "ViewController.h"
#import <AXCameraKit/AXCameraKit.h>
#import "AXCameraViewController.h"

@interface ViewController ()
//@property (weak, nonatomic) AXCameraViewController *vc;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self loadCameraKit];
//    self.overlayView.enablePreview = YES;
}

- (IBAction)openCamera:(UIButton *)sender {
    AXCameraViewController *vc = [[AXCameraViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}


//- (AXCameraViewController *)vc{
//    if (!_vc) {
//        _vc = [[AXCameraViewController alloc] init];
//    }
//    return _vc;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)dealloc{
    NSLog(@"dealloc");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
//    [self presentCameraVC:nil];
    
}

//- (void)cameraDidTakePicture:(UIImage *)image{
//    NSLog(@"%@",image);
//}
//- (void)cameraDidPresented{
//    NSLog(@"pre");
//}
//- (void)cameraDidDismissed{
//    NSLog(@"dismiss");
//}
@end
