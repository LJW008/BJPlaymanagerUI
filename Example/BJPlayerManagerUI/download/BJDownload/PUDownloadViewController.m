//
//  PUDownloadViewController.m
//  BJPlayerManagerUI
//
//  Created by 辛亚鹏 on 2017/9/19.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>
#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import <BJPlayerManagerUI/MBProgressHUD+bjp.h>
#import "PUDownloadManagerViewController.h"
#import "PULocalListTableViewController.h"

#import "PUDownloadViewController.h"
#import "PUAppDelegate.h"

@interface PUDownloadViewController ()< BJDownloadDelegate>


@property (weak, nonatomic) IBOutlet UITextField *vidTF;
@property (weak, nonatomic) IBOutlet UITextField *tokenTF;
@property (weak, nonatomic) IBOutlet UITextField *sessionIDTF;
@property (weak, nonatomic) IBOutlet UILabel *definitionLabel;
@property (weak, nonatomic) IBOutlet UITextField *definitionTF;

@end

@implementation PUDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    @weakify(self);
    [[self.definitionTF rac_signalForControlEvents:UIControlEventEditingDidEnd | UIControlEventEditingDidEndOnExit] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (![self isNumber:self.definitionTF.text]) {
            [MBProgressHUD bjp_showMessageThenHide:@"请输入0到4的数字" toView:self.view onHide:nil];
        }
    }];

//    [BJDownloadManager sharedDownloadManager].downloadAlertBlock = ^BOOL(BJDownloadAlertType alertType) {
//        @strongify(self);
//        if (alertType == BJDownloadAlertType_Completed) {
//            [MBProgressHUD bjp_showMessageThenHide:@"已经下载完成" toView:self.view onHide:nil];
//            return NO;
//        }
//        if (alertType == BJDownloadAlertType_Queue) {
//            [MBProgressHUD bjp_showMessageThenHide:@"已经在下载列表" toView:self.view onHide:nil];
//            return NO;
//        }
//        return YES;
//    };


    self.vidTF.text = @"11234924";
    self.tokenTF.text = @"MG3rdif24dhNV8ralNcYMp91ZQzaPh0oUWS-ipEH22q6MWvRSkAXPQ";

    [BJDownloadManager sharedDownloadManager].downloadDelegate = self;

    //线上回放下载
    self.vidTF.text = @"18052364683771";
    self.sessionIDTF.text = @"201806072";
    self.tokenTF.text = @"B-UNvRAk15hNV8ralNcYMtDJCVO2ZMRY_aebota0jc1TW6an_7BLsQgqTrePME3XK2CcjdGCgTQKp0fXMnVKLQ";

//    self.vidTF.text = @"11043598";
//    self.sessionIDTF.text = nil;
//    self.tokenTF.text = @"axxH4tfK_8kwXbbKg3_HD9k5_RfnTyw_23Jh8czx4LtxG4b8QqrUdw";

    self.definitionTF.text = @"0,1,2,3,4,5";

//    self.vidTF.text = @"196625";
//    self.tokenTF.text = @"test12345678";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [BJDownloadManager sharedDownloadManager].maxCount = 30;
    [BJDownloadManager sharedDownloadManager].downloadDelegate = self;

}
- (IBAction)setBlock:(id)sender {
//    @weakify(self);
//    [BJDownloadManager sharedDownloadManager].downloadAlertBlock = ^BOOL(BJDownloadAlertType alertType) {
//        @strongify(self);
//        if (alertType == BJDownloadAlertType_Completed) {
//            [MBProgressHUD bjp_showMessageThenHide:@"已经下载完成" toView:self.view onHide:nil];
//            return NO;
//        }
//        if (alertType == BJDownloadAlertType_Queue) {
//            [MBProgressHUD bjp_showMessageThenHide:@"已经在下载列表" toView:self.view onHide:nil];
//            return NO;
//        }
//        return YES;
//    };
}
- (IBAction)cancelBlock:(id)sender {
//    [BJDownloadManager sharedDownloadManager].downloadAlertBlock = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getDefinition:(id)sender {
    @weakify(self);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BJPlayerManager managerWithType:BJPlayerManagerType_AVPlayer] getVideoInfoWithVid:self.vidTF.text token:self.tokenTF.text completion:^(PMVideoInfoModel * _Nullable videoInfo, NSError * _Nullable error) {
        @strongify(self);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [MBProgressHUD bjp_showMessageThenHide:[error description] toView:self.view onHide:nil];
            self.definitionLabel.text = @"获取失败";
            return ;
        }
        NSString *definitionStr = @"";
        for (PMVideoDefinitionInfoModel *model in videoInfo.definitionList) {
            definitionStr = [definitionStr stringByAppendingString:[NSString stringWithFormat:@" %@", model.definition]];
        }
        self.definitionLabel.text = definitionStr;
    }];
}
- (IBAction)playbackDownload:(id)sender {
    //www
//    [[BJDownloadManager sharedDownloadManager] downloadWithClassId:@"18032152043105" sessionId:nil token:@"nZiHYOWrCbQ3S3PxCaNtta8B8RNlGC3dLlOERyZym7B33Hd623cMcg" definitionType:1 showFileName:@"playback"];
    
    //test
//    [[BJDownloadManager sharedDownloadManager] downloadWithClassId:@"18021291876920" sessionId:nil token:@"z73x1s77oYC9cWOOu4-mn15NVcu8X3rO3eClAhUysuNfjiIOEGU98Q" definitionType:1 showFileName:@"playback"];
    [[BJDownloadManager sharedDownloadManager] downloadWithClassId:self.vidTF.text sessionId:self.sessionIDTF.text token:self.tokenTF.text definitionType:[self.definitionTF.text integerValue] showFileName:@"playback"];

}

