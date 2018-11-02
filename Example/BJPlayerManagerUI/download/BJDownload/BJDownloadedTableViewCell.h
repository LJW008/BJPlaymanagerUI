//
//  BJDownloadedTableViewCell.h
//  BJPlaybackCore
//
//  Created by 辛亚鹏 on 2017/9/18.
//  Copyright © 2017年 辛亚鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJPlayerManagerCore/BJPlayerManagerCore.h>

@interface BJDownloadedTableViewCell : UITableViewCell

@property (nonatomic)  UILabel *fileNameLabel;
@property (nonatomic)  UILabel *sizeLabel;
@property (nonatomic, strong) BJFileModel *fileInfo;

@end
