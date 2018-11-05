//
//  BJPUDisplayViewController.h
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import <UIKit/UIKit.h>
#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import "BJPUViewControllerProtocol.h"
#import "BJPUProgressView.h"
#import "BJPUSliderView.h"

@interface BJPUDisplayViewController : UIViewController <BJPUSliderProtocol>

@property (weak, nonatomic) id<BJPUViewControllerProtocol> delegate;

@property (strong, nonatomic) BJPlayerManager *playerManager;

@property (strong, nonatomic) NSTimer *hiddenTimer;

@property (assign, nonatomic) BOOL stopUpdateProgress;

@property (strong, nonatomic) BJPUSliderView *sliderView;

@property (copy, nonatomic) void(^rePlayBlock)(void);

- (instancetype)initWithPlayerManager:(BJPlayerManager *)playerManager;

- (void)updatePlayState:(PMPlayState)state;

- (void)updateCurrentPlayDuration:(long)curr playableDuration:(long)playable totalDuration:(long)total;

#pragma mark - action
- (void)playAction:(UIButton *)button;

- (void)pauseAction:(UIButton *)button;

- (void)sliderChanged:(BJPUVideoSlider *)slider;

- (void)dragSlider:(BJPUVideoSlider *)slider;


@end
