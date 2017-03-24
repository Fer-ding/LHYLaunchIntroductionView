//
//  LHYGuideView.m
//  Curato
//
//  Created by YueHui on 2017/3/21.
//  Copyright © 2017年 GZ Leihou Software Development CO.LTD. All rights reserved.
//

#import "LHYLaunchIntroductionView.h"

typedef NS_ENUM(NSInteger, LHYLaunchIntroductionType) {
    LHYLaunchIntroductionTypeNone, //没有按钮模式
    LHYLaunchIntroductionTypeButton//按钮模式
};

static NSString *const kAppVersion = @"appVersion";

#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth   [[UIScreen mainScreen] bounds].size.width


@interface LHYLaunchIntroductionView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *launchScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIButton *enterButton;

@property (nonatomic, assign) LHYLaunchIntroductionType launchIntroductionType;
@property (nonatomic, assign) CGFloat bottomSapcing;

@end

@implementation LHYLaunchIntroductionView



#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
                       images:(NSArray *)images
       launchIntroductionType:(LHYLaunchIntroductionType)launchIntroductionType
            pageBottomSapcing:(CGFloat)bottomSapcing {
    
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.images = images;
    self.enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.launchIntroductionType = launchIntroductionType;
    self.bottomSapcing = bottomSapcing;
    
    [self createScrollView];
    
    return self;
}


#pragma mark - public method

+ (void)launchIntroductionViewWithImageNames:(NSArray *)imageNames pageBottomSapcing:(CGFloat)bottomSapcing {
    
    [LHYLaunchIntroductionView launchIntroductionViewWithImageNames:imageNames pageBottomSapcing:bottomSapcing launchIntroductionType:LHYLaunchIntroductionTypeNone buttonConfiguration:nil];
}

+ (void)launchIntroductionViewWithImageNames:(NSArray *)imageNames pageBottomSapcing:(CGFloat)bottomSapcing buttonConfiguration:(LHYLaunchIntroductionConfigurationBlock)configuration {
    
    [LHYLaunchIntroductionView launchIntroductionViewWithImageNames:imageNames pageBottomSapcing:bottomSapcing launchIntroductionType:LHYLaunchIntroductionTypeButton buttonConfiguration:configuration];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger currentIndex = (_launchScrollView.contentOffset.x + _launchScrollView.bounds.size.width * 0.5) / _launchScrollView.bounds.size.width;
    _pageControl.currentPage = currentIndex;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    NSInteger currentIndex = (_launchScrollView.contentOffset.x + _launchScrollView.bounds.size.width * 0.5) / _launchScrollView.bounds.size.width;
    if (currentIndex == self.images.count - 1) {
        if ([self isScrolltoLeft:scrollView]) {
            if (self.launchIntroductionType == LHYLaunchIntroductionTypeButton) {
                return ;
            }
            [self hideGuidView];
        }
    }
}

#pragma mark - private Method

#pragma mark - 初始化界面
+ (void)launchIntroductionViewWithImageNames:(NSArray *)imageNames
                           pageBottomSapcing:(CGFloat)bottomSapcing
                      launchIntroductionType:(LHYLaunchIntroductionType)launchIntroductionType
                         buttonConfiguration:(LHYLaunchIntroductionConfigurationBlock)configuration {
    
    LHYLaunchIntroductionView *launch = [[LHYLaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) images:imageNames launchIntroductionType:launchIntroductionType pageBottomSapcing:bottomSapcing];
    launch.backgroundColor = [UIColor whiteColor];
    if (configuration) {
        configuration(launch.enterButton);
    }
    
    [LHYLaunchIntroductionView addToWindowWithLaunch:launch];
}

#pragma mark - 判断是不是首次登录或者版本更新
+ (BOOL)isFirstLaunch {
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentAppVersion = infoDic[@"CFBundleShortVersionString"];
    //获取上次启动应用保存的appVersion
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppVersion];
    //版本升级或首次登录
    if (version == nil || ![version isEqualToString:currentAppVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:kAppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 添加视图到窗体
+ (void)addToWindowWithLaunch:(LHYLaunchIntroductionView *)launch {
//    if ([LHYLaunchIntroductionView isFirstLaunch]) {
        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
        [window addSubview:launch];
//    }
}

#pragma mark - 创建滚动视图
- (void)createScrollView {
    
    _launchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _launchScrollView.showsHorizontalScrollIndicator = NO;
    _launchScrollView.bounces = NO;
    _launchScrollView.pagingEnabled = YES;
    _launchScrollView.delegate = self;
    _launchScrollView.contentSize = CGSizeMake(kScreenWidth * _images.count, kScreenHeight);
    [self addSubview:_launchScrollView];
    
    for (int i = 0; i < _images.count; i ++) {
        CGFloat guideX = kScreenWidth * i;
        CGFloat guideY = 0;
        CGFloat guideW = kScreenWidth;
        CGFloat guideH = kScreenHeight;
        UIImageView *guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(guideX, guideY, guideW, guideH)];
        guideImageView.image = [UIImage imageNamed:_images[i]];
        [_launchScrollView addSubview:guideImageView];
        if (i == _images.count - 1) {
            //判断要不要添加button
            if (self.launchIntroductionType == LHYLaunchIntroductionTypeButton) {
                [_enterButton addTarget:self action:@selector(enterBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                [guideImageView addSubview:_enterButton];
                guideImageView.userInteractionEnabled = YES;
            }
        }
    }
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreenHeight - 30 - self.bottomSapcing, kScreenWidth, 30)];
    _pageControl.numberOfPages = _images.count;
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.currentPage = 0;
    _pageControl.defersCurrentPageDisplay = YES;
    [self addSubview:_pageControl];
}

#pragma mark - 进入按钮
- (void)enterBtnClicked {
    [self hideGuidView];
}

#pragma mark - 隐藏引导页
- (void)hideGuidView {
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
        
    }];
}

#pragma mark - 判断滚动方向
- (BOOL)isScrolltoLeft:(UIScrollView *) scrollView {
    //返回YES为向左反动，NO为右滚动
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        return YES;
    } else {
        return NO;
    }
}


@end
