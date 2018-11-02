//
//  BJPUDisplayViewController.m
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import "BJPUDisplayViewController.h"
#import "BJPUTheme.h"

@interface BJPUDisplayViewController ()

@end

@implementation BJPUDisplayViewController

- (instancetype)initWithPlayerManager:(BJPlayerManager *)playerManager
{
    self = [super init];
    if (self) {
        _playerManager = playerManager;
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

#pragma mark - should be cover
- (void)updatePlayState:(PMPlayState)state
{
    NSAssert(0, @"Method should be cover in subclass");
}

- (void)updateCurrentPlayDuration:(long)curr playableDuration:(long)playable totalDuration:(long)total
{
    NSAssert(0, @"Method should be cover in subclass");
}

#pragma mark - action
- (void)playAction:(UIButton *)button
{
//    if (_playerManager.playState == PMPlayStateStopped) {
//        if (self.rePlayBlock) {
//            self.rePlayBlock();
//        }
//    }
//    else if (_playerManager.playState == PMPlayStatePaused){
//        [_playerManager play];
//    }
    [_playerManager play];
}

- (void)pauseAction:(UIButton *)button
{
    [_playerManager pause];
}

- (void)sliderChanged:(BJPUVideoSlider *)slider
{
    self.stopUpdateProgress = true;
    [self restartHiddenTimer];
}

- (void)dragSlider:(BJPUVideoSlider *)slider
{
    [_playerManager seek:slider.value];
    self.stopUpdateProgress = false;

    [self.hiddenTimer invalidate];
    self.hiddenTimer = nil;
}

- (void)displayOrHiddenControlAction
{
    NSAssert(0, @"Method should be cover in subclass");
}

- (void)restartHiddenTimer {
    NSAssert(0, @"Method should be cover in subclass");
}

#pragma mark - BJPUSliderProtocol
- (CGFloat)originValueForTouchSlideView:(BJPUSliderView *)touchSlideView
{
    return _playerManager.currentTime;
}

- (CGFloat)durationValueForTouchSlideView:(BJPUSliderView *)touchSlideView
{
    return _playerManager.duration;
}

- (void)touchSlideView:(BJPUSliderView *)touchSlideView finishHorizonalSlide:(CGFloat)value
{
    [_playerManager seek:value];
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
