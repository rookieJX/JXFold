//
//  ViewController.m
//  JXFoldPicture
//
//  Created by 王加祥 on 16/5/7.
//  Copyright © 2016年 Wangjiaxiang. All rights reserved.
//


/**
 *  图片折叠效果，实现方式为设置两个UIImageView，每个的尺寸大小为图片尺寸的一半。之后可以实现上下折叠效果
 */
#import "ViewController.h"
#import "Masonry.h"

#define mainScale [UIScreen mainScreen].scale

@interface ViewController ()

/** 上半部分图片 */
@property (nonatomic,weak) UIImageView * topImageView;
/** 下半部分图片 */
@property (nonatomic,weak) UIImageView * bottomImageView;
/** 透明背景 */
@property (nonatomic,weak) UIView * transparentV;
/** 渐变图层 */
@property (nonatomic,weak) CAGradientLayer * gradientLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
    [self setupTwoImageView];
    
    [self setupPan];
}

// 创建两个UIImageView
- (void)setupTwoImageView {
    
    // 读取图片
    UIImage * image = [UIImage imageNamed:@"001"];
    
    // 创建透明背景控件
    [self setupViewWithImage:image];
    // 创建前景图片控件
    [self setupForeImage:image];
    // 设置渐变图层
    [self setupGradientLayer:image];
    
}

#pragma mark - 创建分控件
/**
 *  创建透明背景控件
 */
- (void)setupViewWithImage:(UIImage *)image {
    // 创建透明UIView
    UIView * transparentV = [[UIView alloc] init];
    transparentV.backgroundColor = [UIColor clearColor];
    // 将控件添加到屏幕上
    [self.view addSubview:transparentV];
    // 创建约束（约束必须要在添加之后）
    [transparentV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.height.mas_equalTo(image.size.height / mainScale);
        make.width.mas_equalTo(image.size.width / mainScale);
    }];
    self.transparentV = transparentV;
    
}

/**
 *  创建前景图片
 */
- (void)setupForeImage:(UIImage *)image {
    // 创建UIImageView
    UIImageView * bottomImageView = [[UIImageView alloc] init];
    // 将控件添加到屏幕上
    [self.view addSubview:bottomImageView];
    // 创建约束（约束必须要在添加之后）
    [bottomImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.height.mas_equalTo(image.size.height * 0.5 / mainScale);
        make.width.mas_equalTo(image.size.width / mainScale);
    }];
    
    // 设置锚点将图像向下偏移
    bottomImageView.layer.anchorPoint = CGPointMake(0.5, 0);
    // contentsRect：设置图片显示尺寸，值为0~1
    bottomImageView.layer.contentsRect = CGRectMake(0, 0.5, 1, 0.5);
    bottomImageView.image = image;
    self.bottomImageView = bottomImageView;
    
    
    // 创建UIImageView
    UIImageView * topImageView = [[UIImageView alloc] init];
    // 将控件添加到屏幕上
    [self.view addSubview:topImageView];
    // 创建约束（约束必须要在添加之后）
    [topImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.height.mas_equalTo(image.size.height * 0.5 / mainScale);
        make.width.mas_equalTo(image.size.width / mainScale);
    }];
    // 设置锚点，将图像向上偏移
    topImageView.layer.anchorPoint = CGPointMake(0.5, 1);
    // contentsRect：设置图片显示尺寸，值为0~1
    topImageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.5);
    topImageView.image = image;
    self.topImageView = topImageView;

}

/**
 *  创建渐变图层
 */
- (void)setupGradientLayer:(UIImage *)image {
    // 渐变图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    // 注意图层需要设置尺寸
    gradientLayer.frame = CGRectMake(0, 0, image.size.width / mainScale, image.size.height * 0.5 / mainScale);
    // 设置图层透明度
    gradientLayer.opacity = 0;
    // 设置图层颜色，（id）[UIColor clearColor].CGColor，是将颜色包装成对象
    gradientLayer.colors = @[(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor];
    // 将渐变图层添加到下半部分UIImageView
    [self.bottomImageView.layer addSublayer:gradientLayer];
    self.gradientLayer = gradientLayer;

}

// 添加手势
- (void)setupPan {
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.transparentV addGestureRecognizer:pan];
}

#pragma mark - 手势
- (void)pan:(UIPanGestureRecognizer *)gesture {
    // 获取偏移量
    CGPoint point = [gesture translationInView:self.transparentV];
    CGFloat offsetY = self.transparentV.bounds.size.height * 0.5;
    // 往下逆时针旋转
    CGFloat angle = - point.y / offsetY * M_PI;
    
    // 先设置旋转效果为空
    CATransform3D transfrom = CATransform3DIdentity;
    
    // 增加旋转的立体感，近大远小,d：距离图层的距离，需要设置在旋转效果之前
    transfrom.m34 = -1 / 500.0;
    // 设置渐变颜色透明度
    self.gradientLayer.opacity = point.y * 1.0 / offsetY;
    
    transfrom = CATransform3DRotate(transfrom, angle, 1, 0, 0);
    
    self.topImageView.layer.transform = transfrom;
    // 拖动结束的时候进行操作
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        // 添加弹簧动画效果
        // usingSpringWithDamping:弹簧效果系数
        [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // 将3D旋转效果归零
            self.topImageView.layer.transform = CATransform3DIdentity;
        } completion:nil];
    }
}
@end
