//
//  PMBigViewController.m
//  Pods
//
//  Created by DLM on 2016/11/7.
//
//

#import "BJPUFullViewController.h"
#import "BJPUProgressView.h"
#import "BJPUSliderView.h"
#import "BJPUDefinitionView.h"
#import "BJPULessonListView.h"
#import "BJPURateView.h"
#import "BJPUFullRightView.h"
#import "BJPUTheme.h"
#import "BJPUAppearance.h"

@interface BJPUFullViewController () <BJPULessonListViewProtocol, BJPUDefinitionViewProtocol, BJPURateViewProtocol>
//View
@property (strong, nonatomic) UIView *topBarView;
@property (strong, nonatomic) UIButton *lockButton;
@property (strong, nonatomic, readwrite) BJPUFullBottomView *bottomBarView;
@property (strong, nonatomic) BJPUFullRightView *rightView;
@property (strong, nonatomic) UIButton *scaleButton;

@property (strong, nonatomic) BJPUDefinitionView *definitionView;
@property (strong, nonatomic) BJPULessonListView *lessonListView;
@property (strong, nonatomic) BJPURateView *rateView;

//锁屏时, sliderView隐藏, 手势加在hudView上
@property (strong, nonatomic) UIView *hudView;

@end

@implementation BJPUFullViewController

- (void)dealloc
{
    [self.lockButton removeObserver:self forKeyPath:@"hidden"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self setupSubviews];
    [self restartHiddenTimer];
    [self registeAction];
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

- (void)setupSubviews {
    [self.view addSubview:self.hudView];
    [self.view addSubview:self.sliderView];
    [self.view addSubview:self.topBarView];
    [self.view addSubview:self.bottomBarView];
    [self.view addSubview:self.lockButton];
    [self.view addSubview:self.rightView];
    [self.topBarView addSubview:self.scaleButton];
    
    [self.view addSubview:self.rateView];
    [self.view addSubview:self.lessonListView];
    [self.view addSubview:self.definitionView];

    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.offset(0);
        make.height.mas_equalTo(40.f).priorityHigh();
    }];
    [self.bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.offset(0);
        make.height.mas_equalTo(40.f).priorityHigh();
    }];
    [self.lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(20);
        make.centerY.offset(0.f);
    }];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(10.f);
        make.centerY.offset(0.f);
        make.width.mas_equalTo(80.f);
        make.height.mas_equalTo(160.f);
    }];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.offset(0);
        make.top.equalTo(self.topBarView.mas_bottom);
        make.bottom.equalTo(self.bottomBarView.mas_top);
    }];

    [self.hudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.offset(0);
        make.top.equalTo(self.topBarView.mas_bottom);
        make.bottom.equalTo(self.bottomBarView.mas_top);
    }];
    
    [self.scaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(15.f);
        make.centerY.offset(0);
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
    [self.rateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.offset(0.f);
        make.width.mas_equalTo(120);
    }];
    [self.definitionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.offset(0.f);
        make.width.mas_equalTo(120);
    }];
    [self.lessonListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.offset(0.f);
        make.width.mas_equalTo(200.f);
    }];
}

- (void)registeAction
{
    [self.bottomBarView.playButton addTarget:self action:@selector(playAction:)
                            forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView.pauseButton addTarget:self action:@selector(pauseAction:)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView.nextVideoButton addTarget:self action:@selector(playNextVideoAction:)
                                 forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView.progressView.slider addTarget:self action:@selector(sliderChanged:)
                                     forControlEvents:UIControlEventValueChanged];
    [self.bottomBarView.progressView.slider addTarget:self action:@selector(dragSlider:)
                                     forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView.progressView.slider addTarget:self action:@selector(dragSlider:)
                                     forControlEvents:UIControlEventTouchUpOutside];
    [self.bottomBarView.progressView.slider addTarget:self action:@selector(dragSlider:)
                                     forControlEvents:UIControlEventTouchCancel];
    [self.rightView.rateButton addTarget:self action:@selector(showRateViewAction:)
                        forControlEvents:UIControlEventTouchUpInside];
//    [self.rightView.lessonButton addTarget:self action:@selector(showLessonListViewAction:)
//                          forControlEvents:UIControlEventTouchUpInside];
    [self.rightView.definitionButton addTarget:self action:@selector(showDefinitionViewAction:)
                              forControlEvents:UIControlEventTouchUpInside];
    
    [self.lockButton addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapView:)];
    [self.sliderView addGestureRecognizer:tap];

    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapView:)];
    [self.hudView addGestureRecognizer:tap2];
}

