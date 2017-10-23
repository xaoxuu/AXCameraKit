//
//  AXCameraOverlayView.h
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 根据按钮的tag判断是哪个按钮

 - CameraOverlayButtonUnknown: 未知按钮
 - CameraOverlayButtonDismiss: dismiss按钮
 - CameraOverlayButtonShutter: 快门按钮
 - CameraOverlayButtonSwitch: 切换前后摄像头按钮
 */
typedef NS_ENUM(NSUInteger, CameraOverlayButton) {
    CameraOverlayButtonUnknown = 0,
    CameraOverlayButtonDismiss,
    CameraOverlayButtonShutter,
    CameraOverlayButtonSwitch,
};


/**
 相机的overlay图层
 */
@interface AXCameraOverlayView : UIView


/**
 dismiss按钮，用于退出相机页面
 */
@property (strong, nonatomic) UIButton *dismissButton;

/**
 快门按钮，用于拍照
 */
@property (strong, nonatomic) UIButton *shutterButton;

/**
 切换前后摄像头按钮
 */
@property (strong, nonatomic) UIButton *switchButton;

/**
 预览照片
 */
@property (strong, nonatomic) UIImage *previewImage;

/**
 设置是否显示缩略图预览
 */
@property (assign, getter=isEnablePreview, nonatomic) BOOL enablePreview;

@end
NS_ASSUME_NONNULL_END
