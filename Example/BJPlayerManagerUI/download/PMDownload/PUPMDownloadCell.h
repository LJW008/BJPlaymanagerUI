//
//  PUPMDownloadCell.h
//  BJPlayerManagerUI_Example
//
//  Created by 辛亚鹏 on 2017/12/13.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJPlayerManagerCore/PMDownloadManager.h>

@interface PUPMDownloadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (nonatomic) PMDownloader *downloader;

- (void)setModel:(PMDownloader *)downloader;

@end