#pragma mark - public
- (void)updateCurrentPlayDuration:(long)curr playableDuration:(long)playable totalDuration:(long)total
{
    if (!self.stopUpdateProgress) {
        [self.bottomBarView.progressView setValue:curr cache:playable duration:total];
    }
    self.bottomBarView.relTimeLabel.text = [NSString stringFromTimeInterval:curr totalTimeInterval:total];
    self.bottomBarView.durationLabel.text = [NSString stringFromTimeInterval:total];
}

- (void)updatePlayState:(PMPlayState)state
{
    if (PMPlayStatePaused == state || PMPlayStateStopped == state) {
        self.bottomBarView.playButton.hidden = false;
        self.bottomBarView.pauseButton.hidden = true;
    } else if (PMPlayStatePlaying == state) {
        self.bottomBarView.playButton.hidden = true;
        self.bottomBarView.pauseButton.hidden = false;
        PMVideoDefinitionInfoModel *definitionModel = self.playerManager.currDefinitionInfoModel;
        [self.rightView.definitionButton setTitle:definitionModel.definition forState:UIControlStateNormal];
    }
}

#pragma mark - hidden control view
- (void)restartHiddenTimer
{
    [self.hiddenTimer invalidate];
    self.hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self
                                                      selector:@selector(hiddenControlView)
                                                      userInfo:nil repeats:false];
}

- (void)hiddenControlViewByLockScreen
{
    __weak typeof(self) weakSelf = self;
    if ([self isLocked]) { //当前是锁屏，则只显示加锁按钮
        self.lockButton.hidden = false;
        [UIView animateWithDuration:0.5 animations:^{
            __strong typeof(weakSelf) self = weakSelf;
            self.topBarView.alpha = 0;
            self.bottomBarView.alpha = 0;
            self.rightView.alpha = 0;

            self.sliderView.hidden = true;
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf) self = weakSelf;
            self.topBarView.alpha = 1;
            self.bottomBarView.alpha = 1;
            self.rightView.alpha = 1;
            
            self.topBarView.hidden = true;
            self.bottomBarView.hidden = true;
            self.rightView.hidden = true;
        }];
    } else { //没锁屏，全部显示
        
        PMVideoDefinitionInfoModel *definitionModel = self.playerManager.currDefinitionInfoModel;
        [self.rightView.definitionButton setTitle:definitionModel.definition forState:UIControlStateNormal];
        
        self.lockButton.hidden = false;
        self.topBarView.hidden = false;
        self.bottomBarView.hidden = false;
        self.rightView.hidden = false;
        self.sliderView.hidden = false;
    }
}

- (void)hiddenControlView
{
    [self.hiddenTimer invalidate];
    self.hiddenTimer = nil;

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.0 animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.lockButton.alpha = 0;
        self.topBarView.alpha = 0;
        self.bottomBarView.alpha = 0;
        self.rightView.alpha = 0;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        self.lockButton.alpha = 1;
        self.topBarView.alpha = 1;
        self.bottomBarView.alpha = 1;
        self.rightView.alpha = 1;
        
        self.lockButton.hidden = true;
        self.topBarView.hidden = true;
        self.bottomBarView.hidden = true;
        self.rightView.hidden = true;
    }];
}

#pragma mark - action
- (void)showRateViewAction:(UIButton *)button
{
    self.rateView.rate = self.playerManager.playRate;
    
    [self hiddenControlView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rateView.hidden = false;
    });
}

- (void)showDefinitionViewAction:(UIButton *)button
{
    NSArray *definitionList = self.playerManager.videoInfoModel.definitionList;
    PMVideoDefinitionInfoModel *definitionModel = self.playerManager.currDefinitionInfoModel;
    [self.definitionView resetDefinitionList:definitionList currentDefinition:definitionModel];
    
    [self hiddenControlView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.definitionView.hidden = false;
    });
}

- (void)scaleSmallScreenAction
{
    [self.delegate changeScreenType:BJPUScreenType_Small];
}

- (void)changeLockScreenAction:(UIButton*)button
{
    button.selected = !button.selected;
    [self hiddenControlViewByLockScreen];
    [self restartHiddenTimer];
}

- (void)playNextVideoAction:(UIButton *)button
{
    //[self.playerManager next]
}

