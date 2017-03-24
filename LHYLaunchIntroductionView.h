//
//  LHYGuideView.h
//  Curato
//
//  Created by YueHui on 2017/3/21.
//  Copyright © 2017年 GZ Leihou Software Development CO.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LHYLaunchIntroductionConfigurationBlock)(UIButton *enterButton);

@interface LHYLaunchIntroductionView : UIView

/**
 *  不带按钮的引导页，滑动到最后一页，再向右滑直接隐藏引导页
 *
 *  @param imageNames 背景图片数组
 *
 */
+ (void)launchIntroductionViewWithImageNames:(NSArray *)imageNames pageBottomSapcing:(CGFloat)bottomSapcing;

/**
 *  带按钮的引导页
 *
 *  @param images        背景图片数组
 *  @param configuration 按钮配置(样式，frame, title)
 */
+ (void)launchIntroductionViewWithImageNames:(NSArray *)imageNames pageBottomSapcing:(CGFloat)bottomSapcing buttonConfiguration:(LHYLaunchIntroductionConfigurationBlock)configuration;


@end
