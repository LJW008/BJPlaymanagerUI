//
//  BJPUViewController.m
//  Pods
//
//  Created by DLM on 2017/4/26.
//
//

#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import "BJPUViewController.h"
#import "BJPUMacro.h"
#import "MBProgressHUD+bjp.h"
#import "BJPUFullViewController.h"
#import "BJPUSmallViewController.h"

@interface BJPUViewController () <BJPUViewControllerProtocol, BJPMProtocol>

@property (strong, nonatomic) BJPUSmallViewController *smallVC;
@property (strong, nonatomic) BJPUFullViewController *fullVC;
@property (strong, nonatomic, readwrite) BJPlayerManager *playerManager;
@property (strong, nonatomic) UIImageView *audioOnlyImageView;

@property (assign, nonatomic) BOOL isNavigationBarHidden, isPlayingTailAD, isLocalVideo;
@property (strong, nonatomic) NSTimer *updateDurationTimer;

@property (strong, nonatomic, nullable) NSString *vid, *token;
@property (strong, nonatomic, nullable) NSString *localVideoPath;
@property (assign, nonatomic) NSInteger definitionType;

@property (assign, nonatomic) BOOL pauseByInterrupt;

@end

@implementation BJPUViewController

//获取锁屏状态
- (BOOL)isLockedNow
{
    //    NSLog(@"是否允许横竖屏%d",![self.fullVC isLocked]);
    return ![self.fullVC isLocked];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSubviews];
    
    // 自定义
    [self.fullVC setupSubviews];
    [self.view addSubview:self.fullVC.view];
    self.screenType = BJPUScreenType_Small;


    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayStateChanged:)
                                                 name:PMPlayStateChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateChanged:)
                                                 name:PKMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willPlayNormal:)
                                                 name:PMPlayerWillPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tailADWillPlay:)
                                                 name:PMPlayerTailADWilPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tailADPlayFinish:)
                                                 name:PMPlayerTailADPlayFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterChangeCDN:)
                                                 name:PMPlayerFailedAfterCDNNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.updateDurationTimer invalidate];
    self.updateDurationTimer = nil;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)sliderMayDrag:(BOOL)mayDrag {
    self.smallVC.progressView.userInteractionEnabled = mayDrag;
    self.fullVC.bottomBarView.progressView.userInteractionEnabled = mayDrag;
    
    self.smallVC.sliderView.userInteractionEnabled = mayDrag;
    self.fullVC.sliderView.userInteractionEnabled = mayDrag;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerManager.player.view];
    [self.playerManager.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

#pragma mark - process notification
- (void)deviceOrientationDidChange:(NSNotification *)noti
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if ([self.fullVC isLocked]
        && orientation != UIInterfaceOrientationLandscapeLeft
        && orientation != UIInterfaceOrientationLandscapeRight) {
        [self changeScreenType:BJPUScreenType_Full];
        return;
    }
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        PMLog(@"横屏模式");
        _isNavigationBarHidden = self.navigationController.isNavigationBarHidden;
        self.navigationController.navigationBarHidden = YES;
        self.screenType = BJPUScreenType_Full;
    }
    else if (orientation == UIInterfaceOrientationPortrait) {
        PMLog(@"竖屏模式");
        [self.navigationController setNavigationBarHidden:NO];
        self.screenType = BJPUScreenType_Small;
    }
}

- (void)playerLoadStateChanged:(NSNotification *)noti {
    PKMoviePlayerController *vc = noti.object;
    if(vc.runingPlayer == PKMovieNormalPlayer) {
        if(vc.loadState == PKMovieLoadStatePlaythroughOK) {
            [MBProgressHUD bjp_closeLoadingView:self.view];
        }
        else if (vc.loadState == PKMovieLoadStateStalled) {
            [MBProgressHUD bjp_showLoading:@"正在加载" toView:self.view];
        }
    }
    NSLog(@"BJPUViewController - loadStatusChange: %td", vc.loadState);
}

- (void)playerPlayStateChanged:(NSNotification *)noti
{
    BJPlayerManager *playerManager = (BJPlayerManager*)noti.object;
    NSLog(@"BJPUViewController - playState:%td", playerManager.playState);
    [self.smallVC updatePlayState:playerManager.playState];
    [self.fullVC updatePlayState:playerManager.playState];
    if (playerManager.playState == PMPlayStatePlaying) {
        self.audioOnlyImageView.hidden = !(playerManager.currDefinitionInfoModel.definitionType == DT_Audio);
    }
    
    if ((playerManager.playState == PMPlayStatePlaying || playerManager.playState == PMPlayStateSeeking)
        && playerManager.player.runingPlayer == PKMovieNormalPlayer) {
        [MBProgressHUD bjp_closeLoadingView:self.view];

        if (!self.updateDurationTimer || ![self.updateDurationTimer isValid]) {
            self.updateDurationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                                      selector:@selector(updatePlayTime)
                                                                      userInfo:nil repeats:true];
        }
    }
    else {
        [self updatePlayTime];
        [self.updateDurationTimer invalidate];
        self.updateDurationTimer = nil;
    }
}

