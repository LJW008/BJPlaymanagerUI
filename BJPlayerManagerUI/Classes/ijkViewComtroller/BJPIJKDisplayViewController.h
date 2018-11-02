//
//  BJPIJKDisplayViewController.h
//  BJPlayerManagerUI
//
//  Created by 凡义 on 2018/1/2.
//

#import <UIKit/UIKit.h>
#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import "BJPUViewControllerProtocol.h"
#import "BJPUProgressView.h"
#import "BJPUSliderView.h"

@interface BJPIJKDisplayViewController : UIViewController <BJPUSliderProtocol>

@property (nonatomic, weak) id<BJPUViewControllerProtocol> delegate;

@property (nonatomic, strong) BJPlayerManager *ijkPlayerManager;

//用于控制界面上的view无操作几秒后消失
@property (strong, nonatomic) NSTimer *hiddenTimer;

@property (assign, nonatomic) BOOL stopUpdateProgress;

//view上滑动更新亮度和声音
@property (strong, nonatomic) BJPUSliderView *sliderView;

@property (copy, nonatomic) void(^rePlayBlock)(void);

//播放的是本地视频还是在线视频
@property (assign, nonatomic) BOOL isLocalVideo;

- (instancetype)initWithPlayerManager:(BJPlayerManager *)playerManager;

- (void)updatePlayState:(PMPlayState)state;

- (void)updateCurrentPlayDuration:(long)curr playableDuration:(long)playable totalDuration:(long)total;

#pragma mark - action
- (void)playAction:(UIButton *)button;

- (void)pauseAction:(UIButton *)button;

- (void)sliderChanged:(BJPUVideoSlider *)slider;

- (void)dragSlider:(BJPUVideoSlider *)slider;

@end
