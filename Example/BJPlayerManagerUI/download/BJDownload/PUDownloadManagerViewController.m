//
//  PUDownloadManagerViewController.m
//  BJPlayerManagerUI
//
//  Created by 辛亚鹏 on 2017/9/19.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import "PUDownloadManagerViewController.h"
#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import <BJPlayerManagerUI/BJPlayerManagerUI.h>
#import "BJDownloadingTableViewCell.h"
#import "BJDownloadedTableViewCell.h"
#import <BJPlayerManagerCore/BJHttpRequest.h>
#import <Masonry/Masonry.h>
#import "PUAppDelegate.h"

#define  DownloadManager  [BJDownloadManager sharedDownloadManager]

@interface PUDownloadManagerViewController ()<BJDownloadDelegate,UITableViewDataSource,UITableViewDelegate>

@property ( nonatomic) UITableView *tableView;
@property (atomic, strong) NSMutableArray *downloadObjectArr;

@property (nonatomic) BOOL textCompleted, livebackVideoCompleted;

@end

@implementation PUDownloadManagerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 更新数据源
    [self initData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [UITableView new] ;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70;

    DownloadManager.downloadDelegate = self;
    [self.tableView registerClass:[BJDownloadingTableViewCell class] forCellReuseIdentifier:@"downloadingCell"];

    [self setupBarButton];
}

- (void)setupBarButton {

    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStylePlain target:self action:@selector(startAll:)];
    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithTitle:@"全部暂停" style:UIBarButtonItemStylePlain target:self action:@selector(pauseAll:)];
    UIBarButtonItem *rightItem3 = [[UIBarButtonItem alloc] initWithTitle:@"全部删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAll:)];
    self.navigationItem.rightBarButtonItems = @[rightItem2, rightItem1, rightItem3];
}