- (void)singleTapView:(UITapGestureRecognizer *)tap {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.0f animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.rateView.alpha = 0;
        self.lessonListView.alpha = 0;
        self.definitionView.alpha = 0;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        self.rateView.hidden = true;
        self.lessonListView.hidden = true;
        self.definitionView.hidden = true;
        
        self.rateView.alpha = 1;
        self.lessonListView.alpha = 1;
        self.definitionView.alpha = 1;
    }];
    self.lockButton.hidden = !self.lockButton.hidden;
    if (![self isLocked]) {
        
        PMVideoDefinitionInfoModel *definitionModel = self.playerManager.currDefinitionInfoModel;
        [self.rightView.definitionButton setTitle:definitionModel.definition forState:UIControlStateNormal];
        
        self.topBarView.hidden = self.lockButton.hidden;
        self.bottomBarView.hidden = self.lockButton.hidden;
        self.rightView.hidden = self.lockButton.hidden;

        self.sliderView.hidden = self.isLocked;
    }
}

- (void)dragSlider:(BJPUVideoSlider *)slider
{
    [self.playerManager seek:slider.value];
    self.bottomBarView.relTimeLabel.text = [NSString stringFromTimeInterval:self.playerManager.currentTime totalTimeInterval:self.playerManager.duration];
    self.stopUpdateProgress = false;
}

#pragma mark kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([object isEqual:self.lockButton] && [@"hidden" isEqualToString:keyPath]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == false) {
            [self restartHiddenTimer];
        }
    }
}

#pragma mark - delegate
#pragma mark BJPURateViewProtocol
- (void)rateView:(BJPURateView *)rateView changeRate:(CGFloat)rate
{
    [self.playerManager changeRate:rate];
}

#pragma mark BJPUDefinitionViewProtocol
- (void)definitionView:(BJPUDefinitionView *)definitionView selectDefinition:(PMVideoDefinitionInfoModel *)definition
{
    if(self.playerManager.currDefinitionInfoModel.definitionType == definition.definitionType) {
        return;
    }

    [self.playerManager changeDefinition:definition.definitionType];
}

#pragma mark BJPULessonListViewProtocol
- (void)lessonListView:(BJPULessonListView *)lessonListView selectLesson:(PMVideoSectionModel *)lessonModel
{
    //[self.playerManager ];
}

#pragma mark - set get
- (BOOL)isLocked
{
    return self.lockButton.isSelected;
}

- (UIView *)topBarView
{
    if (!_topBarView) {
        _topBarView = [[UIView alloc] init];
        _topBarView.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.4];
    }
    return _topBarView;
}

- (UIView *)hudView {
    if (!_hudView) {
        _hudView = [UIView new];
        _hudView.backgroundColor = [UIColor clearColor];
    }
    return _hudView;
}

- (UIButton *)lockButton
{
    if (!_lockButton) {
        _lockButton = [[UIButton alloc] init];
        [_lockButton setImage:[UIImage bjpu_imageNamed:@"ic_lock"] forState:UIControlStateNormal];
        [_lockButton setImage:[UIImage bjpu_imageNamed:@"ic_unlock"] forState:UIControlStateSelected];
        [_lockButton addTarget:self action:@selector(changeLockScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lockButton;
}

- (BJPUFullBottomView *)bottomBarView
{
    if (!_bottomBarView) {
        _bottomBarView = [[BJPUFullBottomView alloc] init];
        _bottomBarView.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.4f];
    }
    return _bottomBarView;
}

- (BJPUFullRightView *)rightView
{
    if (!_rightView)
    {
        _rightView = [[BJPUFullRightView alloc] init];
        _rightView.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.6f];
    }
    return _rightView;
}

- (UIButton *)scaleButton
{
    if (!_scaleButton) {
        _scaleButton = [[UIButton alloc] init];
        [_scaleButton setImage:[BJPUTheme backButtonImage] forState:UIControlStateNormal];
        [_scaleButton setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
        [_scaleButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_scaleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        [_scaleButton addTarget:self action:@selector(scaleSmallScreenAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scaleButton;
}

- (BJPURateView *)rateView
{
    if (!_rateView) {
        _rateView = [[BJPURateView alloc] init];
        _rateView.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.6f];
        _rateView.delegate = self;
        _rateView.hidden = YES;
    }
    return _rateView;
}

- (BJPUDefinitionView *)definitionView
{
    if (!_definitionView) {
        _definitionView = [[BJPUDefinitionView alloc] init];
        _definitionView.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.6f];
        _definitionView.delegate = self;
        _definitionView.hidden = YES;
    }
    return _definitionView;
}

- (BJPULessonListView *)lessonListView
{
    if (!_lessonListView) {
        _lessonListView = [[BJPULessonListView alloc] init];
        _lessonListView.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.6f];
        _lessonListView.delegate = self;
        _lessonListView.hidden = YES;
    }
    return _lessonListView;
}
@end
