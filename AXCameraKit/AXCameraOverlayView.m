//
//  AXCameraOverlayView.m
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import "AXCameraOverlayView.h"

static NSString *moduleName = @"AXCameraKit";
static inline BOOL isIphoneX(){
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO);
}

//NSString *url = @"photos-redirect://";
static CGFloat margin = 8;
static CGFloat normalButtonSize = 64.0f;
static CGFloat kMinHeight = 64 + 16;

static CGFloat kScreenH(){
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        height = [UIScreen mainScreen].bounds.size.height;
    });
    return height;
}

static CGFloat kTopViewHeight(){
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        height = 40;
        if (isIphoneX()) {
            height += 24;
        }
    });
    return height;
}

static CGFloat kBottomViewHeight(){
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        height = 128;
        if (isIphoneX()) {
            height += 34;
        }
    });
    return height;
}


static CGFloat kBottomSafeMargin(){
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        height = 32;
        if (isIphoneX()) {
            height += 34;
        }
    });
    return height;
}


static CGFloat currentBottomHeight;





static inline UIEdgeInsets UIEdgeInsetsWithMargin(CGFloat margin){
    return UIEdgeInsetsMake(margin, margin, margin, margin);
}

static inline UIImage *loadImageWithBundleAndImageName(NSBundle *bundle, NSString *name) {
    NSString *suffix = @"@2x";
    if (kScreenH() == 736 || kScreenH() == 812) {
        suffix = @"@3x";
    }
    NSString *path = [bundle pathForResource:[name stringByAppendingString:suffix] ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    return img;
}
static inline UIImage *loadImageWithName(NSString *name) {
    // in mainBundle/AXCameraKit.bundle
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:moduleName ofType:@"bundle"]];
    UIImage *img = loadImageWithBundleAndImageName(bundle, name);
    if (!img) {
        NSString *path_frameworks = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks"];
        path_frameworks = [[path_frameworks stringByAppendingPathComponent:moduleName] stringByAppendingPathExtension:@"framework"];
        bundle = [NSBundle bundleWithPath:path_frameworks];
        bundle = [NSBundle bundleWithPath:[bundle pathForResource:moduleName ofType:@"bundle"]];
        img = loadImageWithBundleAndImageName(bundle, name);
    }
    return img;
}



@interface AXCameraOverlayView()

/**
 顶部操作区域的图层
 */
@property (strong, nonatomic) UIView *topOverlayView;

/**
 底部操作区域的图层
 */
@property (strong, nonatomic) UIView *bottomOverlayView;

/**
 对焦框
 */
@property (strong, nonatomic )UIView *focusView;


@end


@implementation AXCameraOverlayView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self _init];
    }
    return self;
}

- (void)_init{
    // const
    
    // overlay
    [self _initOverlayView];
    
    // update frame
    self.frame = self.frame;
    
    // front camera available
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        self.switchCameraDeviceButton.userInteractionEnabled = YES;
        self.switchCameraDeviceButton.alpha = 1;
    } else {
        self.switchCameraDeviceButton.userInteractionEnabled = NO;
        self.switchCameraDeviceButton.alpha = 0.5;
    }
    
    // 默认不显示预览
    self.enablePreview = NO;
}

- (void)_initOverlayView{
    // top view
    self.topOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kTopViewHeight())];
    self.topOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self addSubview:self.topOverlayView];
    // top buttons
    self.switchFlashlightButton = [self targetView:self.topOverlayView addButtonWithImageName:@"flashlight_auto" imageEdgeInsets:0];
    self.switchFlashlightButton.tag = CameraOverlayViewFlashlightButtonStateAuto;
    
    self.changeAspectRatioButton = [self targetView:self.topOverlayView addButtonWithImageName:@"aspect_4_3" imageEdgeInsets:0];
    self.changeAspectRatioButton.tag = CameraOverlayViewAspectRatio4_3;
    
    self.previewButton = [self targetView:self.topOverlayView addButtonWithImageName:nil imageEdgeInsets:0];
    self.previewButton.layer.cornerRadius = 4;
    self.previewButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    
    
    // bottom view
    self.bottomOverlayView = [[UIView alloc] initWithFrame:self.bounds];
    self.bottomOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self addSubview:self.bottomOverlayView];
    
    // bottom buttons
    self.dismissButton = [self targetView:self.bottomOverlayView addButtonWithImageName:@"arrow" imageEdgeInsets:0];
    self.shutterButton = [self targetView:self.bottomOverlayView addButtonWithImageName:@"shutter" imageEdgeInsets:0];
    self.switchCameraDeviceButton = [self targetView:self.bottomOverlayView addButtonWithImageName:@"camera" imageEdgeInsets:0];
    
    // gesture
    
    self.focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.focusView.layer.borderWidth = 1.0;
    self.focusView.layer.borderColor =[UIColor greenColor].CGColor;
    self.focusView.backgroundColor = [UIColor clearColor];
    [self insertSubview:self.focusView belowSubview:self.topOverlayView];
    self.focusView.hidden = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    // top
    CGRect topFrame = frame;
    topFrame.size.height = kTopViewHeight();
    if (isIphoneX() && frame.origin.y < 24) {
        topFrame.size.height += 24 - frame.origin.y; // 刘海的高度
    }
    [self updateTopOverlayFrame:topFrame];
    // bottom
    CGRect bottomFrame = frame;
    bottomFrame.size.height = kBottomViewHeight();
    if (isIphoneX() && kScreenH() - (frame.origin.y + frame.size.height) < 34) {
        bottomFrame.size.height += 34 - (kScreenH() - (frame.origin.y + frame.size.height)); // 底部安全区域
    }
    bottomFrame.origin.y = frame.size.height - bottomFrame.size.height;
    [self updateBottomOverlayFrame:bottomFrame];
    
    
}

