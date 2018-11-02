//
//  BJPViewController.m
//  BJPlaybackUI
//
//  Created by oushizishu on 08/22/2017.
//  Copyright (c) 2017 oushizishu. All rights reserved.
//

#import <BJPlaybackUI/BJPlaybackUI.h>
#import <BJPlayerManagerCore/PMAppConfig.h>
#import "PUDownloadViewController.h"
#import "BJPViewController.h"
#import "PUPlayOptionsViewController.h"

@interface BJPViewController ()<UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic) UITextField *classIdTextField, *tokenTextField, *sessionTextField;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, readwrite) UIView *contentView;

@end

@implementation BJPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupScrollView];
    [self setupSubviews];
    
    self.classIdTextField.text = @"18101891820371";
    self.sessionTextField.text = @"";
    self.tokenTextField.text = @"XkUpy6xIOuGwCRjhQyTd4EpQarINe_aBeRhlK7Yo2puRpFRd35W7wjTSEzZrILF4";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayStateChanged:)
                                                 name:PMPlayStateChangeNotification object:nil];
}

- (void)setupScrollView {
    self.contentView = [UIView new];
    self.scrollView = [UIScrollView new];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.frame.size.height+50);
    
    [self.scrollView addSubview:self.contentView];
    [self.view addSubview:self.scrollView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(1.5);
        make.top.left.equalTo(self.scrollView);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupSubviews {
    [self.contentView addSubview:self.classIdTextField];
    
    [self.classIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(50.f);
        make.left.equalTo(self.view).offset(30.f);
        make.right.equalTo(self.view).offset(-30.f);
        make.height.equalTo(@35);
    }];
    
    [self.contentView addSubview:self.sessionTextField];
    [self.sessionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.classIdTextField.mas_bottom).offset(20.f);
        make.left.right.height.equalTo(self.classIdTextField);
    }];
    
    [self.contentView addSubview:self.tokenTextField];
    [self.tokenTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sessionTextField.mas_bottom).offset(20.f);
        make.left.right.height.equalTo(self.classIdTextField);
    }];
    
    [self.contentView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tokenTextField.mas_bottom).offset(30);
        make.height.equalTo(@42);
        make.width.equalTo(@100);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - action

- (void)enterRoom:(UIButton *)button {
    
    /**
     BJPlayerManagerType_AVPlayer = 0,
     BJPlayerManagerType_IJKPlayer = 1,
     */

    bjl_weakify(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"播放器选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *BJDownAction = [UIAlertAction actionWithTitle:@"AVPlaer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        bjl_strongify(self);
        // AVPlaer
        PUPlayOptions *options = [PUPlayOptions shareInstance];
        BJPRoomViewController *vc = [BJPRoomViewController onlineVideoCreateRoomWithClassId:self.classIdTextField.text
                                                                                  sessionId:self.sessionTextField.text
                                                                                      token:self.tokenTextField.text
                                                                                   userName:options.userName
                                                                                 userNumber:options.userNumber
                                                                                use_encrypt:options.encryptEnabled
                                                                          PlayerManagerType:BJPlayerManagerType_AVPlayer];
        // 示例：开启记忆播放，剩余时间不足 4 秒时视为播放完成，删除纪录
        BJPlayerManager *playerControl = vc.room.playbackVM.playerControl;
        playerControl.playTimeRecordEnabled = YES;
        playerControl.ignorableRemainingTimeInterval = 4.0;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    UIAlertAction *PMDownAction = [UIAlertAction actionWithTitle:@"IJKPlayer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        bjl_strongify(self);
        // IJKPlayer
        PUPlayOptions *options = [PUPlayOptions shareInstance];
        BJPRoomViewController *vc = [BJPRoomViewController onlineVideoCreateRoomWithClassId:self.classIdTextField.text
                                                                                  sessionId:self.sessionTextField.text
                                                                                      token:self.tokenTextField.text
                                                                                   userName:@"江军"
                                                                                 userNumber:0
                                                                                use_encrypt:options.encryptEnabled
                                                                          PlayerManagerType:BJPlayerManagerType_IJKPlayer];
        // 示例：开启记忆播放，剩余时间不足 4 秒时视为播放完成，删除纪录
        BJPlayerManager *playerControl = vc.room.playbackVM.playerControl;
        playerControl.playTimeRecordEnabled = YES;
        playerControl.ignorableRemainingTimeInterval = 4.0;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    [alert addAction:BJDownAction];
    [alert addAction:PMDownAction];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - private

- (UITextField *)textFieldwithLeftLabelText:(NSString *)text {
    UITextField *textField = [UITextField new];
    textField.layer.borderWidth = 1.f;
    textField.layer.borderColor = [UIColor grayColor].CGColor;
    textField.leftViewMode = UITextFieldViewModeAlways;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 42)];
    label.text = text;
    textField.leftView = label;
    return textField;
}

- (void)playerPlayStateChanged:(NSNotification *)noti {
    BJPlayerManager *playerManager = (BJPlayerManager*)noti.object;
    if(playerManager.playState == PMPlayStatePlaying) {
    }
}

#pragma mark - getter

- (UITextField *)classIdTextField {
    if (!_classIdTextField) {
        _classIdTextField = [self textFieldwithLeftLabelText:@" classId: "];
    }
    return _classIdTextField;
}

- (UITextField *)sessionTextField {
    if (!_sessionTextField) {
        _sessionTextField = [self textFieldwithLeftLabelText:@" sessionId:"];
    }
    return _sessionTextField;
}

- (UITextField *)tokenTextField {
    if (!_tokenTextField) {
        self.tokenTextField = [self textFieldwithLeftLabelText:@"token: "];
    }
    return _tokenTextField;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton new];
        [_playButton setTitle:@"在线视频" forState:UIControlStateNormal];
        [_playButton setBackgroundColor:[UIColor blueColor]];
        [_playButton addTarget:self action:@selector(enterRoom:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

@end