- (void)initData
{
    [DownloadManager startLoad];
    NSMutableArray *downladed = DownloadManager.finishedlist;
    NSMutableArray *downloading = DownloadManager.downinglist;
    self.downloadObjectArr = @[].mutableCopy;
    [self.downloadObjectArr addObject:downladed];
    [self.downloadObjectArr addObject:downloading];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = self.downloadObjectArr[section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        BJDownloadedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadedCell"];
        if (!cell) {
            cell = [[BJDownloadedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"downloadedCell"];
        }
        BJFileModel *fileInfo = self.downloadObjectArr[indexPath.section][indexPath.row];
        cell.fileInfo = fileInfo;
        return cell;
    } else if (indexPath.section == 1) {
        BJDownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadingCell"];
        if (!cell) {
            cell = [[BJDownloadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"downloadingCell"];
        }
        BJHttpRequest *request = self.downloadObjectArr[indexPath.section][indexPath.row];
        if (request == nil) { return nil; }
        BJFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
        
        __weak typeof(self) weakSelf = self;
        // 下载按钮点击时候的要刷新列表
        cell.btnClickBlock = ^{
            [weakSelf initData];
        };
        // 下载模型赋值
        cell.fileInfo = fileInfo;
        // 下载的request
        cell.request = request;
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if(indexPath.row >= 0 && indexPath.row < [self.downloadObjectArr[indexPath.section] count]) {
            BJFileModel *fileInfo = self.downloadObjectArr[indexPath.section][indexPath.row];
            if(fileInfo.downloadState == BJDownloadedError) {
                //文件下载损坏
                if([DownloadManager reDownloadFile:fileInfo]) {
                    NSLog(@"重新下载OK");
                }
                else {
                    NSLog(@"重新下载失败");
                }
                [self initData];
            }
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    if (indexPath.section == 0) {
        BJFileModel *fileInfo = self.downloadObjectArr[indexPath.section][indexPath.row];
        [DownloadManager deleteFinishFile:fileInfo];
    }else if (indexPath.section == 1) {
        BJHttpRequest *request = self.downloadObjectArr[indexPath.section][indexPath.row];
        [DownloadManager deleteRequest:request];
    }
    [self initData];
//    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @[@"下载完成",@"下载中"][section];
}

#pragma mark - BJDownloadDelegate

// 开始下载
- (void)startDownload:(BJHttpRequest *)request
{
    NSLog(@"startDownload ==> request = %@", [request description]);


}

// 下载中
- (void)updateCellProgress:(BJHttpRequest *)request
{
    BJFileModel *fileInfo = [request.userInfo objectForKey:@"File"];

    if ( fileInfo.downloadFileType == BJDownloadFileType_LiveVideo ) {
        [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
    }
}

// 下载完成
- (void)finishedDownload:(BJHttpRequest *)request
{
    NSLog(@"finishedDownload ==> request = %@", [request description]);
    [self initData];

    BJFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    if (fileInfo.downloadFileType == BJDownloadFileType_LiveVideo) {
        self.livebackVideoCompleted = YES;
    }

    if (fileInfo.downloadFileType == BJDownloadFileType_Text) {
        self.textCompleted = YES;
    }
}

- (void)requestFailBeforeDowndownError:(BJBeforeDownloadModel *)beforeDownloadError  downloadingError:(BJHttpRequest *)request {
    
    //beforeDownloadError: 开始下载之前发生的error, error.code参考错误码
    //request.error: 下载过程中发生的error,
    
//    if(beforeDownloadError && beforeDownloadError.urlCheckState != BJDownloadURLCheckState_Checking && beforeDownloadError.urlCheckState != BJDownloadURLCheckState_Complete) {
//        NSLog(@"download error ==> beforeDownloadError = %@ \n", [beforeDownloadError description]);
//    }
//
//    if(request && request.error) {
//        NSLog(@"downloading - request = %@", [request description]);
//    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *errorDes = [NSString stringWithFormat:@"beforeDownload.error : %@, \n request.error: %@, \n request.responseStatusCode = %d",
                              [beforeDownloadError.error description], request.error, request.responseStatusCode];
        [MBProgressHUD bjp_showMessageThenHide:errorDes toView:self.view onHide:nil];
    });
    
    //1010是下载的url失效, 需要调用resetDownloadWithRequest:request token:@"" downloadTyope:];
    //点播下载:BJDownloadFileType_Video  回放下载:BJDownloadFileType_LivePlayback
    if (beforeDownloadError.error.code == 1010) {
        NSLog(@"error = %@", beforeDownloadError.error.description);
        BJFileModel *fileInfo = (BJFileModel *)[request.userInfo objectForKey:@"File"];
        if(fileInfo.downloadFileType == BJDownloadFileType_Video) {
            [DownloadManager resetDownloadWithRequest:request token:@"test12345678" downloadTyope:BJDownloadFileType_Video];
        }
        else if(fileInfo.downloadFileType == BJDownloadFileType_LiveVideo) {
            [DownloadManager resetDownloadWithRequest:request token:@"test12345678" downloadTyope:BJDownloadFileType_LiveVideo];
        }
    }
    
    if (beforeDownloadError) {
        if (beforeDownloadError.urlCheckState == BJDownloadURLCheckState_Checking) {
//            [MBProgressHUD bjp_showLoading:@"正在检测下载的url的有效性" toView:self.view];
        }
        else if (beforeDownloadError.urlCheckState == BJDownloadURLCheckState_Complete) {
//            [MBProgressHUD bjp_showMessageThenHide:@"url检测完成" toView:self.view onHide:nil];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }
}

// 更新下载进度
- (void)updateCellOnMainThread:(BJFileModel *)fileInfo
{
    NSArray *cellArr = [self.tableView visibleCells];
    for (id obj in cellArr) {
        if([obj isKindOfClass:[BJDownloadingTableViewCell class]]) {
            BJDownloadingTableViewCell *cell = (BJDownloadingTableViewCell *)obj;
            if([cell.fileInfo.fileURL isEqualToString:fileInfo.fileURL]) {
                cell.fileInfo = fileInfo;


                float progress = (float)[fileInfo.fileReceivedSize longLongValue] / [fileInfo.fileSize longLongValue];
                if (progress > 98) {
                    if (self.textCompleted && self.livebackVideoCompleted) {
                        //两个都下载完的时候, 视频下载显示 100 %
                    }
                    else {
                        //这里可以在ui上一直显示视频下载98%
                    }
                }
            }
        }
    }
}

- (void)startAll:(id)sender {
    NSMutableArray<BJHttpRequest *> *downinglist = DownloadManager.downinglist;
    [downinglist enumerateObjectsUsingBlock:^(BJHttpRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [DownloadManager resumeRequest:obj];
    }];
    [self initData];

}

- (void)pauseAll:(id)sender {
    [DownloadManager pauseAllDownloads];
    [self initData];

}

- (void)deleteAll:(id)sender {
    //全选删除用clearAllRquests
//    if([DownloadManager clearAllRquests]) {
//        [MBProgressHUD bjp_showMessageThenHide:@"删除成功" toView:self.view onHide:nil];
//    }
//    else {
//        [MBProgressHUD bjp_showMessageThenHide:@"删除失败" toView:self.view onHide:nil];
//    }
//    return;
    
    //加入想尝试多选删除,注意request
    NSMutableArray<BJHttpRequest *> *downinglist = DownloadManager.downinglist;
    
    NSMutableArray<BJHttpRequest *> *downloading = [downinglist copy];
    for (int i = 0; i < downloading.count; i++) {
        BJHttpRequest *request = [downloading objectAtIndex:i];
        BJFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
        NSLog(@"file name:%@", fileInfo.fileName);
        [DownloadManager deleteRequest:request];
    }
    [self.tableView reloadData];
}
@end