- (CGRect)previewFrame{
    if (CGRectEqualToRect(_previewFrame, CGRectZero)) {
        [self updatePreviewLayerFrameWithAspectRatio:CameraOverlayViewAspectRatio4_3];
    }
    return _previewFrame;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [self.bottomOverlayView setBackgroundColor:backgroundColor];
}

- (void)setEnablePreview:(BOOL)enablePreview{
    _enablePreview = enablePreview;
    self.previewButton.hidden = !enablePreview;
}


- (void)updateTopOverlayFrame:(CGRect)frame{
    self.topOverlayView.frame = frame;
    CGFloat y = frame.size.height - kTopViewHeight();
    CGFloat i = 0;
    self.switchFlashlightButton.frame = CGRectMake(i++ * (kTopViewHeight() + margin), y, kTopViewHeight(), kTopViewHeight());
    self.changeAspectRatioButton.frame = CGRectMake(i++ * (kTopViewHeight() + margin), y, kTopViewHeight(), kTopViewHeight());
    
    CGRect previewFrame = frame;
    previewFrame.size.height = kTopViewHeight();
    previewFrame.size.width = previewFrame.size.height * 3 / 4;
    previewFrame.origin.y = 0;
    previewFrame.origin.x = frame.size.width - previewFrame.size.width;
    self.previewButton.frame = previewFrame;
}

- (void)updateBottomOverlayFrame:(CGRect)frame{
    // bottom
    CGFloat offset = frame.size.height - kMinHeight;
    if (offset < 0) {
        frame.size.height = kMinHeight;
        frame.origin.y += offset;
    }
    currentBottomHeight = frame.size.height;
    self.bottomOverlayView.frame = frame;
    // layout shutter button
    CGRect tmpFrame = self.shutterButton.frame;
    tmpFrame.origin.x = 0.5 * (frame.size.width - tmpFrame.size.width);
    CGFloat marginToBottom = MIN(0.5 * (frame.size.height - tmpFrame.size.height), kBottomSafeMargin());
    tmpFrame.origin.y = frame.size.height - marginToBottom - tmpFrame.size.height;
    
    self.shutterButton.frame = tmpFrame;
    // layout dismiss button
    tmpFrame.origin.x = 2*margin;
    self.dismissButton.frame = tmpFrame;
    // layout switch button
    tmpFrame.origin.x = frame.size.width - tmpFrame.size.width - 2*margin;
    self.switchCameraDeviceButton.frame = tmpFrame;
    
    
}
- (UIButton *)targetView:(UIView *)targetView addButtonWithImageName:(NSString *)imageName imageEdgeInsets:(CGFloat)imageEdgeInsets{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, normalButtonSize, normalButtonSize)];
    btn.layer.masksToBounds = YES;
    btn.tag = NSIntegerMax;
//    btn.layer.cornerRadius = 0.5 * fmin(btn.layer.frame.size.width, btn.layer.frame.size.height);
    btn.imageEdgeInsets = UIEdgeInsetsWithMargin(imageEdgeInsets);
    if (imageName.length) {
        [btn setImage:loadImageWithName(imageName) forState:UIControlStateNormal];
    }
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [targetView addSubview:btn];
    return btn;
}


