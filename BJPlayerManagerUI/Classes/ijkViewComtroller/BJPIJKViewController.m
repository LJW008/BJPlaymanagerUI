
//
//  BJPIJKViewController.m
//  BJPlayerManagerUI
//
//  Created by 凡义 on 2018/1/2.
//

#import "BJPIJKViewController.h"
#import "BJPIJKSmallViewController.h"
#import "BJPIJKFullViewController.h"
#import "BJPUMacro.h"
#import "MBProgressHUD+bjp.h"
#import <BJLiveBase/BJLAFNetworking.h>
#import <BJLiveBase/UIAlertController+BJLAddAction.h>

@interface BJPIJKViewController ()<BJPUViewControllerProtocol, BJPMProtocol, BJPUDefinitionViewProtocol>

@property (strong, nonatomic, readwrite) BJPlayerManager *playerManager;

@property (strong, nonatomic) BJPIJKSmallViewController *smallVC;
@property (strong, nonatomic) BJPIJKFullViewController *fullVC;
@property (strong, nonatomic) UIImageView *audioOnlyImageView;

//由于ijkplayer播放器在进入后台的时候默认是
@property (assign, nonatomic) BOOL needBackgroundModes;
/*用于区分是进入后台的pause还是其他操作的pause*/
@property (nonatomic, assign) BOOL isEnterBackgroudPasue;

@property (assign, nonatomic) BOOL isNavigationBarHidden, isPlayingTailAD, isLocalVideo;
@property (strong, nonatomic) NSTimer *updateDurationTimer;

@property (strong, nonatomic, nullable) NSString *vid, *token;
@property (strong, nonatomic, nullable) NSString *localVideoPath;
@property (assign, nonatomic) NSInteger definitionType;

@property (nonatomic, nullable) BJLAFNetworkReachabilityManager *reachability;

@end

@implementation BJPIJKViewController

- (instancetype)init {
    self = [super init];
    if(self) {
        self.needBackgroundModes = NO;
    }
    return self;
}

