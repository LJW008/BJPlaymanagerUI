//
//  PUMainViewController.m
//  BJHL-VideoPlayer-UI
//
//  Created by DLM on 2017/4/26.
//  Copyright © 2017年 杨健. All rights reserved.
//

#import "PUMainViewController.h"
#import <BJPlayerManagerUI/BJPlayerManagerUI.h>
#import <BJPlayerManagerUI/BJPUMacro.h>
#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import <Masonry/Masonry.h>
#import "PUPlayViewController.h"
#import "PUPlayOptionsViewController.h"
#import "BJPViewController.h"
#import "PUDownloadViewController.h"
#import "PUPMDownloadViewController.h"
#import "UIAlertView+bjp.h"

@interface PUMainViewController ()
@property (strong, nonatomic) UISegmentedControl *deploySegment;
@property (strong, nonatomic) UITextField *vidTextField;
@property (strong, nonatomic) UITextField *tokenTextField;

@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *downloadBtn;
@property (strong, nonatomic) UIButton *ijkVideoPlayButton;
@property (strong, nonatomic) UIButton *playbackTestButton;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;

@end

@implementation PUMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupScrollView];
    
#if DEBUG
    [self.contentView addSubview:self.deploySegment];
    [self deploySegmentMakeConstraints];
#else
#endif
    [self.contentView addSubview:self.vidTextField];
    [self.contentView addSubview:self.tokenTextField];

    [self.contentView addSubview:self.settingButton];
    [self.contentView addSubview:self.playButton];
    [self.contentView addSubview:self.downloadBtn];
    [self.contentView addSubview:self.ijkVideoPlayButton];
    [self.contentView addSubview:self.playbackTestButton];

    [self makeConstraints];

    self.vidTextField.text = @"215722";
    self.tokenTextField.text = @"Pju4Si4GUtzXWjHe9OrhtHR8enhFhU64zap5z1AYmVgPIE_QY2iMlQ";
}

- (void)setupScrollView
{
    self.contentView = [UIView new];
    self.scrollView = [UIScrollView new];
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.frame.size.height);
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
}

- (void)deploySegmentMakeConstraints
{
    [self.deploySegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(20.f);
        make.right.equalTo(self.contentView).offset(-20.f);
        make.height.equalTo(@30);
    }];
}

- (void)makeConstraints {

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.view);
    }];

    [self.vidTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.contentView).offset(70);
    }];

    [self.tokenTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.vidTextField);
        make.top.equalTo(self.vidTextField.mas_bottom).offset(30);
    }];

    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tokenTextField.mas_bottom).offset(30.0);
        make.left.right.equalTo(self.vidTextField);
        make.height.equalTo(@30);
    }];

    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.vidTextField);
        make.top.equalTo(self.settingButton.mas_bottom).offset(30);
    }];

    [self.downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.vidTextField);
        make.top.equalTo(self.playButton.mas_bottom).offset(30);
        //        make.bottom.offset(-50);
    }];

    [self.ijkVideoPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.vidTextField);
        make.top.equalTo(self.downloadBtn.mas_bottom).offset(30);
    }];

    [self.playbackTestButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.vidTextField);
        make.top.equalTo(self.ijkVideoPlayButton.mas_bottom).offset(30);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-30);
    }];
}

#pragma mark - action

- (void)showSettingView {
    PUPlayOptionsViewController *optionsVC = [[PUPlayOptionsViewController alloc] init];
    [self presentViewController:optionsVC animated:YES completion:nil];
}

- (void)entryPlayControl {
    NSString *vid = self.vidTextField.text;
    NSString *token = self.tokenTextField.text;
    
    PUPlayOptions *options = [PUPlayOptions shareInstance];
    [[PMAppConfig sharedInstance] setExclusiveSubdomain:options.exclusiveDomain];
    [PMAppConfig sharedInstance].notAutoStartImageAD = options.notAutoStartImageAD;
    BOOL advertisementEnabled = options.advertisementEnabled;
    BOOL autoplay = options.autoplay;
    BOOL playTimeRecordEnabled = options.playTimeRecordEnabled;
    BOOL sliderDragEnabled = options.sliderDragEnabled;
    PUPlayViewController *playerVC = [[PUPlayViewController alloc] initWithVid:vid
                                                                         token:token
                                                                      isNeedAD:advertisementEnabled
                                                                       mayDrag:sliderDragEnabled
                                                                shouldAutoPlay:autoplay
                                                                   needEncrypt:NO
                                                          enableplayTimeRecord:playTimeRecordEnabled
                                                                    playerType:PUPlayerType_AVPlayer];
    [self.navigationController pushViewController:playerVC animated:YES];
}

