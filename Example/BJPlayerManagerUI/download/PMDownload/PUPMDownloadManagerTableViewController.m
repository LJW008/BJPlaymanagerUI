//
//  PUPMDownloadManagerTableViewController.m
//  BJPlayerManagerUI_Example
//
//  Created by 辛亚鹏 on 2017/12/13.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import <BJPlayerManagerUI/MBProgressHUD+bjp.h>
#import "PUPMDownloadManagerTableViewController.h"
#import "PUPMDownloadCell.h"

@interface PUPMDownloadManagerTableViewController () <PMDownloadDelegate>
@property (atomic, strong) NSMutableArray *downloadObjectArr;
@end

static NSString *pmCellIdentifier = @"pmdownloadCell";

@implementation PUPMDownloadManagerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PUPMDownloadCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:pmCellIdentifier];
    self.tableView.rowHeight = 90;
    [self initData];
    [self setupBarButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [PMDownloadManager downloadManager].delegate = self;
    [self.tableView reloadData];
}

- (void)initData {
    self.downloadObjectArr = [NSMutableArray array];
    if([[PMDownloadManager downloadManager].downloadingList count]) {
        self.downloadObjectArr = [NSMutableArray arrayWithArray:[PMDownloadManager downloadManager].downloadingList];
    }
    [self.tableView reloadData];
}

- (void)setupBarButton {
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStylePlain target:self action:@selector(startAll:)];
    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithTitle:@"全部暂停" style:UIBarButtonItemStylePlain target:self action:@selector(pauseAll:)];
    UIBarButtonItem *rightItem3 = [[UIBarButtonItem alloc] initWithTitle:@"全部取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAll:)];
    self.navigationItem.rightBarButtonItems = @[rightItem3, rightItem2, rightItem1];
}

- (void)cancelAll:(id)sender {
    NSLog(@"cancelAll: start");
    if(![[PMDownloadManager downloadManager].downloadingList count])
        return;
    NSMutableArray <PMDownloader *> *downloadingList = [NSMutableArray arrayWithArray:[PMDownloadManager downloadManager].downloadingList];
    NSMutableArray <PMDownloader *> *copyDownloadingList = [downloadingList copy];

    if(downloadingList.count <= 0) return;
    for (int i = 0; i < copyDownloadingList.count; i++) {
        PMDownloader * downloader= copyDownloadingList[i];
        if(downloader.downloadModel.downloadFileType == PMDownloadFileType_Video) {
            NSLog(@"cancel vid: %@", downloader.downloadModel.vid);
            [[PMDownloadManager downloadManager] cancelTask:downloader.downloadModel.vid];
        }
        else {
            NSLog(@"cancel classid: %@", downloader.downloadModel.classId);
            [[PMDownloadManager downloadManager] cancelTask:downloader.downloadModel.classId sessionId:downloader.downloadModel.sessionId];
        }
    }
    NSLog(@"cancelAll: end");
    [self initData];
}

- (void)pauseAll:(id)sender {
    NSLog(@"pauseAll: start");
    if(![[PMDownloadManager downloadManager].downloadingList count]) {
        return;
    }
    NSMutableArray <PMDownloader *> *downloadingList = [NSMutableArray arrayWithArray:[PMDownloadManager downloadManager].downloadingList];
    for (int i = 0; i < downloadingList.count; i++) {
        PMDownloader * downloader= downloadingList[i];
        if(downloader.downloadModel.state == PMDownloadState_Start) {
            if(downloader.downloadModel.downloadFileType == PMDownloadFileType_Video) {
                NSLog(@"pause vid: %@", downloader.downloadModel.vid);
                [[PMDownloadManager downloadManager] pause:downloader.downloadModel.vid];
            }
            else {
                NSLog(@"pause classid: %@", downloader.downloadModel.classId);
                [[PMDownloadManager downloadManager] pause:downloader.downloadModel.classId sessionId:downloader.downloadModel.sessionId];
            }
        }
    }
    NSLog(@"pauseAll: end");
    [self initData];
}

