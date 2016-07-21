//
//  LQLaunchImageInterstitials.m
//  启动广告
//
//  Created by v大夫 on 16/7/19.
//  Copyright © 2016年 LQ. All rights reserved.
//

#import "LQLaunchImageInterstitials.h"
#import "UIImageView+WebCache.h"

#ifdef DEBUG
#define LQLog(fmt,...) NSLog(fmt,##__VA_ARGS__)
#else
#define LQLog(...)
#endif

#define UIScreenWidth [[UIScreen mainScreen] bounds].size.width
#define UIScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface LQLaunchImageInterstitials()
@property (nonatomic, strong)NSTimer *timer;
/**
 *  跳过按钮
 */
@property (nonatomic, strong)UIButton *skipBtn;
/**
 *  显示的窗口
 */
@property (nonatomic, strong)UIWindow *window;

/**
 *  显示的图片
 */
@property (nonatomic, strong)UIImageView *posterImageView;

/**
 *  倒计时时间
 */
@property (nonatomic, assign)NSInteger seconds;
/**
 *  广告结束或者点击跳过按钮的回调
 */
@property (nonatomic, copy) void (^closeBlock)();

@end


@implementation LQLaunchImageInterstitials
/**
 *  单例创建
 */
+ (instancetype)sharImageInterstitials
{
    static LQLaunchImageInterstitials * _sharImageInterstitials = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharImageInterstitials = [[self alloc]init];
    });
    return _sharImageInterstitials;
}


/**
 *  创建一个启动时广告View
 *
 *  @param url    广告图片url
 *  @param window window
 *  @param time   定时器的时间
 *  @param type   展示的方式（全屏、logo在上部分、logo在下部分）
 *  @param block  点击跳过或者时间完后的回调
 */
- (void)imageinterstitialsWithImageURL:(NSURL *)url andWindow:(UIWindow*)window andTime:(NSInteger)time andType:(LQLaunchImageType)type andBlock:(void (^)())block
{
    self.seconds = time;
    self.closeBlock = block;
    //获取启动图片
    //横屏请设置成 @"Landscape"
    NSString *viewOrientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, [UIScreen mainScreen].bounds.size) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    
    UIImage * launchImage = [UIImage imageNamed:launchImageName];
    self.backgroundColor = [UIColor colorWithPatternImage:launchImage];
    self.frame = [UIScreen mainScreen].bounds;
    
    UIImageView *adImageView = [[UIImageView alloc]init];
    if (type == LQFullScreenType)
    {
        adImageView.frame = CGRectMake(0, 0,UIScreenWidth, UIScreenHeight);
        
    }else if(type == LQTopLogoType)
    {
        adImageView.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight - UIScreenWidth/3);
    }
    else
    {
        adImageView.frame = CGRectMake(0, UIScreenWidth/3, UIScreenWidth, UIScreenHeight - UIScreenWidth/3);
    }
    self.posterImageView = adImageView;
    [self addSubview:adImageView];
    
    /**
     *  判断缓存中是否存在图片
     */
    UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:url.absoluteString];
    if (image!= nil)
    {
        [adImageView setImage:image];
        /**
         跳过按钮
         */
        UIButton *skipBtn = [[UIButton alloc]init];
        self.skipBtn = skipBtn;
        self.skipBtn.backgroundColor = [UIColor grayColor];
        self.skipBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.skipBtn setTitle:[NSString stringWithFormat:@"%@ | 跳过",@(self.seconds)] forState:UIControlStateNormal];
        [self addSubview:self.skipBtn];
        
        /**
         *  背景图片动画（淡入淡出）
         */
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration = 0.5;
        opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [adImageView.layer addAnimation:opacityAnimation forKey:@"animateOpacity"];
        
        /**
         *  设置定时器
         */
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
        
        /**
         *  设置window的显示
         */
        self.window = window;
        [self.window makeKeyAndVisible];
        [self.window addSubview:self];

    }
    else
    {
        // 从网络中请求数据
        [adImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if (image)
             {
                 [adImageView setImage:[self imageCompressForWidth:image targetWidth:UIScreenWidth]];
                 [[SDImageCache sharedImageCache] storeImage:image forKey:url.absoluteString];
             }
             [self clipsToBounds];
         }];
    }
}

/**
 *  点击跳过按钮
 */
- (void)skipBtnClick
{
    [self.timer invalidate];
    self.timer = nil;
    [self closeAnimation];
}

/**
 *  定时器方法
 */
- (void)onTimer
{
    if (self.seconds > 1)
    {
        self.seconds--;
        [self.skipBtn setTitle:[NSString stringWithFormat:@"%@ | 跳过",@(self.seconds)] forState:UIControlStateNormal];
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
        [self closeAnimation];
    }
}

/**
 *  结束
 */
- (void)closeAnimation
{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = 0.5;
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.3];
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    [self.posterImageView.layer addAnimation:opacityAnimation forKey:@"animateOpacity"];
    self.closeBlock();
}




#pragma mark - 指定宽度按比例缩放
- (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)width
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    CGFloat targetHeight = imageHeight / (imageWidth / width);
    CGSize size = CGSizeMake(width, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = width;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO)
    {
        CGFloat widthFactor = imageWidth / width;
        CGFloat heightFactor = targetHeight / imageHeight;
        
        if(widthFactor > heightFactor)
        {
            scaleFactor = widthFactor;
        }
        else
        {
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = imageHeight * scaleFactor;
        
        if(widthFactor > heightFactor)
        {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }
        else if(widthFactor < heightFactor)
        {
            
            thumbnailPoint.x = (width - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        LQLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.skipBtn.frame = CGRectMake(UIScreenWidth - 80, 25, 70, 30);
    self.skipBtn.layer.masksToBounds = YES;
    self.skipBtn.layer.cornerRadius = 15;
}
@end
