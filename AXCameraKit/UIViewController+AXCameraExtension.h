//
//  UIViewController+AXCameraExtension.h
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXCameraOverlayView.h"

/**
 相机代理，用于监听相机状态。无需手动设置代理。
 */
@protocol AXCameraKit

@optional

/**
 相机页面present
 */
- (void)cameraDidPresented;

/**
 相机页面dismiss
 */
- (void)cameraDidDismissed;

/**
 拍照

 @param image 照片
 */
- (void)cameraDidTakePicture:(UIImage *)image;

@end

@interface UIViewController (AXCameraExtension)


/**
 overlay view
 */
@property (strong, nonatomic) AXCameraOverlayView *overlayView;


/**
 加载相机，可以提前异步加载
 */
- (void)loadCameraVC;

/**
 显示相机页面

 @param completion 完成回调
 */
- (void)presentCameraVC:(void (^)(void))completion;

/**
 退出相机页面
 
 @param completion 完成回调
 */
- (void)dismissCameraVC:(void (^)(void))completion;

/**
 拍照
 */
- (void)takePicture;


@end