- (void)downloadAction {
    bjl_weakify(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"下载选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *BJDownAction = [UIAlertAction actionWithTitle:@"BJ下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        bjl_strongify(self);
        //BJDownload
        PUDownloadViewController *downloadVC = [PUDownloadViewController new];
        [self.navigationController pushViewController:downloadVC animated:YES];
    }];
    UIAlertAction *PMDownAction = [UIAlertAction actionWithTitle:@"PM下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        bjl_strongify(self);
        //PMDownload
        PUPMDownloadViewController *vc = [PUPMDownloadViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alert addAction:BJDownAction];
    [alert addAction:PMDownAction];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deployTypeChanged:(UISegmentedControl *)segment
{
#if DEBUG
    switch (segment.selectedSegmentIndex) {
        case 0:
            [PMAppConfig sharedInstance].deployType = PMDeployType_www;
            [self saveDeplayAndTipWithEnvType:0];
            break;
        case 1:
            [PMAppConfig sharedInstance].deployType = PMDeployType_beta;
            [self saveDeplayAndTipWithEnvType:1];
            break;
        case 2:
            [PMAppConfig sharedInstance].deployType = PMDeployType_test;
            [self saveDeplayAndTipWithEnvType:2];
            break;
        default:
            break;
    }
#else
#endif
}

- (void)enterIJKPlay {
    NSString *vid = self.vidTextField.text;
    NSString *token = self.tokenTextField.text;
    PUPlayOptions *options = [PUPlayOptions shareInstance];
    BOOL advertisementEnabled = options.advertisementEnabled;
    BOOL shouldAutoPlay = options.autoplay;
    BOOL encryptEnabled = options.encryptEnabled;
    BOOL playTimeRecordEnabled = options.playTimeRecordEnabled;
    BOOL sliderDragEnabled = options.sliderDragEnabled;
    PUPlayViewController *playerVC = [[PUPlayViewController alloc]
                                         initWithVid:vid
                                         token:token
                                         isNeedAD:advertisementEnabled
                                         mayDrag:sliderDragEnabled
                                         shouldAutoPlay:shouldAutoPlay
                                         needEncrypt:encryptEnabled
                                         enableplayTimeRecord:playTimeRecordEnabled
                                      playerType:PUPlayerType_IJKPlayer];
    [self.navigationController pushViewController:playerVC animated:YES];
}

- (void)playbackAction {
    [self.navigationController pushViewController:[BJPViewController new] animated:YES];
}


#pragma MARK - 切换环境
- (void)saveDeplayAndTipWithEnvType:(PMDeployType)type {
    [self saveDeplay:type];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"切换成功" message:@"必须重新启动app设置才生效" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"退出程序", nil];
    [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        abort();
    }];
}

- (void)saveDeplay:(PMDeployType)type {
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:@"developType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)playbackTest {
    BJPViewController *vc = [[BJPViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - set get

- (UISegmentedControl *)deploySegment
{
    if (!_deploySegment) {
        _deploySegment = [[UISegmentedControl alloc] initWithItems:@[@"www", @"Beta", @"test"]];
        NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"developType"];
        _deploySegment.selectedSegmentIndex = index;
        [self setDevelopType:index];
        [_deploySegment addTarget:self action:@selector(deployTypeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _deploySegment;
}

- (UITextField *)vidTextField
{
    if(!_vidTextField) {
        _vidTextField = [[UITextField alloc] init];
        _vidTextField.placeholder = @"vid";
        _vidTextField.layer.borderColor = [UIColor grayColor].CGColor;
        _vidTextField.layer.borderWidth = 0.5;
        _vidTextField.layer.cornerRadius = 5.f;
    }
    return _vidTextField;
}

- (UITextField *)tokenTextField
{
    if(!_tokenTextField) {
        _tokenTextField = [[UITextField alloc] init];
        _tokenTextField.placeholder = @"token";
        _tokenTextField.text = @"test12345678";//测试环境
        _tokenTextField.layer.borderColor = [UIColor grayColor].CGColor;
        _tokenTextField.layer.borderWidth = 0.5;
        _tokenTextField.layer.cornerRadius = 5.f;
    }
    return _tokenTextField;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [[UIButton alloc] init];
        _settingButton.backgroundColor = [UIColor redColor];
        _settingButton.layer.cornerRadius = 5.f;
        [_settingButton setTitle:@"播放设置" forState:UIControlStateNormal];
        [_settingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_settingButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_settingButton addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        _playButton.backgroundColor = [UIColor redColor];
        _playButton.layer.cornerRadius = 5.f;
        [_playButton setTitle:@"avplayer播放" forState:UIControlStateNormal];
        [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_playButton addTarget:self action:@selector(entryPlayControl) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)downloadBtn
{
    if (!_downloadBtn) {
        _downloadBtn = [[UIButton alloc] init];
        _downloadBtn.backgroundColor = [UIColor redColor];
        _downloadBtn.layer.cornerRadius = 5.f;
        [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_downloadBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_downloadBtn addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadBtn;
}

- (UIButton *)ijkVideoPlayButton {
    if(!_ijkVideoPlayButton) {
        _ijkVideoPlayButton = [[UIButton alloc] init];
        _ijkVideoPlayButton.backgroundColor = [UIColor redColor];
        _ijkVideoPlayButton.layer.cornerRadius = 5.f;
        [_ijkVideoPlayButton setTitle:@"ijkplayer播放" forState:UIControlStateNormal];
        [_ijkVideoPlayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_ijkVideoPlayButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_ijkVideoPlayButton addTarget:self action:@selector(enterIJKPlay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ijkVideoPlayButton;
}

- (UIButton *)playbackTestButton {
    if(!_playbackTestButton) {
        _playbackTestButton = [[UIButton alloc] init];
        _playbackTestButton.backgroundColor = [UIColor redColor];
        _playbackTestButton.layer.cornerRadius = 5.f;
        [_playbackTestButton setTitle:@"回放播放" forState:UIControlStateNormal];
        [_playbackTestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playbackTestButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_playbackTestButton addTarget:self action:@selector(playbackTest) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playbackTestButton;
}

#pragma MARK - 切换环境

- (void)setDevelopType:(NSInteger)type {
    
#if DEBUG
    switch (type) {
        case 0:
            [PMAppConfig sharedInstance].deployType = PMDeployType_www;
            break;
            
        case 1:
            [PMAppConfig sharedInstance].deployType = PMDeployType_beta;
            break;
            
        case 2:
            [PMAppConfig sharedInstance].deployType = PMDeployType_test;
            break;

        default:
            break;
    }
#else
#endif
}

@end
