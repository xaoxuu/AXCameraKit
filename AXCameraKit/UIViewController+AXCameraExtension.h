//
//  UIViewController+AXCameraExtension.h
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AXCameraExtension)<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


- (void)loadCameraVC;

- (void)loadCameraVCWithTintColor:(UIColor *)tintColor;

- (void)presentCameraVC:(void (^)(void))completion;

- (void)dismissCameraVC:(void (^)(void))completion;


- (void)takePicture;


@end
