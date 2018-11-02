//
//  PUPMDownloadCell.m
//  BJPlayerManagerUI_Example
//
//  Created by 辛亚鹏 on 2017/12/13.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import "PUPMDownloadCell.h"

@implementation PUPMDownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)pause:(UIButton *)sender {
//    sender.selected = !sender.selected;
    
    if (self.downloader.downloadModel.downloadFileType == PMDownloadFileType_Playback) {
        
        if (self.downloader.downloadModel.state == PMDownloadState_Start) {
            sender.selected = YES;
            [[PMDownloadManager downloadManager] pause:self.downloader.downloadModel.classId sessionId:self.downloader.downloadModel.sessionId];
            self.sizeLabel.text = @"暂停";
        }
        else if (self.downloader.downloadModel.state == PMDownloadState_Suspended
                 || self.downloader.downloadModel.state == PMDownloadState_Failed) {
            sender.selected = NO;
            [[PMDownloadManager downloadManager] resume:self.downloader.downloadModel.classId sessionId:self.downloader.downloadModel.sessionId];
        }
        
    }
    else if (self.downloader.downloadModel.downloadFileType == PMDownloadFileType_Video) {
        if (self.downloader.downloadModel.state == PMDownloadState_Start) {
            sender.selected = YES;
            [[PMDownloadManager downloadManager] pause:self.downloader.downloadModel.vid];
            self.sizeLabel.text = @"暂停";
        }
        else if (self.downloader.downloadModel.state == PMDownloadState_Suspended
                 || self.downloader.downloadModel.state == PMDownloadState_Failed) {
            sender.selected = NO;
            [[PMDownloadManager downloadManager] resume:self.downloader.downloadModel.vid];
        }
    }
}

- (void)setModel:(PMDownloader *)downloader {
    self.downloader = downloader;
    self.nameLabel.text = downloader.downloadModel.videoFileName;
    NSString *totalSize = [self getFileSizeString:downloader.downloadModel.totalLength];
    NSString *receiveSize = [self getFileSizeString:downloader.downloadModel.receivedSize];
    float progress = (float)downloader.downloadModel.receivedSize / downloader.downloadModel.totalLength;
    if(downloader.downloadModel.totalLength == 0) {
        progress = 0;
    }
    if(progress > 1.0) {
        progress = 1.0;
    }
    
    if (downloader.downloadModel.state == PMDownloadState_Start) {
        self.sizeLabel.text  = [NSString stringWithFormat:@"%@ / %@ (%.2f%%)",receiveSize, totalSize, progress*100];
        self.pauseBtn.selected = NO;
    }
    else if(downloader.downloadModel.state == PMDownloadState_Failed){
        self.sizeLabel.text = @"下载失败";
        self.pauseBtn.selected = YES;
    }
    else if (self.downloader.downloadModel.state == PMDownloadState_Suspended) {
        self.pauseBtn.selected = YES;
        self.sizeLabel.text = @"暂停";
    }
    self.progress.progress = progress;
}

- (NSString *)getFileSizeString:(float)size {
    
    if(size >=1024*1024)//大于1M，则转化成M单位的字符串
    {
        return [NSString stringWithFormat:@"%1.2fM",size/1024/1024];
    }
    else if(size >=1024 && size<1024*1024) //不到1M,但是超过了1KB，则转化成KB单位
    {
        return [NSString stringWithFormat:@"%1.2fK",size /1024];
    }
    else//剩下的都是小于1K的，则转化成B单位
    {
        return [NSString stringWithFormat:@"%1.2fB",size];
    }
}

@end
