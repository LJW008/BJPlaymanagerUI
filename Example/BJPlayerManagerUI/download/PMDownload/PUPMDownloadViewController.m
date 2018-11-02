//
//  PUPMDownloadViewController.m
//  BJPlayerManagerUI_Example
//
//  Created by 辛亚鹏 on 2017/12/13.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import <BJPlayerManagerUI/MBProgressHUD+bjp.h>
#import <Masonry.h>
#import "PUPMDownloadManagerTableViewController.h"
#import "PULocalVideoListTableViewController.h"
#import "PULocalListTableViewController.h"
#import "PUPMDownloadViewController.h"
#import "PUPlayOptionsViewController.h"

@interface PUPMDownloadViewController ()<PMDownloadDelegate>
@property (weak, nonatomic) IBOutlet UITextField *vidclassidTF;
@property (weak, nonatomic) IBOutlet UITextField *sessionIdTF;
@property (weak, nonatomic) IBOutlet UITextField *tokenTF;

@property (strong, nonatomic) IBOutlet UIButton *vidDownbtn;
@property (strong, nonatomic) IBOutlet UIButton *classDownBtn;

@end

@implementation PUPMDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.vidclassidTF.text = @"215722";
    self.sessionIdTF.text = @"";
    self.tokenTF.text = @"N8ZYHS6iMsDXWjHe9OrhtHR8enhFhU645IAGUzYlB6RhAuGGFV1jrg";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [PMDownloadManager downloadManager].delegate = self;
}

- (IBAction)vidDownloadAction:(UIButton *)sender {
    PUPlayOptions *options = [PUPlayOptions shareInstance];
    sender.enabled = NO;
    [MBProgressHUD bjp_showLoading:@"加载中" toView:self.view];
    [[PMDownloadManager downloadManager] addDownloadWithVid:self.vidclassidTF.text token:self.tokenTF.text definionArray:options.preferredDefinitionList showFileName:[NSString stringWithFormat:@"%@", _vidclassidTF.text] need_encrypt:options.encryptEnabled];
}

- (IBAction)playbackDownloadAction:(UIButton *)sender {
    PUPlayOptions *options = [PUPlayOptions shareInstance];
    sender.enabled = NO;

    [MBProgressHUD bjp_showLoading:@"加载中" toView:self.view];
    [[PMDownloadManager downloadManager] addDownloadWithClass:self.vidclassidTF.text seesionID:self.sessionIdTF.text token:self.tokenTF.text definionArray:options.preferredDefinitionList showFileName:[NSString stringWithFormat:@"playback+%@", self.vidclassidTF.text] creatTime:@"creatTime" need_encrypt:options.encryptEnabled];
}

- (IBAction)localVideo:(id)sender {
    [self.navigationController pushViewController:[PULocalVideoListTableViewController new] animated:YES];
}

- (IBAction)downloadManagerAction:(id)sender {
    [self.navigationController pushViewController:[PUPMDownloadManagerTableViewController new] animated:YES];
}

#pragma mark - download delegate

- (void)startDownload:(PMDownloader *)downloader {
    NSLog(@"PUVC: %s", __func__);

    dispatch_sync(dispatch_get_main_queue(), ^{
        self.vidDownbtn.enabled = YES;
        self.classDownBtn.enabled = YES;
        [MBProgressHUD bjp_closeLoadingView:self.view];
    });
}

- (void)updateProgress:(PMDownloader *)downloader {
//    NSLog(@"PUVC: %s", __func__);
}

- (void)finishedDownload:(PMDownloader *)downloader {
//    NSLog(@"PUVC: %s", __func__);
}

- (void)downloadFail:(nullable PMDownloader *)downloader beforeDownloadError:(nullable PMBeforeDownloadModel *)beforeDownloadModel {

    dispatch_async(dispatch_get_main_queue(), ^{
        self.vidDownbtn.enabled = YES;
        self.classDownBtn.enabled = YES;
    });

    //加入下载的时候发生的错误需要处理,同下载过程中发生了错误的处理稍有不同
//    !!!:加入下载的时候,如果发生的下载前的错误,是需要再次调用addDownloadWith...方法的
    NSLog(@"PUVC: %s", __func__);

    //下载前的错误信息:下载前主要是会检测一下传入的token参数是否能获取到正确的url,如果不能会抛出错误,
    //下载前也会检测文件是否已经正在下载,或者已经下载完成,都会抛出描述信息
    //TODO:其他错误参考BJPMErrorCode 错误码,
    NSError *error = beforeDownloadModel.error;
    BJPMErrorCode errorCode = error.code;
    if(errorCode == BJPMErrorCodeDownloadInvalid) {
        //TODO:加入下载的时候,发生下载链接失效的错误,需要重新获取一次token,再加入下载(调用addDownloadWithVid...或者addDownloadWithClass...)
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD bjp_showMessageThenHide:error.description toView:self.view onHide:nil];
        });
        return;
    }
    if (BJPMErrorCodeNetwork == error.code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *errMsg = [error.userInfo objectForKey:NSLocalizedDescriptionKey] ?: @"";
            NSString *msg = [NSString stringWithFormat:@"没有网络或者未知网络\n错误码:%td \n %@", error.code, errMsg];
            [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
        });
        return;
    }
    
    //下载中会抛出的错误
    NSLog(@"PUVC: downloader.downloadModel.error.description - %@", downloader.downloadModel.error.description);

    NSString *msg1 = downloader.downloadModel.error.localizedDescription;
    NSString *msg2 = error.localizedDescription;
    NSString *msg = @"";
    if (msg1.length > 0 && msg2.length > 0) {
        msg = [NSString stringWithFormat:@"%@ / %@", msg1, msg2];
    }
    else {
        if (msg1.length > 0) {
            msg = msg1;
        }
        else if (msg2.length > 0) {
            msg = msg2;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(msg.length > 0) {
            [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
        }
    });
}

@end
