//
//  AXCameraViewController.h
//  AXCameraKit
//
//  Created by xaoxuu on 21/11/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AXCameraViewController : UIViewController


/**
 拍照
 */
- (void)takePicture;


/**
 切换前后摄像头
 */
- (void)switchCameraDevice;


/**
 开关闪光灯
 */
- (void)switchFlashlight;


@end
