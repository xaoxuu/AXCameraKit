//
//  AXCameraOverlayView.m
//  AXCameraKit
//
//  Created by xaoxuu on 18/10/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import "AXCameraOverlayView.h"

static CGFloat margin = 16;
static CGFloat normalButtonSize = 64.0f;

static NSString *moduleName = @"AXCameraKit";
typedef void(^BlockType)(void);
static NSInteger actionIndex = CameraOverlayButtonDismiss;
static NSString *stringFromInteger(NSInteger index){
    return [NSString stringWithFormat:@"%ld", (long)index];
}


@interface AXCameraOverlayView()

@property (strong, nonatomic) NSMutableDictionary<NSString *, BlockType> *actions;

@end

@implementation AXCameraOverlayView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _actions = [NSMutableDictionary dictionary];
        [self _init];
    }
    return self;
}

- (void)_init{
    // const
    actionIndex = CameraOverlayButtonDismiss;
    
    // buttons
    self.dismissButton = [self buttonWithImageName:@"ax_camera_dismiss" action:nil];
    self.shutterButton = [self buttonWithImageName:@"ax_camera_shutter" action:nil];
    self.switchButton = [self buttonWithImageName:@"ax_camera_switch" action:nil];
    [self addSubview:self.dismissButton];
    [self addSubview:self.shutterButton];
    [self addSubview:self.switchButton];
    
    // update frame
    self.frame = self.frame;
    CGFloat margin = 16;
    self.dismissButton.imageEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    margin = 18;
    self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    
    // front camera available
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        self.switchButton.userInteractionEnabled = YES;
        self.switchButton.alpha = 1;
    } else {
        self.switchButton.userInteractionEnabled = NO;
        self.switchButton.alpha = 0.5;
    }
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    // layout ok
    CGRect tmpFrame = self.shutterButton.frame;
    tmpFrame.origin.x = (frame.size.width - tmpFrame.size.width) / 2;
    tmpFrame.origin.y = (frame.size.height - tmpFrame.size.height) / 2;
    self.shutterButton.frame = tmpFrame;
    // layout cancel
    tmpFrame.origin.x = margin;
    self.dismissButton.frame = tmpFrame;
    // layout switch
    tmpFrame.origin.x = frame.size.width - tmpFrame.size.width - margin;
    self.switchButton.frame = tmpFrame;
}

- (UIButton *)buttonWithImageName:(NSString *)imageName action:(BlockType)action{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, normalButtonSize, normalButtonSize)];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 0.5 * fmin(btn.layer.frame.size.width, btn.layer.frame.size.height);
    [btn setImage:[self loadImageWithName:imageName] forState:UIControlStateNormal];
    btn.tag = actionIndex++;
    if (action) {
        self.actions[stringFromInteger(btn.tag)] = action;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return btn;
}

- (UIImage *)loadImageWithName:(NSString *)name{
    // in mainBundle/AXCameraKit.bundle
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:moduleName ofType:@"bundle"]];
    UIImage *img = [self loadImageWithBundle:bundle name:name];
    if (!img) {
        NSString *path_frameworks = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks"];
        path_frameworks = [[path_frameworks stringByAppendingPathComponent:moduleName] stringByAppendingPathExtension:@"framework"];
        bundle = [NSBundle bundleWithPath:path_frameworks];
        bundle = [NSBundle bundleWithPath:[bundle pathForResource:moduleName ofType:@"bundle"]];
        img = [self loadImageWithBundle:bundle name:name];
    }
    return img;
}

- (UIImage *)loadImageWithBundle:(NSBundle *)bundle name:(NSString *)name{
    NSString *path = [bundle pathForResource:name ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    return img;
}

- (void)btnAction:(UIButton *)sender{
    BlockType action = self.actions[stringFromInteger(sender.tag)];
    if (action) {
        action();
    }
}



@end
