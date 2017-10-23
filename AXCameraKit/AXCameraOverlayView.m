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
    actionIndex = CameraOverlayButtonDismiss;
    UIButton *dismissButton = [self buttonWithImageName:@"ax_camera_dismiss" action:nil];
    UIButton *shutterButton = [self buttonWithImageName:@"ax_camera_shutter" action:nil];
    UIButton *switchButton = [self buttonWithImageName:@"ax_camera_switch" action:nil];
    [self addSubview:dismissButton];
    [self addSubview:shutterButton];
    [self addSubview:switchButton];
    self.dismissButton = dismissButton;
    self.shutterButton = shutterButton;
    self.switchButton = switchButton;
    
    self.frame = self.frame;
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
    // @xaoxuu: in main bundle/AXCameraKit.bundle
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"123");
}


@end
