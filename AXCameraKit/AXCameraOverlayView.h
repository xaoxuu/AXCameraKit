//
//  AXCameraOverlayView.h
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 根据按钮的tag判断是哪个按钮

 - CameraOverlayButtonUnknown: 未知按钮
 - CameraOverlayButtonDismiss: dismiss按钮
 - CameraOverlayButtonShutter: 快门按钮
 - CameraOverlayButtonSwitch: 切换前后摄像头按钮
 */
//typedef NS_ENUM(NSUInteger, CameraOverlayButton) {
//    CameraOverlayButtonUnknown = 10000,
//    CameraOverlayButtonDismiss,
//    CameraOverlayButtonShutter,
//    CameraOverlayButtonSwitch,
//    CameraOverlayButtonFlashlight,
//};

typedef NS_ENUM(NSUInteger, CameraOverlayViewFlashlightButtonState) {
    CameraOverlayViewFlashlightButtonStateOff,
    CameraOverlayViewFlashlightButtonStateOn,
    CameraOverlayViewFlashlightButtonStateAuto, // default
};

typedef NS_ENUM(NSUInteger, CameraOverlayViewAspectRatio) {
    CameraOverlayViewAspectRatio1_1,
    CameraOverlayViewAspectRatio4_3, // default
    CameraOverlayViewAspectRatio16_9,
    CameraOverlayViewAspectRatioFill,
};


@protocol AXCameraOverlayViewDelegate

@optional

- (void)overlayViewDidTappedDismissButton:(UIButton *)sender;
- (void)overlayViewDidTappedShutterButton:(UIButton *)sender;
- (void)overlayViewDidTappedSwitchCameraDeviceButton:(UIButton *)sender;
- (void)overlayViewDidTappedSwitchFlashlightButton:(UIButton *)sender;
- (void)overlayViewDidTappedChangeAspectRatioButton:(UIButton *)sender;


/**
 改变闪光灯模式

 @param mode 闪光灯模式
 */
- (void)overlayViewDidChangeFlashMode:(AVCaptureFlashMode)mode;


/**
 切换前后摄像头

 @param position 设备位置
 */
- (void)overlayViewDidSwitchCameraDevicePosition:(AVCaptureDevicePosition)position;

/**
 改变长宽比

 @param aspectRatio 长宽比
 */
- (void)overlayViewDidChangeAspectRatio:(CameraOverlayViewAspectRatio)aspectRatio;

/**
 点击了某个点

 @param point 坐标点
 */
- (void)overlayViewDidTouchAtPoint:(CGPoint)point;

@end

/**
 相机的overlay图层
 */
@interface AXCameraOverlayView : UIView

// @xaoxuu: delegate
@property (weak, nonatomic) NSObject<AXCameraOverlayViewDelegate> *delegate;
/**
 闪光灯
 */
@property (strong, nonatomic) UIButton *switchFlashlightButton;

/**
 dismiss按钮，用于退出相机页面
 */
@property (strong, nonatomic) UIButton *dismissButton;

/**
 改变长宽比按钮
 */
@property (strong, nonatomic) UIButton *changeAspectRatioButton;

/**
 快门按钮，用于拍照
 */
@property (strong, nonatomic) UIButton *shutterButton;

/**
 切换前后摄像头按钮
 */
@property (strong, nonatomic) UIButton *switchCameraDeviceButton;

/**
 预览照片按钮
 */
@property (strong, nonatomic) UIButton *previewButton;

/**
 设置是否显示缩略图预览，默认为否
 */
@property (assign, getter=isEnablePreview, nonatomic) BOOL enablePreview;

// @xaoxuu: preview layer frame
@property (assign, nonatomic) CGRect previewFrame;


- (void)updatePreviewLayerFrameWithAspectRatio:(CameraOverlayViewAspectRatio)aspectRatio;

- (void)updateUIWithDeviceOrientation;


@end
NS_ASSUME_NONNULL_END
