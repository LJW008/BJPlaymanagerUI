//
//  PULocalListTableViewController.m
//  BJPlayerManagerUI
//
//  Created by 辛亚鹏 on 2017/9/19.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import <BJPlayerManagerCore/BJDownloadManager.h>
#import <BJPlaybackUI/BJPlaybackUI.h>

#import "PULocalListTableViewController.h"
#import "PUPlayViewController.h"

@interface PULocalListTableViewController ()

@property (atomic, strong) NSArray *downloadObjectArr;

@end

@implementation PULocalListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.downloadObjectArr = [BJDownloadManager sharedDownloadManager].finishedlist;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadObjectArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJFileModel *model = [self.downloadObjectArr objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"list"];
    
    if(model.downloadState == BJDownloadedError) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@-下载出错", model.fileName];
    }
    else {
        cell.textLabel.text = model.fileName;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BJFileModel *model = [self.downloadObjectArr objectAtIndex:indexPath.row];
    if (model.downloadFileType == BJDownloadFileType_Video) {
        PUPlayViewController *vc = [[PUPlayViewController alloc] initWithPath:model.filePath definitionType:model.definionType playerType:PUPlayerType_AVPlayer];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (model.downloadFileType == BJDownloadFileType_LiveVideo) {
        NSString *tempFrontStr = [[model.fileName componentsSeparatedByString:@"."] firstObject];
        NSString *signalPath = @"";
        for (BJFileModel *fileModel in self.downloadObjectArr) {
            if (fileModel.downloadFileType == BJDownloadFileType_Text && [fileModel.fileName containsString:tempFrontStr]) {
                signalPath = fileModel.filePath;
                break;
            }
        }
        BJPRoomViewController *vc = [BJPRoomViewController localVideoCreatRoomWithVideoPath:model.filePath
                                                                                 signalPath:signalPath definition:model.definionType isZip:YES];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