- (instancetype)initWithNeedBackgroundModes:(BOOL)needBackgroundModes {
    self = [super init];
    if(self) {
        self.needBackgroundModes = needBackgroundModes;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubviews];
    self.screenType = BJPUScreenType_Small;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayStateChanged:)
                                                 name:PMPlayStateChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateChanged:)
                                                 name:PKMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerReadyNotification:)
                                                 name:PKMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willPlayNormal:)
                                                 name:PMPlayerWillPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tailADWillPlay:)
                                                 name:PMPlayerTailADWilPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tailADPlayFinish:)
                                                 name:PMPlayerTailADPlayFinishNotification object:nil];
    
    //不需要后台播放的时候,进入前后台暂停
    if(!self.needBackgroundModes) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];

    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.reachability) {
        [self.reachability stopMonitoring];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.updateDurationTimer invalidate];
    self.updateDurationTimer = nil;
    [_playerManager clearPlayer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - public
- (void)playWithVid:(NSString *)vid token:(NSString *)token shouldAutoPlay:(BOOL)shouldAutoPlay needEncrypt:(BOOL)needEncrypt {
    self.vid = vid;
    self.token = token;
    self.localVideoPath = nil;
    self.isLocalVideo = NO;
    [self.playerManager setVideoID:vid token:token encrypted:needEncrypt completion:^BOOL(PMVideoInfoModel * _Nonnull result, NSError * _Nonnull error) {
        return shouldAutoPlay;
    }];
}

- (void)playWithVideoPath:(NSString *)path definitionType:(NSInteger)definitionType {
    self.localVideoPath = path;
    self.definitionType = definitionType;
    self.vid = nil;
    self.token = nil;
    self.isLocalVideo = YES;
    [self.playerManager setVideoPath:path definition:definitionType completion:nil];
}

/**
 进度条是否可以拖拽
 
 @param mayDrag mayDrag
 */
- (void)sliderMayDrag:(BOOL)mayDrag {
    self.smallVC.progressView.userInteractionEnabled = mayDrag;
    self.fullVC.bottomBarView.progressView.userInteractionEnabled = mayDrag;
    
    self.smallVC.sliderView.userInteractionEnabled = mayDrag;
    self.fullVC.sliderView.userInteractionEnabled = mayDrag;
}

#pragma mark - private
- (void)setupSubviews {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerManager.player.view];
    [self.playerManager.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

//方向变化
- (void)deviceOrientationDidChange:(NSNotification *)noti {
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
        //        || orientation == UIDeviceOrientationPortraitUpsideDown) {
        PMLog(@"竖屏模式");
        //        [self.navigationController setNavigationBarHidden:_isNavigationBarHidden];
        [self.navigationController setNavigationBarHidden:NO];
        self.screenType = BJPUScreenType_Small;
    }
}

//播放状态变化
- (void)playerPlayStateChanged:(NSNotification *)noti {
    BJPlayerManager *playerManager = (BJPlayerManager*)noti.object;
    [self.smallVC updatePlayState:playerManager.playState];
    [self.fullVC updatePlayState:playerManager.playState];
    if (playerManager.playState == PMPlayStatePlaying) {
        self.audioOnlyImageView.hidden = !(playerManager.currDefinitionInfoModel.definitionType == DT_Audio);
    }
    
//    !!!:ijkplayer的状态,初始化播放的时候为PMPlayStateSeeking状态
    if ((playerManager.playState == PMPlayStatePlaying || playerManager.playState == PMPlayStateSeeking)
        && playerManager.player.runingPlayer == PKMovieNormalPlayer) {
        // 清晰度切换完成后会变成playing状态，在这里去掉了loading，首次播放也是这里
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

 // ijk 的卡顿loading状态通过这里显示
- (void)playerLoadStateChanged:(NSNotification *)noti {
    PKMoviePlayerController *vc = noti.object;
    if(vc.loadState == PKMovieLoadStatePlaythroughOK) {
        [MBProgressHUD bjp_closeLoadingView:self.view];
    }
    else if (vc.loadState == PKMovieLoadStateStalled) {
        [MBProgressHUD bjp_showLoading:@"正在加载" toView:self.view];
    }
}

// ijk在这里去掉loading动画
- (void)playerReadyNotification:(NSNotification *)noti {
    [MBProgressHUD bjp_closeLoadingView:self.view];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    if (self.playerManager.playState != PMPlayStatePaused &&
        self.playerManager.playState != PMPlayStateStopped)
    {
        [self.playerManager pause];
        self.isEnterBackgroudPasue = YES;
    }
    else if ((self.playerManager.playState == PMPlayStatePaused ||
             self.playerManager.playState == PMPlayStateStopped) &&
             self.isEnterBackgroudPasue == YES)
    {
        self.isEnterBackgroudPasue = YES;
    }
    else {
        self.isEnterBackgroudPasue = NO;
    }
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    if (self.isEnterBackgroudPasue &&
        self.playerManager.playState == PMPlayStatePaused)
    {
        [self.playerManager play];
        self.isEnterBackgroudPasue = NO;
    }
}

- (void)updatePlayTime {
    long curr = _playerManager.currentTime;
    long cache = _playerManager.cacheDuration;
    long total = _playerManager.duration;
    [self.smallVC updateCurrentPlayDuration:curr playableDuration:cache totalDuration:total];
    [self.fullVC updateCurrentPlayDuration:curr playableDuration:cache totalDuration:total];
}

//即将变化
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
    [self.smallVC setupSubviews];
    // 首次播放的时候显示正在加载
    [MBProgressHUD bjp_showLoading:@"正在加载" toView:self.view];
    @YPWeakObj(self);
    if(self.isLocalVideo) {
        return;
    }
    self.reachability = ({
        __block BOOL isFirstTime = YES;
        BJLAFNetworkReachabilityManager *reachability = [BJLAFNetworkReachabilityManager manager];
        [reachability setReachabilityStatusChangeBlock:^(BJLAFNetworkReachabilityStatus status) {
             @YPStrongObj(self);
            if (status != BJLAFNetworkReachabilityStatusReachableViaWWAN) {
                return;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (status != BJLAFNetworkReachabilityStatusReachableViaWWAN) {
                    return;
                }
                if (isFirstTime) {
                    if(self.playerManager.playState == PMPlayStatePlaying) {
                        isFirstTime = NO;
                        [self.playerManager pause];
                        UIAlertController *alert = [UIAlertController
                                                    alertControllerWithTitle:@"提示"
                                                    message:@"正在使用3G/4G网络，可手动关闭视频以减少流量消耗"
                                                    preferredStyle:UIAlertControllerStyleAlert];
                        [alert bjl_addActionWithTitle:@"知道了"
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction *action) {
                                                  @YPStrongObj(self);
                                                  [self.playerManager play];
                                              }];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }
                else {
                    [MBProgressHUD bjp_showMessageThenHide:@"正在使用3G/4G网络" toView:self.view onHide:nil];
                }
            });
        }];
        [reachability startMonitoring];
        reachability;
    });
}

//片尾即将播放
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

//片尾播放完
- (void)tailADPlayFinish:(NSNotification *)noti {
    self.isPlayingTailAD = NO;
    if (self.screenType == BJPUScreenType_Full) {
        self.fullVC.view.hidden = NO;
    }
    else if (self.screenType == BJPUScreenType_Small) {
        self.smallVC.view.hidden = NO;
    }
}

#pragma mark BJPUDefinitionViewProtocol
- (void)definitionView:(BJPUDefinitionView *)definitionView selectDefinition:(PMVideoDefinitionInfoModel *)definition {
    if(self.playerManager.currDefinitionInfoModel.definitionType == definition.definitionType) {
        return;
    }
    // 切换清晰度时显示loading
    [MBProgressHUD bjp_showLoading:@"正在加载" toView:self.view];
    [self.playerManager changeDefinition:definition.definitionType];
}

#pragma mark - BJPUViewControllerProtocol
- (void)changeScreenType:(BJPUScreenType)type {
    if (type == BJPUScreenType_Small) {
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    }
    else if (type == BJPUScreenType_Full) {
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
    }
}

#pragma mark - BJPIJKMProtocol
- (void)videoplayer:(BJPlayerManager *)playerManager throwPlayError:(NSError *)error {
    NSString *errMsg = [error.userInfo objectForKey:NSLocalizedDescriptionKey] ?: @"未知错误";
    // 点播不会走BJPMErrorCodeLoading和BJPMErrorCodeLoadingEnd的逻辑
    if (error.code == BJPMErrorCodeLoading) {
//        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    } else if (BJPMErrorCodeLoadingEnd == error.code) {
//        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    else if (BJPMErrorCodeParse == error.code) {
        NSString *msg = [NSString stringWithFormat:@"视频播放失败\n错误码:%td \n %@", error.code, errMsg];
        [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
    }
    else if (BJPMErrorCodeNetwork == error.code) {
        if(!self.isLocalVideo) {
            NSString *msg = [NSString stringWithFormat:@"没有网络或者未知网络\n错误码:%td \n %@", error.code, errMsg];
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
        NSString *msg = [NSString stringWithFormat:@"播放失败\n错误码:%td \n %@", error.code, errMsg];
        [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"错误码:%td \n %@", error.code, errMsg];
        [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
    }
}

- (void)videoDidFinishPlayInVideoPlayer:(BJPlayerManager *)playerManager {
    PMLog(@" == >finish");
}

#pragma mark - set get
- (void)setScreenType:(BJPUScreenType)screenType {
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
            self.view.frame = CGRectMake(0, 0, BJPUScreenHeight, BJPUScreenWidth);
        }
        
    } else if (screenType == BJPUScreenType_Small) {
        if (!self.isPlayingTailAD) {
            self.smallVC.view.hidden = false;
            self.fullVC.view.hidden = true;
        }
        self.view.frame = self.smallScreenFrame;
    }
}

- (BJPlayerManager *)playerManager {
    if (!_playerManager) {
        _playerManager = [BJPlayerManager managerWithType:BJPlayerManagerType_IJKPlayer];
        _playerManager.delegate = self;
    }
    return _playerManager;
}

- (BJPlayerManager *)ijkPlayerManager {
    return self.playerManager;
}

- (BJPIJKSmallViewController *)smallVC
{
    if (!_smallVC) {
        _smallVC = [[BJPIJKSmallViewController alloc] initWithPlayerManager:self.playerManager];
        _smallVC.delegate = self;
        @YPWeakObj(self);
        _smallVC.rePlayBlock = ^(){
            @YPStrongObj(self);
            if (self.vid.length && self.token.length) {
//                [self playWithVid:self.vid token:self.token shouldAutoPlay:YES needEncrypt:self.ijkPlayerManager];
            }
            else if(self.localVideoPath.length){
                [self playWithVideoPath:self.localVideoPath definitionType:self.definitionType];
            }
        };
        [self addChildViewController:_smallVC];
    }
    _smallVC.isLocalVideo = self.isLocalVideo;
    return _smallVC;
}

- (BJPIJKFullViewController *)fullVC {
    if (!_fullVC) {
        _fullVC = [[BJPIJKFullViewController alloc] initWithPlayerManager:self.playerManager];
        _fullVC.delegate = self;
        _fullVC.definitionView.delegate = self;
        @YPWeakObj(self);
        _fullVC.rePlayBlock = ^(){
            @YPStrongObj(self);
            if (self.vid.length && self.token.length) {
//                [self playWithVid:self.vid token:self.token];
            }
            else if(self.localVideoPath.length){
                [self playWithVideoPath:self.localVideoPath definitionType:self.definitionType];
            }
        };
        [self addChildViewController:_fullVC];
    }
    _fullVC.isLocalVideo = self.isLocalVideo;
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
