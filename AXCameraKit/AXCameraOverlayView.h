//
//  AXCameraOverlayView.h
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 根据按钮的tag判断是哪个按钮

 - CameraOverlayButtonUnknown: 未知
 - CameraOverlayButtonCancel: 取消按钮，用于dismiss
 - CameraOverlayButtonOk: 快门按钮
 - CameraOverlayButtonSwitch: 切换前后相机
 */
typedef NS_ENUM(NSUInteger, CameraOverlayButton) {
    CameraOverlayButtonUnknown = 0,
    CameraOverlayButtonCancel,
    CameraOverlayButtonOk,
    CameraOverlayButtonSwitch,
};


/**
 相机的overlay图层
 */
@interface AXCameraOverlayView : UIView


/**
 dismiss按钮，用于退出相机页面
 */
@property (strong, nonatomic) UIButton *dismiss;

/**
 shutter快门按钮，用于拍照
 */
@property (strong, nonatomic) UIButton *shutter;

/**
 切换前后镜头按钮
 */
@property (strong, nonatomic) UIButton *switchCamera;


@end
