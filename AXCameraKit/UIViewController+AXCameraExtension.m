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
#import "AXCameraOverlayView.h"

static UIImagePickerController *imagePicker;
static UIColor *sTintColor;
static BOOL isActive = NO;


@implementation UIViewController (AXCameraExtension)


- (void)loadCameraVCWithTintColor:(UIColor *)tintColor{
    sTintColor = tintColor;
    [self loadCameraVC];
}
- (void)loadCameraVC{
    if (imagePicker) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // in background queue
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //录制视频时长，默认10s
        imagePicker.videoMaximumDuration = 15;
        
        //相机类型（拍照、录像...）字符串需要做相应的类型
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        
        //视频上传质量
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        //设置摄像头模式（拍照，录制视频）为录像模式
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePicker.showsCameraControls = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // @xaoxuu: in main queue
            imagePicker.cameraOverlayView = [self setupOverlayView];
        });
    });
    
    
}



- (void)presentCameraVC:(void (^)(void))completion{
    if (!isActive) {
        isActive = YES;
        [self presentViewController:imagePicker animated:YES completion:completion];
    }
}


- (void)dismissCameraVC:(void (^)(void))completion{
    isActive = NO;
    [imagePicker dismissViewControllerAnimated:YES completion:completion];
}

- (void)takePicture{
    [imagePicker takePicture];
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
        if (imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        } else {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
    }
}


#pragma mark - priv

- (UIView *)setupOverlayView{
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height - width * 4 / 3;
    CGFloat originY = self.view.bounds.size.height - height;
    if (!sTintColor) {
        sTintColor = [UIColor blueColor];
    }
    AXCameraOverlayView *overlayView = [[AXCameraOverlayView alloc] initWithFrame:CGRectMake(0, originY, width, height) tintColor:sTintColor];
    [overlayView.cancel addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.ok addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.switchCamera addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat margin = 16;
    overlayView.cancel.imageEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    overlayView.switchCamera.imageEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    return overlayView;
}



@end



