//
//  PULocalVideoListTableViewController.m
//  BJPlayerManagerUI_Example
//
//  Created by 辛亚鹏 on 2017/12/13.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import <BJPlayerManagerUI/MBProgressHUD+bjp.h>
#import <BJPlaybackUI/BJPlaybackUI.h>

#import "PULocalVideoListTableViewController.h"
#import "PUPlayViewController.h"

static NSString *pmLocalVideolistCell = @"pmLocalVideolistCell";

@interface PULocalVideoListTableViewController ()

@property (nonatomic) NSMutableArray <PMDownloadModel *> *arrM;

@end

@implementation PULocalVideoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:pmLocalVideolistCell];
    
    [self setupBarButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initData];
}

- (void)initData {
    self.arrM = @[].mutableCopy;
    if([[PMDownloadManager downloadManager].finishedList count]) {
        self.arrM = [NSMutableArray arrayWithArray:[PMDownloadManager downloadManager].finishedList];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBarButton {
    UIBarButtonItem *rightItem3 = [[UIBarButtonItem alloc] initWithTitle:@"全部删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAll:)];
    self.navigationItem.rightBarButtonItems = @[rightItem3];
}

- (void)deleteAll:(id)sender {
    NSLog(@"deleteAll: start");
    if(![[PMDownloadManager downloadManager].finishedList count])
        return;
    NSMutableArray <PMDownloadModel *> *finishedList = [NSMutableArray arrayWithArray:[PMDownloadManager downloadManager].finishedList];
    NSMutableArray <PMDownloadModel *> *copyFinishedList = [finishedList copy];
    
    if(copyFinishedList.count <= 0) return;
    for (int i = 0; i < copyFinishedList.count; i++) {
        PMDownloadModel * downloader= copyFinishedList[i];
        if(downloader.downloadFileType == PMDownloadFileType_Video) {
            NSLog(@"delete vid: %@", downloader.vid);
            [[PMDownloadManager downloadManager] deleteFile:downloader.vid];
        }
        else {
            NSLog(@"delete classid: %@", downloader.classId);
            [[PMDownloadManager downloadManager] deleteFile:downloader.classId sessionId:downloader.sessionId];
        }
    }
    NSLog(@"delete: end");
    [self initData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:pmLocalVideolistCell forIndexPath:indexPath];
    PMDownloadModel *model = [self.arrM objectAtIndex:indexPath.row];
    cell.textLabel.text = model.videoFileName;
    cell.imageView.image = [UIImage imageWithContentsOfFile:model.imagePath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PMDownloadModel *model = [self.arrM objectAtIndex:indexPath.row];
    if (model.downloadFileType == PMDownloadFileType_Video) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *avplayerAction = [UIAlertAction actionWithTitle:@"avplayer" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            PUPlayViewController *vc = [[PUPlayViewController alloc] initWithPath:model.videoPath definitionType:model.definitionType playerType:PUPlayerType_AVPlayer];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [alert addAction:avplayerAction];
        UIAlertAction *ijkAction = [UIAlertAction actionWithTitle:@"ijkplayer" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            PUPlayViewController *vc = [[PUPlayViewController alloc] initWithPath:model.videoPath definitionType:model.definitionType playerType:PUPlayerType_IJKPlayer];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [alert addAction:ijkAction];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            nil;
        }]];

        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (model.downloadFileType == PMDownloadFileType_Playback) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *avplayerAction = [UIAlertAction actionWithTitle:@"avplayer" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            BJPRoomViewController *vc = [BJPRoomViewController localVideoCreatRoomWithVideoPath:model.videoPath signalPath:model.signalPath definition:model.definitionType isZip:YES PlayerManagerType:BJPlayerManagerType_AVPlayer];
            BJPlayerManager *playerControl = vc.room.playbackVM.playerControl;
            playerControl.playTimeRecordEnabled = YES;
            playerControl.ignorableRemainingTimeInterval = 4.0;
            [self presentViewController:vc animated:YES completion:nil];
        }];
        [alert addAction:avplayerAction];
        UIAlertAction *ijkAction = [UIAlertAction actionWithTitle:@"ijkplayer" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            BJPRoomViewController *vc = [BJPRoomViewController localVideoCreatRoomWithVideoPath:model.videoPath signalPath:model.signalPath definition:model.definitionType isZip:YES PlayerManagerType:BJPlayerManagerType_IJKPlayer];
            BJPlayerManager *playerControl = vc.room.playbackVM.playerControl;
            playerControl.playTimeRecordEnabled = YES;
            playerControl.ignorableRemainingTimeInterval = 4.0;
            [self presentViewController:vc animated:YES completion:nil];
        }];
        [alert addAction:ijkAction];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            nil;
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
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
    PMDownloadModel *model = [self.arrM objectAtIndex:indexPath.row];
    if (model.downloadFileType == PMDownloadFileType_Video) {
        if(![[PMDownloadManager downloadManager] deleteFile:model.vid]) {
            [MBProgressHUD bjp_showMessageThenHide:@"点播 - 删除失败" toView:self.view onHide:nil];
            return;
        }
    }
    else if (model.downloadFileType == PMDownloadFileType_Playback){
        if(![[PMDownloadManager downloadManager] deleteFile:model.classId sessionId:model.sessionId]) {
            [MBProgressHUD bjp_showMessageThenHide:@"回放 - 删除失败" toView:self.view onHide:nil];
            return;
        }
    }
    [self initData];
}

@end
