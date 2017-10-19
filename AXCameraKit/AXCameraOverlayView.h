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

@interface AXCameraOverlayView : UIView

// @xaoxuu: theme color
//@property (strong, nonatomic) UIColor *tintColor;

// @xaoxuu: cancel
@property (strong, nonatomic) UIButton *cancel;
// @xaoxuu: ok
@property (strong, nonatomic) UIButton *ok;
// @xaoxuu: switch camera
@property (strong, nonatomic) UIButton *switchCamera;



- (instancetype)initWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor;

@end