- (IBAction)download:(id)sender {
    [[BJDownloadManager sharedDownloadManager] downloadWithVid:self.vidTF.text token:self.tokenTF.text definitionType:[self.definitionTF.text integerValue] showFileName:@"customerName"];
    return;
    
    NSArray *vidArray = @[@"8858803",
                          @"8858809",
                          @"8858825",
                          @"8858931",
                          @"8858934",
//                          @"8858944",
//                          @"8858956",
//                          @"8858963",
//                          @"8859024",
//                          @"8859030",
//                          @"8859034",
//                          @"8859042",
//                          @"8859063",
//                          @"8859080",
//                          @"8859115",
//                          @"8859165",
//                          @"8859185",
//                          @"8859218",
//                          @"8859441",
//                          @"8859500",
//                          @"8859511",
//                          @"8992195",
//                          @"8992197",
//                          @"8992259",
                          ];
    NSArray *tokenArray = @[@"hIExVeSyq2pMyA0LsBVeTI2XgX3R-lJgNvym64-ZPCmGHUs6gMVBgg",
                            @"BUalGMb6AeBMyA0LsBVeTC7izJ06Fl5aoNqMvPl3yfW0adbuHS95zw",
                            @"QjT5Tcna70pMyA0LsBVeTAoKD7IZr7fkoNqMvPl3yfUJrZ1EEuQicw",
                            @"yYcvYnHJmsVMyA0LsBVeTFI3JYpgtHQooNqMvPl3yfVKh4QFHL-pCQ",
                            @"q0gMB0s90uC7WzcaucHR9oWjOMwBvaciqU7cO3BSAKUFMpDdV0GS3Q",
//                            @"jswPivhJ2xNMyA0LsBVeTE_IJGWg0yFDoNqMvPl3yfWqFE0iFmHCLA",
//                            @"TLQEEeyb6CtMyA0LsBVeTI1fq3_YtKoqoNqMvPl3yfXeaR9YN3lH4g",
//                            @"CkPPvcwmL9lMyA0LsBVeTF4_63qiz8GaNvym64-ZPCmGHUs6gMVBgg",
//                            @"PqeMKtN5zF9MyA0LsBVeTDUtXPelLOHXNvym64-ZPCmGHUs6gMVBgg",
//                            @"RutsR-66cAVMyA0LsBVeTBOJx-FiFt0rNvym64-ZPCmGHUs6gMVBgg",
//                            @"ZwivroLvFDlMyA0LsBVeTJzBreJBS53JNvym64-ZPCmGHUs6gMVBgg",
//                            @"mQHwNHJ5i35MyA0LsBVeTKQl6hoFiyCSNvym64-ZPCmGHUs6gMVBgg",
//                            @"P1ux-0BdTnFMyA0LsBVeTJmQhJZo92T2Nvym64-ZPCmGHUs6gMVBgg",
//                            @"eBU3pTR48uBMyA0LsBVeTKOO3mL3KZ_3Nvym64-ZPCmGHUs6gMVBgg",
//                            @"Bb7UGo1L4ABMyA0LsBVeTDL1UHMENNojNvym64-ZPCmGHUs6gMVBgg",
//                            @"qjeNXuL3wSZMyA0LsBVeTL4r7CMiBYl_Nvym64-ZPCmGHUs6gMVBgg",
//                            @"0kuWDmF1BCpMyA0LsBVeTGxSfICioxJWNvym64-ZPCmGHUs6gMVBgg",
//                            @"58cxakjxLZpMyA0LsBVeTB47O2EXSXukNvym64-ZPCmGHUs6gMVBgg",
//                            @"pC5xcEKw6iZMyA0LsBVeTO_EQVw8GFJGNvym64-ZPCmGHUs6gMVBgg",
//                            @"dGKMhxxH8mdMyA0LsBVeTCfcA5gp_lBENvym64-ZPCmGHUs6gMVBgg",
//                            @"y4LqgjYPngFMyA0LsBVeTDGPwH4hwV3VNvym64-ZPCmGHUs6gMVBgg",
//                            @"24FkI8TrRrVMyA0LsBVeTBpzWCwdkRYwNvym64-ZPCmGHUs6gMVBgg",
//                            @"2auaJUkmH9BMyA0LsBVeTOMppfiVr_ZPNvym64-ZPCmGHUs6gMVBgg",
//                            @"ab-XLit2UmBMyA0LsBVeTISnMWqNdAJeNvym64-ZPCmGHUs6gMVBgg",
                            ];
    
    for(NSInteger i = 0;i< vidArray.count;i++){
        [[BJDownloadManager sharedDownloadManager] downloadWithVid:[vidArray objectAtIndex:i] token:tokenArray[i] definitionType:2 showFileName:@"customerName"];
    }
}

- (IBAction)downloadManager:(id)sender {
    [self.navigationController pushViewController:[PUDownloadManagerViewController new] animated:YES];
}

- (IBAction)localVideo:(id)sender {
    [self.navigationController pushViewController:[PULocalListTableViewController new] animated:YES];
}

- (BOOL)isNumber:(NSString *)str {
    if (str.length == 1  && ([str integerValue] <= 4) && ([str integerValue] >= 0)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)requestFailBeforeDowndownError:(BJBeforeDownloadModel *)beforeDownload
                      downloadingError:(BJHttpRequest *)request {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *errorDes = [NSString stringWithFormat:@"beforeDownload.error : %@, \n request.error: %@, \n request.responseStatusCode = %d",
                              [beforeDownload.error description], request.error, request.responseStatusCode];
        [MBProgressHUD bjp_showMessageThenHide:errorDes toView:self.view onHide:nil];
    });
}

@end