- (void)updatePlayTime
{
    long curr = _playerManager.currentTime;
    long cache = _playerManager.cacheDuration;
    long total = _playerManager.duration;
    [self.smallVC updateCurrentPlayDuration:curr playableDuration:cache totalDuration:total];
    [self.fullVC updateCurrentPlayDuration:curr playableDuration:cache totalDuration:total];
}

- (void)willPlayNormal:(NSNotification *)noti {
    
    [self.view addSubview:self.fullVC.view];
    [self.view addSubview:self.smallVC.view];

    [self.fullVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [self.smallVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];

    [self.fullVC setupSubviews];
    [self.smallVC setupSubViews];
}

- (void)tailADWillPlay:(NSNotification *)noti {
    BJPlayerManager *player = noti.object;
    if(player != self.playerManager) return;
    self.isPlayingTailAD = YES;
    if (self.screenType == BJPUScreenType_Full) {
        self.fullVC.view.hidden = YES;
    }
    else if (self.screenType == BJPUScreenType_Small) {
        self.smallVC.view.hidden = YES;
    }
}

- (void)tailADPlayFinish:(NSNotification *)noti {
    self.isPlayingTailAD = NO;
    if (self.screenType == BJPUScreenType_Full) {
        self.fullVC.view.hidden = NO;
    }
    else if (self.screenType == BJPUScreenType_Small) {
        self.smallVC.view.hidden = NO;
    }
}

- (void)afterChangeCDN:(NSNotification *)noti {
    [MBProgressHUD bjp_closeLoadingView:self.view];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    if (self.playerManager.player.playbackState != PKMoviePlaybackStatePaused &&
        self.playerManager.player.playbackState != PKMoviePlaybackStatePaused)
    {
        [self.playerManager pause];
        self.pauseByInterrupt = YES;
    }
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    if (self.pauseByInterrupt &&
        self.playerManager.player.playbackState == PKMoviePlaybackStatePaused)
    {
        [self.playerManager play];
        self.pauseByInterrupt = NO;
    }
}

#pragma mark - public interface
- (void)playWithVid:(NSString *)vid token:(NSString *)token
{
    self.vid = vid;
    self.token = token;
    self.localVideoPath = nil;
//    @YPWeakObj(self);
    [self.playerManager setVideoID:vid token:token completion:^BOOL(PMVideoInfoModel * _Nonnull result, NSError * _Nonnull error) {
//        @YPStrongObj(self);
        //可以设置初始播放时间
//        self.playerManager.initialPlaybackTime = 60;
        return YES;
    }];
}

- (void)playWithVid:(NSString *)vid token:(NSString *)token shouldAutoPlay:(BOOL)shouldAutoPlay {
    self.vid = vid;
    self.token = token;
    self.localVideoPath = nil;
//    @YPWeakObj(self);
    [self.playerManager setVideoID:vid token:token completion:^BOOL(PMVideoInfoModel * _Nonnull result, NSError * _Nonnull error) {
//        @YPStrongObj(self);
        //可以设置初始播放时间
//        self.playerManager.initialPlaybackTime = 60;
        return shouldAutoPlay;
    }];
    
}

- (void)playWithVideoPath:(NSString *)path definitionType:(NSInteger)definitionType
{
    self.isLocalVideo = YES;
    self.localVideoPath = path;
    self.definitionType = definitionType;
    self.vid = nil;
    self.token = nil;
//    @YPWeakObj(self);
    [self.playerManager setVideoPath:path definition:definitionType completion:^BOOL(PMVideoInfoModel * _Nonnull result, NSError * _Nonnull error) {
//        @YPStrongObj(self);
        //可以设置初始播放时间
//        self.playerManager.initialPlaybackTime = 60;
        return YES;
    }];
}

#pragma mark - BJPUViewControllerProtocol
- (void)changeScreenType:(BJPUScreenType)type
{
    
    if (self.exitBlock) {
        self.exitBlock();
        return;
    }
    
    if (type == BJPUScreenType_Small) {
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    }
    else if (type == BJPUScreenType_Full) {
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
    }
}

#pragma mark - BJPMProtocol
- (void)videoplayer:(BJPlayerManager *)playerManager throwPlayError:(NSError *)error
{
    [MBProgressHUD bjp_closeLoadingView:self.view];
    NSString *errMsg = [error.userInfo objectForKey:NSLocalizedDescriptionKey] ?: @"";
    // 点播不会走BJPMErrorCodeLoading和BJPMErrorCodeLoadingEnd的逻辑
    if (error.code == BJPMErrorCodeLoading) {
//        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    else if (BJPMErrorCodeLoadingEnd == error.code) {
//        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    else if (BJPMErrorCodeParse == error.code) {
        [MBProgressHUD bjp_closeLoadingView:self.view];
        NSString *msg = [NSString stringWithFormat:@"网络异常，请检查网络后重试\n错误码:%td \n %@", error.code, errMsg];
        if(self.isLocalVideo) {
            msg = [NSString stringWithFormat:@"视频播放失败\n错误码:%td \n %@", error.code, errMsg];
        }
        [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
    }
    else if (BJPMErrorCodeNetwork == error.code) {
        if(!self.isLocalVideo) {
            NSString *msg = [NSString stringWithFormat:@"网络异常，请检查网络后重试\n错误码:%td \n %@", error.code, errMsg];
            [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
        }
    }
    else if (BJPMErrorCodeWWAN == error.code) {
    }
    else if (BJPMErrorCodeServer == error.code) {
        NSString *msg = [NSString stringWithFormat:@"播放失败\n错误码:%td \n %@", error.code, errMsg];
        [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
    }
    else if (BJPMErrorCodeDownloadInvalid == error.code) {
        NSString *msg = [NSString stringWithFormat:@"token有误\n错误码:%td \n %@", error.code, errMsg];
        [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
    }
    else if (BJPMErrorCodeFileEncrypt == error.code) {
        NSString *msg = [NSString stringWithFormat:@"视频播放失败\n错误码:%td \n %@", error.code, errMsg];
        [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
    }
}

- (void)videoDidFinishPlayInVideoPlayer:(BJPlayerManager *)playerManager {
//    PMLog(@" == >finish");
    if (self.finishPlayBlock) {
        self.finishPlayBlock();
    }
}

#pragma mark - set get
- (void)setScreenType:(BJPUScreenType)screenType
{
    _screenType = screenType;
    if (screenType == BJPUScreenType_Full) {
        if (!self.isPlayingTailAD) {
            self.smallVC.view.hidden = true;
            self.fullVC.view.hidden = false;
        }
        self.navigationController.navigationBarHidden = true;
        
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        
        if ([self.fullVC isLocked]) {
            self.view.frame = CGRectMake(0, 0, w, h);
        }
        else {
//            self.view.frame = CGRectMake(0, 0, BJPUScreenHeight, BJPUScreenWidth);
            self.view.frame = CGRectMake(0, 0, w, h);

        }
        
    } else if (screenType == BJPUScreenType_Small) {
        if (!self.isPlayingTailAD) {
            self.smallVC.view.hidden = false;
            self.fullVC.view.hidden = true;
        }
        self.view.frame = self.smallScreenFrame;
    }
}

- (BJPlayerManager *)playerManager
{
    if (!_playerManager) {
        _playerManager = [BJPlayerManager managerWithType:BJPlayerManagerType_AVPlayer];
        _playerManager.delegate = self;
    }
    return _playerManager;
}

- (BJPUSmallViewController *)smallVC
{
    if (!_smallVC) {
        _smallVC = [[BJPUSmallViewController alloc] initWithPlayerManager:self.playerManager];
        _smallVC.delegate = self;
        @YPWeakObj(self);
        _smallVC.rePlayBlock = ^(){
            @YPStrongObj(self);
            if (self.vid.length && self.token.length) {
                [self playWithVid:self.vid token:self.token shouldAutoPlay:YES];
            }
            else if(self.localVideoPath.length){
                [self playWithVideoPath:self.localVideoPath definitionType:self.definitionType];
            }
        };
        [self addChildViewController:_smallVC];
    }
    return _smallVC;
}

- (BJPUFullViewController *)fullVC
{
    if (!_fullVC) {
        _fullVC = [[BJPUFullViewController alloc] initWithPlayerManager:self.playerManager];
        _fullVC.delegate = self;
        @YPWeakObj(self);
        _fullVC.rePlayBlock = ^(){
            @YPStrongObj(self);
            if (self.vid.length && self.token.length) {
                [self playWithVid:self.vid token:self.token shouldAutoPlay:YES];
            }
            else if(self.localVideoPath.length){
                [self playWithVideoPath:self.localVideoPath definitionType:self.definitionType];
            }
        };
        [self addChildViewController:_fullVC];
    }
    return _fullVC;
}


- (UIImageView *)audioOnlyImageView {
    if (!_audioOnlyImageView) {
        _audioOnlyImageView = [[UIImageView alloc] init];
        _audioOnlyImageView.hidden = YES;
        [self.playerManager.player.view addSubview:_audioOnlyImageView];
        [_audioOnlyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerManager.player.view);
        }];
        NSString *imgStr = @"http://live-cdn.baijiayun.com/web/playback/asset/classroom/mediaPanel/img/audioOn.png";
        [_audioOnlyImageView pm_setImageURLString:imgStr];
    }
    return _audioOnlyImageView;
}
@end