- (void)btnAction:(UIButton *)sender{
    if ([sender isEqual:self.dismissButton]) { // 关闭按钮
        if ([self.delegate respondsToSelector:@selector(overlayViewDidTappedDismissButton:)]) {
            [self.delegate overlayViewDidTappedDismissButton:sender];
        }
    } else if ([sender isEqual:self.shutterButton]) { // 快门按钮
        if ([self.delegate respondsToSelector:@selector(overlayViewDidTappedShutterButton:)]) {
            [self.delegate overlayViewDidTappedShutterButton:sender];
        }
    } else if ([sender isEqual:self.switchCameraDeviceButton]) { // 切换前后镜头
        if (sender.tag == AVCaptureDevicePositionBack) {
            sender.tag = AVCaptureDevicePositionFront;
        } else {
            sender.tag = AVCaptureDevicePositionBack;
        }
        if ([self.delegate respondsToSelector:@selector(overlayViewDidSwitchCameraDevicePosition:)]) {
            [self.delegate overlayViewDidSwitchCameraDevicePosition:sender.tag];
        }
    } else if ([sender isEqual:self.switchFlashlightButton]) { // 开关闪光灯
        if (sender.tag == AVCaptureFlashModeAuto) {
            sender.tag = AVCaptureFlashModeOff;
            [sender setImage:loadImageWithName(@"flashlight_off") forState:UIControlStateNormal];
        } else if (sender.tag == AVCaptureFlashModeOff) {
            sender.tag = AVCaptureFlashModeOn;
            [sender setImage:loadImageWithName(@"flashlight_on") forState:UIControlStateNormal];
        } else if (sender.tag == AVCaptureFlashModeOn) {
            sender.tag = AVCaptureFlashModeAuto;
            [sender setImage:loadImageWithName(@"flashlight_auto") forState:UIControlStateNormal];
        }
        if ([self.delegate respondsToSelector:@selector(overlayViewDidChangeFlashMode:)]) {
            [self.delegate overlayViewDidChangeFlashMode:sender.tag];
        }
    } else if ([sender isEqual:self.changeAspectRatioButton]) { // 改变比例
        if (sender.tag == CameraOverlayViewAspectRatio1_1) {
            sender.tag = CameraOverlayViewAspectRatio4_3;
            [sender setImage:loadImageWithName(@"aspect_4_3") forState:UIControlStateNormal];
        } else if (sender.tag == CameraOverlayViewAspectRatio4_3) {
            sender.tag = CameraOverlayViewAspectRatio16_9;
            [sender setImage:loadImageWithName(@"aspect_16_9") forState:UIControlStateNormal];
        } else if (sender.tag == CameraOverlayViewAspectRatio16_9) {
            sender.tag = CameraOverlayViewAspectRatioFill;
            [sender setImage:loadImageWithName(@"aspect_fill") forState:UIControlStateNormal];
        } else if (sender.tag == CameraOverlayViewAspectRatioFill) {
            sender.tag = CameraOverlayViewAspectRatio1_1;
            [sender setImage:loadImageWithName(@"aspect_1_1") forState:UIControlStateNormal];
        }
        [self updatePreviewLayerFrameWithAspectRatio:sender.tag];
        
    } else if ([sender isEqual:self.previewButton]) { // 预览
        NSURL *photoLibrary = [NSURL URLWithString:@"photos-redirect://"];
        if ([[UIApplication sharedApplication] canOpenURL:photoLibrary]) {
            [[UIApplication sharedApplication] openURL:photoLibrary];
        }
    }
}


- (void)updateUIWithDeviceOrientation{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    CGAffineTransform transform;
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        transform = CGAffineTransformMakeRotation(M_PI_2);
    } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        transform = CGAffineTransformMakeRotation(-M_PI_2);
    } else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        transform = CGAffineTransformIdentity;
    }
    
    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.72f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        self.switchCameraDeviceButton.transform = transform;
        self.switchFlashlightButton.transform = transform;
        self.changeAspectRatioButton.transform = transform;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)updatePreviewLayerFrameWithAspectRatio:(CameraOverlayViewAspectRatio)aspectRatio{
    CGRect frame = self.frame;
    CGFloat width = frame.size.width;
    CGFloat height = width;
    CGFloat y = frame.origin.y;
    switch (aspectRatio) {
        case CameraOverlayViewAspectRatio1_1:
            height = width;
            y = 0.5 * (self.frame.size.height - height - kTopViewHeight() - kBottomViewHeight()) + kTopViewHeight();
            break;
        case CameraOverlayViewAspectRatio4_3:
            height = width * 4 / 3;
            y = kTopViewHeight();
            break;
        case CameraOverlayViewAspectRatio16_9:
            height = width * 16 / 9;
            break;
        case CameraOverlayViewAspectRatioFill:
            height = self.frame.size.height;
            break;
    }
    CGFloat offset = y + height - (frame.size.height - kMinHeight);
    if (offset < kMinHeight && offset > 0) {
        y = 0;
    }
    frame = CGRectMake(0, y, width, height);
    _previewFrame = frame;
    [UIView animateWithDuration:0.18 animations:^{
        [self updateBottomOverlayFrame:CGRectMake(0, height + frame.origin.y, width, self.frame.size.height - height - y)];
    }];
    if ([self.delegate respondsToSelector:@selector(overlayViewDidChangeAspectRatio:)]) {
        [self.delegate overlayViewDidChangeAspectRatio:aspectRatio];
    }
}
#pragma mark 点击手势：对焦
- (void)focusGesture:(UITapGestureRecognizer *)sender{
    CGPoint point = [sender locationInView:sender.view];
    self.focusView.center = point;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.focusView.hidden = YES;
        }];
    }];
    
    CGPoint focusPoint = CGPointMake(point.y /self.bounds.size.height ,1-point.x/self.bounds.size.width);
    if ([self.delegate respondsToSelector:@selector(overlayViewDidTouchAtPoint:)]) {
        [self.delegate overlayViewDidTouchAtPoint:focusPoint];
    }
    
}


#pragma mark - priv




@end
