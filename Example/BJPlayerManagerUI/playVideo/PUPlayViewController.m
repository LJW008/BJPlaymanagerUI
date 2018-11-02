//
//  PUPlayViewController.m
//  BJHL-VideoPlayer-UI
//
//  Created by DLM on 2017/4/26.
//  Copyright © 2017年 杨健. All rights reserved.
//

#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import <BJPlayerManagerUI/BJPlayerManagerUI.h>
#import <BJPlayerManagerUI/BJPUMacro.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import <BJPlayerManagerCore/PMReport.h>
#import <BJLiveBase/NSObject+BJLObserving.h>

#import "PUPlayViewController.h"
#import "PUPlayOptionsViewController.h"

@interface PUPlayViewController ()

@property (assign, nonatomic) BOOL isLocal;

// online
@property (strong, nonatomic) NSString *vid;
@property (strong, nonatomic) NSString *token;

// local
@property (strong, nonatomic) NSString *path;
@property (assign, nonatomic) NSInteger definitionType;

// options
@property (assign, nonatomic) BOOL isNeedAD, mayDrag, needEncrypt, shouldAutoPlay, enablePlayTimeRecord;

@property (strong, nonatomic, readwrite) UIViewController<BJPUViewControllerProtocol> *playerUIVC;
@property (assign, nonatomic, readwrite) PUPlayerType playerType;

@end

@implementation PUPlayViewController

- (void)dealloc {
    [self bjl_stopAllKeyValueObserving];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithVid:(NSString *)vid
                      token:(NSString *)token
                   isNeedAD:(BOOL)isNeedAD
                    mayDrag:(BOOL)mayDrag
             shouldAutoPlay:(BOOL)shouldAutoPlay
                needEncrypt:(BOOL)needEncrypt
       enableplayTimeRecord:(BOOL)enablePlayTimeRecord
                 playerType:(PUPlayerType)playerType {
    self = [super init];
    if (self) {
        _isLocal = NO;
        _vid = vid;
        _token = token;
        _isNeedAD = isNeedAD;
        _mayDrag = mayDrag;
        _needEncrypt = needEncrypt;
        _shouldAutoPlay = shouldAutoPlay;
        _enablePlayTimeRecord = enablePlayTimeRecord;
        _playerType = playerType;
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path definitionType:(NSInteger)definitionType playerType:(PUPlayerType)playerType {
    if (self = [super init]) {
        _isLocal = YES;
        _path = path;
        _definitionType = definitionType;
        _playerType = playerType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [self addNotify];
}

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupPlayerVC];
}

- (void)setupPlayerVC {
    PUPlayOptions *options = [PUPlayOptions shareInstance];
    if (self.isLocal) {
        if (self.playerType == PUPlayerType_AVPlayer) {
            self.playerUIVC = [[BJPUViewController alloc] init];
        }
        else {
            self.playerUIVC = [[BJPIJKViewController alloc] initWithNeedBackgroundModes:options.backgroundAudioEnabled];
        }
        
        // 示例：开启记忆播放，剩余时间不足 4 秒时视为播放完成，删除纪录
        self.playerUIVC.playerManager.playTimeRecordEnabled = YES;
        self.playerUIVC.playerManager.ignorableRemainingTimeInterval = 4.0;
        
        [self.playerUIVC setSmallScreenFrame:CGRectMake(0, 64, BJPUScreenWidth, BJPUScreenWidth*9/16)];
        [self.view addSubview:self.playerUIVC.view];
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            [self.playerUIVC setScreenType:BJPUScreenType_Full];
            self.navigationController.navigationBarHidden = YES;
        }
        
        [self.playerUIVC playWithVideoPath:self.path definitionType:self.definitionType];
        [self addChildViewController:self.playerUIVC];
    }
    else {
        [PMAppConfig sharedInstance].isNeedAD = self.isNeedAD;
        if (self.playerType == PUPlayerType_AVPlayer) {
            self.playerUIVC = [[BJPUViewController alloc] init];
            
        }
        else {
            //!!!:如果希望ijk播放器支持后台播放,除了打开Background Modes, 还需要调用该初始化方法设置为YES, 默认是不支持后台播放的
            self.playerUIVC = [[BJPIJKViewController alloc] initWithNeedBackgroundModes:options.backgroundAudioEnabled];
        }
        [self.playerUIVC sliderMayDrag:self.mayDrag];
        if (self.enablePlayTimeRecord) {
            // 示例：开启记忆播放，剩余时间不足 4 秒时视为播放完成，删除纪录
            self.playerUIVC.playerManager.playTimeRecordEnabled = YES;
            self.playerUIVC.playerManager.ignorableRemainingTimeInterval = 4.0;
        }
        else {
            // 示例：不开启记忆播放，清空播放纪录
            [self.playerUIVC.playerManager clearPlayTimeRecords];
        }
        [self.playerUIVC setSmallScreenFrame:CGRectMake(0, 64, BJPUScreenWidth, BJPUScreenWidth*9/16)];
        [self.view addSubview:self.playerUIVC.view];
        [self addChildViewController:self.playerUIVC];
        if (self.playerType == PUPlayerType_AVPlayer) {
            [self.playerUIVC playWithVid:_vid token:_token shouldAutoPlay:_shouldAutoPlay];
        }
        else {
            [self.playerUIVC playWithVid:_vid token:_token shouldAutoPlay:_shouldAutoPlay needEncrypt:_needEncrypt];
        }
    }
}

#pragma mark - notify

- (void)addNotify {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(deviceOrientationDidChange)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayStateChanged:)
                                                 name:PMPlayStateChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayStateChanged:)
                                                 name:PKMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playADVideo)
                                                 name:PMPlayerADHeaderOrTailWilPlayNotification object:self.playerUIVC.playerManager];
}

#pragma mark - actions

- (void)playADVideo {
    [self.playerUIVC.playerManager startAD];
}

- (void)playerPlayStateChanged:(NSNotification *)noti {
    if([noti.name isEqualToString:PMPlayStateChangeNotification]) {
        BJPlayerManager *playerManager = (BJPlayerManager*)noti.object;
        if(playerManager.playState == PMPlayStatePlaying) {
            //        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            //        [MBProgressHUD bjp_showMessageThenHide:playerManager.player.contentURL.absoluteString toView:keyWindow onHide:nil];
        }
    }

    if([noti.name isEqualToString:PKMoviePlayerPlaybackStateDidChangeNotification]) {
        PKMoviePlayerController *vc = (PKMoviePlayerController *)noti.object;
        if (vc.playbackState == PKMoviePlaybackStateStopped) {
            NSLog(@"xinyapeng: vc.playbackState = PKMoviePlaybackStateStopped");
        }
        else if (vc.playbackState == PKMoviePlaybackStatePlaying) {
            NSLog(@"xinyapeng: vc.playbackState = PKMoviePlaybackStatePlaying");
        }
        else if (vc.playbackState == PKMoviePlaybackStateInterrupted) {
            NSLog(@"xinyapeng: vc.playbackState = PKMoviePlaybackStateInterrupted");
        }
        else if (vc.playbackState == PKMoviePlaybackStateSeekingForward) {
            NSLog(@"xinyapeng: vc.playbackState = PKMoviePlaybackStateSeekingForward");
        }
        else if (vc.playbackState == PKMoviePlaybackStateSeekingBackward) {
            NSLog(@"xinyapeng: vc.playbackState = PKMoviePlaybackStateSeekingBackward");
        }
    }
}

@end
