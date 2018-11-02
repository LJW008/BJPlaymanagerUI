//
//  BJDownloadingTableViewCell.m
//  BJPlaybackCore
//
//  Created by 辛亚鹏 on 2017/9/18.
//  Copyright © 2017年 辛亚鹏. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "BJDownloadingTableViewCell.h"

@implementation BJDownloadingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self makeConstaion];
    }
    return self;
    
}

- (void)setupViews {
    self.fileNameLabel = ({
        UILabel *label = [UILabel new];
        [self.contentView addSubview:label];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    
    self.progressLabel = ({
        UILabel *label = [UILabel new];
        [self.contentView addSubview:label];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    
    self.speedLabel = ({
        UILabel *label = [UILabel new];
        [self.contentView addSubview:label];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentRight;
        label;
    });
    
    self.downloadBtn = ({
        UIButton *btn = [UIButton new];
        btn.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:btn];
        [btn setImage:[UIImage imageNamed:@"ic_play_"] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:@"ic_pause_"] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(clickDownload:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    self.progressView = [UIProgressView new];
    [self.contentView addSubview:self.progressView];
}

- (void)makeConstaion {
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.top.offset(10);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.height.equalTo(@2);
        make.left.offset(10);
        make.right.equalTo(self.downloadBtn.mas_left).offset(-10);
    }];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fileNameLabel);
        make.right.equalTo(self.speedLabel.mas_left).offset(-10);
        make.bottom.offset(-10);
    }];
    [self.downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.height.width.equalTo(@40);
        make.right.offset(-10);
    }];
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.progressLabel);
        make.right.equalTo(self.progressView);
    }];
}

/**
 *  暂停、下载
 *
 *  @param sender UIButton
 */
- (IBAction)clickDownload:(UIButton *)sender {
    // 执行操作过程中应该禁止该按键的响应 否则会引起异常
    BJFileModel *downFile = self.fileInfo;
    BJDownloadManager *filedownmanage = [BJDownloadManager sharedDownloadManager];
    if(downFile.downloadState == BJDownloading) { //文件正在下载，点击之后暂停下载 有可能进入等待状态
        self.downloadBtn.selected = YES;
        [filedownmanage stopRequest:self.request];
    } else {
        self.downloadBtn.selected = NO;
        [filedownmanage resumeRequest:self.request];
    }
    
    // 暂停意味着这个Cell里的ASIHttprequest已被释放，要及时更新table的数据，使最新的ASIHttpreqst控制Cell
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
}

/**
 *  model setter
 *
 *  @param sessionModel sessionModel
 */
- (void)setFileInfo:(BJFileModel *)fileInfo
{
    _fileInfo = fileInfo;
    self.fileNameLabel.text = fileInfo.fileName;
    // 服务器可能响应的慢，拿不到视频总长度 && 不是下载状态
    if ([fileInfo.fileSize longLongValue] == 0 && !(fileInfo.downloadState == BJDownloading)) {
        self.progressLabel.text = @"";
        if (fileInfo.downloadState == BJStopDownload) {
            self.downloadBtn.selected = YES;
            self.speedLabel.text = @"已暂停";
        } else if (fileInfo.downloadState == BJWillDownload) {
            self.downloadBtn.selected = YES;
            self.speedLabel.text = @"等待下载";
        } else if (fileInfo.downloadState == BJDownloadedError) {
            self.downloadBtn.selected = YES;
            self.speedLabel.text = @"下载出错";
        }
        self.progressView.progress = 0.0;
        return;
    }
    NSString *currentSize = [BJCommonHelper getFileSizeString:fileInfo.fileReceivedSize];
    NSString *totalSize = [BJCommonHelper getFileSizeString:fileInfo.fileSize];
    // 下载进度
    float progress = (float)[fileInfo.fileReceivedSize longLongValue] / [fileInfo.fileSize longLongValue];
    
    self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@ (%.2f%%)",currentSize, totalSize, progress*100];
    
    self.progressView.progress = progress;
    
    if (fileInfo.speed) {
        NSString *speed = [NSString stringWithFormat:@"%@ 剩余%@",fileInfo.speed,fileInfo.remainingTime];
        self.speedLabel.text = speed;
    } else {
        self.speedLabel.text = @"正在获取";
    }
    
    if (fileInfo.downloadState == BJDownloading) { //文件正在下载
        self.downloadBtn.selected = NO;
        if (fileInfo.speed) {
            NSString *speed = [NSString stringWithFormat:@"%@ 剩余%@",fileInfo.speed,fileInfo.remainingTime];
            self.speedLabel.text = speed;
        } else {
            self.speedLabel.text = @"正在获取";
        }
    } else if (fileInfo.downloadState == BJStopDownload && !fileInfo.error) {
        self.downloadBtn.selected = YES;
        self.speedLabel.text = @"已暂停";
    } else if (fileInfo.downloadState == BJWillDownload && !fileInfo.error) {
        self.downloadBtn.selected = YES;
        self.speedLabel.text = @"等待下载";
    } else if (fileInfo.error) {
        self.downloadBtn.selected = YES;
        self.speedLabel.text = @"错误";
    } else {
        self.downloadBtn.selected = YES;
        self.speedLabel.text = @"暂停";
    }
}

@end
