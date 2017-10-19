//
//  UIViewController+AXCameraExtension.m
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import "UIViewController+AXCameraExtension.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@import ObjectiveC.runtime;

static BOOL isActive = NO;

static const void *AXCameraExtensionImagePickerKey = &AXCameraExtensionImagePickerKey;
static const void *AXCameraExtensionOverlayViewKey = &AXCameraExtensionOverlayViewKey;

@interface UIViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AXCameraKit>

/**
 image picker
 */
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation UIViewController (AXCameraExtension)

#pragma mark - life circle

- (UIImagePickerController *)imagePicker{
    return objc_getAssociatedObject(self, AXCameraExtensionImagePickerKey);
}
- (void)setImagePicker:(UIImagePickerController *)imagePicker{
    objc_setAssociatedObject(self, AXCameraExtensionImagePickerKey, imagePicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AXCameraOverlayView *)overlayView{
    return objc_getAssociatedObject(self, AXCameraExtensionOverlayViewKey);
}
- (void)setOverlayView:(AXCameraOverlayView *)overlayView{
    objc_setAssociatedObject(self, AXCameraExtensionOverlayViewKey, overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 加载相机，可以提前异步加载
 */
- (void)loadCameraVC{
    if (self.imagePicker) {
        return;
    }
    self.overlayView = [self setupOverlayView];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //录制视频时长，默认10s
    self.imagePicker.videoMaximumDuration = 15;
    
    //相机类型（拍照、录像...）字符串需要做相应的类型
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    
    //视频上传质量
    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    //设置摄像头模式（拍照，录制视频）为录像模式
    self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.imagePicker.showsCameraControls = NO;
    
    self.imagePicker.cameraOverlayView = self.overlayView;
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            [UIView animateWithDuration:0.38f animations:^{
                self.overlayView.switchCamera.transform = CGAffineTransformMakeRotation(M_PI_2);
            }];
        } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
            [UIView animateWithDuration:0.38f animations:^{
                self.overlayView.switchCamera.transform = CGAffineTransformMakeRotation(-M_PI_2);
            }];
        } else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            [UIView animateWithDuration:0.38f animations:^{
                self.overlayView.switchCamera.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        } else {
            [UIView animateWithDuration:0.38f animations:^{
                self.overlayView.switchCamera.transform = CGAffineTransformIdentity;
            }];
        }
        
    }];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - control

/**
 显示相机页面
 
 @param completion 完成回调
 */
- (void)presentCameraVC:(void (^)(void))completion{
    if (!isActive) {
        isActive = YES;
        [self presentViewController:self.imagePicker animated:YES completion:^{
            if (completion) {
                completion();
            }
            if ([self respondsToSelector:@selector(cameraDidPresented)]) {
                [self cameraDidPresented];
            }
        }];
    }
}

/**
 退出相机页面
 
 @param completion 完成回调
 */
- (void)dismissCameraVC:(void (^)(void))completion{
    isActive = NO;
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        if (completion) {
            completion();
        }
        if ([self respondsToSelector:@selector(cameraDidDismissed)]) {
            [self cameraDidDismissed];
        }
    }];
}

/**
 拍照
 */
- (void)takePicture{
    [self.imagePicker takePicture];
}


#pragma mark UIImagePickerControllerDelegate
//该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    NSLog(@"选择完毕----image:%@-----info:%@",image,editingInfo);
}

//适用获取所有媒体资源，只需判断资源类型
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        //        //如果是图片
        //        self.imageView.image = info[UIImagePickerControllerEditedImage];
        //        //压缩图片
        //        NSData *fileData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
        //        //保存图片至相册
        //        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        //        //上传图片
        //        [self uploadImageWithData:fileData];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
        if ([self respondsToSelector:@selector(cameraDidTakePicture:)]) {
            [self cameraDidTakePicture:image];
        }
    }else{
        //        //如果是视频
        //        NSURL *url = info[UIImagePickerControllerMediaURL];
        //        //播放视频
        //        _moviePlayer.contentURL = url;
        //        [_moviePlayer play];
        //        //保存视频至相册（异步线程）
        //        NSString *urlStr = [url path];
        //
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
        //
        //                UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        //            }
        //        });
        //        NSData *videoData = [NSData dataWithContentsOfURL:url];
        //        //视频上传
        //        [self uploadVideoWithData:videoData];
    }
    //    [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark 图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
}



#pragma mark - button action

- (void)overlayButtonTapped:(UIButton *)sender{
    if (sender.tag == CameraOverlayButtonCancel) {
        [self dismissCameraVC:nil];
    } else if (sender.tag == CameraOverlayButtonOk) {
        [self takePicture];
    } else if (sender.tag == CameraOverlayButtonSwitch) {
        if (self.imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        } else {
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
    }
}


#pragma mark - priv

- (AXCameraOverlayView *)setupOverlayView{
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height - width * 4 / 3;
    CGFloat originY = self.view.bounds.size.height - height;
    
    AXCameraOverlayView *overlayView = [[AXCameraOverlayView alloc] initWithFrame:CGRectMake(0, originY, width, height)];
    [overlayView.dismiss addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.shutter addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.switchCamera addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat margin = 16;
    overlayView.dismiss.imageEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    margin = 18;
    overlayView.switchCamera.imageEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    return overlayView;
}



@end



