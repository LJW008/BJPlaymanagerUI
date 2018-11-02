//
//  BJPUSmallViewController.m
//  Pods
//
//  Created by DLM on 2016/11/7.
//
//

#import "BJPUSmallViewController.h"
#import "BJPUProgressView.h"
#import "BJPUSliderView.h"
#import "BJPUAppearance.h"
#import "BJPUTheme.h"
//#import <BJPlayerManagerCore/BJPlayerManagerCore.h>

@interface BJPUSmallViewController () <UIGestureRecognizerDelegate>
//view
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *scaleButton;
@property (strong, nonatomic) UILabel *relTimeLabel;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic, readwrite) BJPUProgressView *progressView;

@end

@implementation BJPUSmallViewController
- (void)dealloc
{
    [self.bottomView removeObserver:self forKeyPath:@"hidden"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self setupSubViews];
    [self.bottomView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.hiddenTimer invalidate];
    self.hiddenTimer = nil;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //主要是更新进度条的时间
    [self updateCurrentPlayDuration:self.playerManager.currentTime playableDuration:self.playerManager.cacheDuration totalDuration:self.playerManager.duration];
}

- (void)setupSubViews
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.sliderView];
    [self.view addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.playButton];
    [self.bottomView addSubview:self.pauseButton];
    [self.bottomView addSubview:self.progressView];
    [self.bottomView addSubview:self.scaleButton];
    [self.bottomView addSubview:self.relTimeLabel];
    [self.bottomView addSubview:self.durationLabel];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.offset(0.f);
        make.height.mas_equalTo(40.f).priorityHigh();
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(10.f);
        make.centerY.offset(0.f);
        make.width.height.mas_equalTo(30.f);
    }];
    [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playButton);
    }];
    [self.scaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-10.f);
        make.centerY.offset(0.f);
        make.width.height.mas_equalTo(30.f);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.playButton.mas_trailing).offset(10.f);
        make.trailing.equalTo(self.scaleButton.mas_leading).offset(-10.f);
        make.top.offset(15.f);
        make.height.mas_equalTo(10.f);
    }];
    [self.relTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-5.f);
        make.trailing.equalTo(self.durationLabel.mas_leading);
    }];
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.relTimeLabel);
        make.trailing.equalTo(self.scaleButton.mas_leading).offset(-20);
    }];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
//    [self.bottomView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapView:)];
    tap.delegate = self;
    [self.sliderView addGestureRecognizer:tap];
}

- (void)restartHiddenTimer
{
    [self.hiddenTimer invalidate];
    self.hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self
                                                      selector:@selector(hiddenBottomViewAction)
                                                      userInfo:nil repeats:false];
}

#pragma mark - public
- (void)updateCurrentPlayDuration:(long)curr playableDuration:(long)playable totalDuration:(long)total
{
    if (!self.stopUpdateProgress) {
        [self.progressView setValue:curr cache:playable duration:total];
    }
    self.relTimeLabel.text = [NSString stringFromTimeInterval:curr totalTimeInterval:total];
    self.durationLabel.text = [NSString stringWithFormat:@" / %@", [NSString stringFromTimeInterval:total]];
}

- (void)updatePlayState:(PMPlayState)state
{
    if (PMPlayStatePaused == state || PMPlayStateStopped == state) {
        self.playButton.hidden = false;
        self.pauseButton.hidden = true;
    } else if (PMPlayStatePlaying == state) {
        self.playButton.hidden = true;
        self.pauseButton.hidden = false;
    }
}

#pragma mark - action
- (void)hiddenBottomViewAction
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:1 animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.bottomView.alpha = 0.f;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        self.bottomView.hidden = true;
        self.bottomView.alpha = 1.f;
        
    }];
    [self.hiddenTimer invalidate];
    self.hiddenTimer = nil;
}

- (void)scaleFullScreenAction:(UIButton *)button
{
    [self.delegate changeScreenType:BJPUScreenType_Full];
}

- (void)singleTapView:(UITapGestureRecognizer *)tap
{
    if (self.bottomView.hidden) {
        self.bottomView.hidden = false;
    } else {
        [self hiddenBottomViewAction];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([object isEqual:self.bottomView] && [keyPath isEqualToString:@"hidden"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == false) {
            [self restartHiddenTimer];
        }
    }
}

- (void)dragSlider:(BJPUVideoSlider *)slider
{
    [self.playerManager seek:slider.value];
    self.relTimeLabel.text = [NSString stringFromTimeInterval:self.playerManager.currentTime totalTimeInterval:self.playerManager.duration];
    self.stopUpdateProgress = false;
}

#pragma mark - UIGestureRecognizerDelegate

#pragma mark - set get
- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.4];
    }
    return _bottomView;
}

- (BJPUProgressView *)progressView
{
    if (!_progressView) {
//        _progressView = [[BJPUProgressView alloc] initWithFrame:CGRectMake(100, 15, 50, 10)];
        _progressView = [[BJPUProgressView alloc] init];
        [_progressView.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressView.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchUpInside];
        [_progressView.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchUpOutside];
        [_progressView.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchCancel];
    }
    return _progressView;
}

- (UIButton *)playButton
{
    if (!_playButton)
    {
        _playButton = [UIButton new];
        [_playButton setImage:[BJPUTheme playButtonImage] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}
- (UIButton *)pauseButton
{
    if (!_pauseButton)
    {
        _pauseButton = [UIButton new];
        _pauseButton.hidden = YES;
        [_pauseButton setImage:[BJPUTheme pauseButtonImage] forState:UIControlStateNormal];
        [_pauseButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseButton;
}

- (UIButton *)scaleButton
{
    if (!_scaleButton) {
        _scaleButton = [[UIButton alloc] init];
        [_scaleButton setImage:[BJPUTheme scaleButtonImage] forState:UIControlStateNormal];
        [_scaleButton addTarget:self action:@selector(scaleFullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scaleButton;
}
- (UILabel *)relTimeLabel
{
    if (!_relTimeLabel)
    {
        _relTimeLabel = [UILabel new];
        _relTimeLabel.textColor = [BJPUTheme defaultTextColor];
        _relTimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _relTimeLabel;
}
- (UILabel *)durationLabel
{
    if (!_durationLabel) {
        _durationLabel = [UILabel new];
        _durationLabel.textColor = [BJPUTheme defaultTextColor];
        _durationLabel.font = [UIFont systemFontOfSize:10];
    }
    return _durationLabel;
}
@end
