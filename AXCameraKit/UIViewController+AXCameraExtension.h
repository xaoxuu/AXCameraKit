//
//  UIViewController+AXCameraExtension.h
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXCameraOverlayView.h"

NS_ASSUME_NONNULL_BEGIN
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


/**
 需要在哪个页面弹出相机，就在哪个页面导入此分类，不要放到全局头文件中。
 */
@interface UIViewController (AXCameraExtension) <AXCameraKit>


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
- (void)presentCameraVC:(void (^ _Nullable)(void))completion;

/**
 退出相机页面
 
 @param completion 完成回调
 */
- (void)dismissCameraVC:(void (^ _Nullable)(void))completion;

/**
 拍照
 */
- (void)takePicture;


@end
NS_ASSUME_NONNULL_END
