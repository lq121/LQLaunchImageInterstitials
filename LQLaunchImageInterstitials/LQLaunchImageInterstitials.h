//
//  LQLaunchImageInterstitials.h
//  启动广告
//
//  Created by v大夫 on 16/7/19.
//  Copyright © 2016年 LQ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LQTopLogoType = 0,
    LQBottomLogoType = 1,
    LQFullScreenType = 2
} LQLaunchImageType;


@interface LQLaunchImageInterstitials : UIView

/**
 *  单例创建
 */
+(instancetype)sharImageInterstitials;


/**
 *  创建一个启动时广告View
 *
 *  @param url    广告图片url
 *  @param window window
 *  @param time   定时器的时间
 *  @param type   展示的方式（全屏、logo在上部分、logo在下部分）
 *  @param block  点击跳过或者时间完后的回调
 */
- (void)imageinterstitialsWithImageURL:(NSURL *)url andWindow:(UIWindow*)window andTime:(NSInteger)time andType:(LQLaunchImageType)type andBlock:(void (^)())block;
@end
