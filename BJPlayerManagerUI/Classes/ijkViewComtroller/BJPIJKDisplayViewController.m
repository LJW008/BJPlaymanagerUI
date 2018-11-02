//
//  BJPIJKDisplayViewController.m
//  BJPlayerManagerUI
//
//  Created by 凡义 on 2018/1/2.
//

#import "BJPIJKDisplayViewController.h"
#import <BJLiveBase/BJLAFNetworkReachabilityManager.h>

@interface BJPIJKDisplayViewController ()


@end

@implementation BJPIJKDisplayViewController

- (instancetype)initWithPlayerManager:(BJPlayerManager *)playerManager
{
    self = [super init];
    if (self) {
        _ijkPlayerManager = playerManager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public
- (void)updatePlayState:(PMPlayState)state {
    NSAssert(0, @"Method should be cover in subclass");
}

- (void)updateCurrentPlayDuration:(long)curr playableDuration:(long)playable totalDuration:(long)total {
    NSAssert(0, @"Method should be cover in subclass");
}

#pragma mark - action
- (void)playAction:(UIButton *)button {
    [_ijkPlayerManager play];
}

- (void)pauseAction:(UIButton *)button {
    [_ijkPlayerManager pause];
}

//拖动进度条的过阵中,slider的值会不停的变化,这个适合就不要更新进度条了
- (void)sliderChanged:(BJPUVideoSlider *)slider {
    self.stopUpdateProgress = true;
}

//拖动进度条操作结束之后,就可以更新了
- (void)dragSlider:(BJPUVideoSlider *)slider {

    BJLAFNetworkReachabilityStatus status = [BJLAFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (BJLAFNetworkReachabilityStatusNotReachable == status && !self.isLocalVideo) {
        self.stopUpdateProgress = false;
        slider.value = self.ijkPlayerManager.currentTime;
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(BJLAFNetworkReachabilityStatusNotReachable == status && !self.isLocalVideo) {
                self.stopUpdateProgress = false;
                slider.value = self.ijkPlayerManager.currentTime;
            }
            else {
                [self.ijkPlayerManager seek:slider.value];
                self.stopUpdateProgress = false;
            }
        });
    }
}

#pragma mark - BJPUSliderProtocol
- (CGFloat)originValueForTouchSlideView:(BJPUSliderView *)touchSlideView
{
    return self.ijkPlayerManager.currentTime;
}

- (CGFloat)durationValueForTouchSlideView:(BJPUSliderView *)touchSlideView
{
    return self.ijkPlayerManager.duration;
}

- (void)touchSlideView:(BJPUSliderView *)touchSlideView finishHorizonalSlide:(CGFloat)value
{
    
    BJLAFNetworkReachabilityStatus status = [BJLAFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (BJLAFNetworkReachabilityStatusNotReachable == status  && !self.isLocalVideo) {
        
    }
    else {
        [self.ijkPlayerManager seek:value];
    }
}

#pragma mark - set get
- (BJPUSliderView *)sliderView
{
    if (!_sliderView) {
        _sliderView = [[BJPUSliderView alloc] init];
        _sliderView.delegate = self;
    }
    return _sliderView;
}

@end