- (void)startAll:(id)sender {
    NSLog(@"startAll: start");
    if(![[PMDownloadManager downloadManager].downloadingList count]) {
        return;
    }
    NSMutableArray <PMDownloader *> *downloadingList = [NSMutableArray arrayWithArray:[PMDownloadManager downloadManager].downloadingList];
    for (int i = 0; i < downloadingList.count; i++) {
        PMDownloader * downloader= downloadingList[i];
        if(downloader.downloadModel.state == PMDownloadState_Suspended || downloader.downloadModel.state == PMDownloadState_Failed) {
            if(downloader.downloadModel.downloadFileType == PMDownloadFileType_Video) {
                NSLog(@"start vid:%@", downloader.downloadModel.vid);
                [[PMDownloadManager downloadManager] resume:downloader.downloadModel.vid];
            }
            else {
                NSLog(@"start classid:%@", downloader.downloadModel.classId);
                [[PMDownloadManager downloadManager] resume:downloader.downloadModel.classId sessionId:downloader.downloadModel.sessionId];
            }
        }
    }
    NSLog(@"startAll: end");
    [self initData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadObjectArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PUPMDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:pmCellIdentifier  forIndexPath:indexPath];
    if(indexPath.row < self.downloadObjectArr.count) {
        PMDownloader *downloader = [self.downloadObjectArr objectAtIndex:indexPath.row];
        [cell setModel:downloader];
        return cell;
    }
    else {
        return [UITableViewCell new];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMDownloader *downloader = [self.downloadObjectArr objectAtIndex:indexPath.row];
    if (downloader.downloadModel.downloadFileType == PMDownloadFileType_Video) {
        [[PMDownloadManager downloadManager] cancelTask:downloader.downloadModel.vid];
    }
    else if (downloader.downloadModel.downloadFileType == PMDownloadFileType_Playback){
        [[PMDownloadManager downloadManager] cancelTask:downloader.downloadModel.classId sessionId:downloader.downloadModel.sessionId];
    }
//    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self initData];
}

- (void)finishedUpdateDownloadCell:(PMDownloader *)downloader {
    [self initData];
    NSString *msg = [downloader.downloadModel.videoFileName stringByAppendingString:@" 下载完成"];;
    [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
}

- (void)updateDownloadCell:(PMDownloader *)downloader {
    NSArray *cellArr = [self.tableView visibleCells];
    if (downloader.downloadModel.error) {
        NSLog(@"xinyapeng : %s, downloer.error = %@", __func__, downloader.downloadModel.error);
    }
    for (id obj in cellArr) {
        if([obj isKindOfClass:[PUPMDownloadCell class]]) {
            PUPMDownloadCell *cell = (PUPMDownloadCell *)obj;
            if([cell.nameLabel.text isEqualToString:downloader.downloadModel.videoFileName]) {
                [cell setModel:downloader];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - download delagate

- (void)startDownload:(PMDownloader *)downloader {
    NSLog(@"TableView: %s", __func__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD bjp_closeLoadingView:self.view];
    });

    [self performSelectorOnMainThread:@selector(initData) withObject:nil waitUntilDone:YES];
}

- (void)updateProgress:(PMDownloader *)downloader {
//    NSLog(@"TableView: %s", __func__);
    [self performSelectorOnMainThread:@selector(updateDownloadCell:) withObject:downloader waitUntilDone:YES];
}

- (void)finishedDownload:(PMDownloader *)downloader {
//    NSLog(@"TableView: %s", __func__);
    [self performSelectorOnMainThread:@selector(finishedUpdateDownloadCell:) withObject:downloader waitUntilDone:YES];
}

- (void)downloadFail:(nullable PMDownloader *)downloader beforeDownloadError:(nullable PMBeforeDownloadModel *)beforeDownloadModel {
  
//    !!!:对于已经加入下载的任务,resume的时候如果发生了下载前的token错误是需要调用resetDownloadWithDownloader...方法的
    //下载前的错误信息:下载前主要是会检测一下传入的token参数是否能获取到正确的url,如果不能会抛出错误
    //下载前会检测token,这里可能会需要时间检测,建议此处加上loading
//    !!!:PMDownloadURLCheckState_Checking表示检测中,PMDownloadURLCheckState_Complete表示检测完\
//    检测完,如果有error, 也会在beforeDownloadModel.error中包含,
    NSError *error = beforeDownloadModel.error;
    BJPMErrorCode errorCode = error.code;
    if(beforeDownloadModel) {
        if(beforeDownloadModel.urlCheckState == PMDownloadURLCheckState_Checking) {//表示正在检测中
            //ui thred loading
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD bjp_showLoading:@"" toView:self.view];
            });
            return;
        }
        else if (beforeDownloadModel.urlCheckState == PMDownloadURLCheckState_Complete) {//表示检测完
            if(errorCode == BJPMErrorCodeDownloadInvalid) {
                //TODO:下载的URL失效时,上层需要传一个新的token.Demo此处暂不处理,需客户自己提供
                //        !!!:此处token需要客户获取一个新的token,test12345678仅供内部测试使用
                
                //1-可以给提示要重传token
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD bjp_showMessageThenHide:@"重传token" toView:self.view onHide:nil];
//                });
                //或者直接重新设置token
                [[PMDownloadManager downloadManager] resetDownloadWithDownloader:downloader token:@"test12345678"];
            }
            else {
                // ui thread  remove loading
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD bjp_closeLoadingView:self.view];
                });
            }
        }
        else {//下载前的其他错误
            // ui thread  remove loading
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errMsg = [error.userInfo objectForKey:NSLocalizedDescriptionKey] ?: @"";
                NSString *msg = [NSString stringWithFormat:@"错误码:%td \n %@", error.code, errMsg];
                [MBProgressHUD bjp_showMessageThenHide:msg toView:self.view onHide:nil];
                
                NSArray *cellArr = [self.tableView visibleCells];
                for (id obj in cellArr) {
                    if([obj isKindOfClass:[PUPMDownloadCell class]]) {
                        PUPMDownloadCell *cell = (PUPMDownloadCell *)obj;
                        if([cell.nameLabel.text isEqualToString:downloader.downloadModel.videoFileName]) {
                            if (error) {
                                cell.sizeLabel.text = error.localizedDescription;
                                cell.pauseBtn.selected = YES;
                            }
                            else {
                                [cell setModel:downloader];
                            }
                        }
                    }
                }

            });
        }
        return;
    }
    
    //下载中的错误处理...

    //如果下载中出现-1005的错误,是sessiontask返回的错误,可以再次resume来解决下载失败的问题
    if(downloader && downloader.downloadModel.state == PMDownloadState_Failed && downloader.downloadModel.error.code == -1005) {
        if(downloader.downloadModel.downloadFileType == PMDownloadFileType_Video) {
            NSLog(@"start vid:%@", downloader.downloadModel.vid);
//            [[PMDownloadManager downloadManager] resume:downloader.downloadModel.vid];
        }
        else {
            NSLog(@"start classid:%@", downloader.downloadModel.classId);
//            [[PMDownloadManager downloadManager] resume:downloader.downloadModel.classId sessionId:downloader.downloadModel.sessionId];
        }
    }

    if (downloader.downloadModel.error) {
        NSLog(@"xinyapeng: downloader.downloadModel.error.description - %@", downloader.downloadModel.error.description);
    }
    if (beforeDownloadModel.error) {
        NSLog(@"xinyapeng: beforeDownloadModel.error %@", error.description);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *cellArr = [self.tableView visibleCells];
        for (id obj in cellArr) {
            if([obj isKindOfClass:[PUPMDownloadCell class]]) {
                PUPMDownloadCell *cell = (PUPMDownloadCell *)obj;
                if([cell.nameLabel.text isEqualToString:downloader.downloadModel.videoFileName]) {
                    if (error) {
                        cell.sizeLabel.text = error.localizedDescription;
                        cell.pauseBtn.selected = YES;
                    }
                    else {
                        [cell setModel:downloader];
                    }
                }
            }
        }
    });
}

@end
