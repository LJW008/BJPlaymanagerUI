//
//  BJDownloadingTableViewCell.h
//  BJPlaybackCore
//
//  Created by 辛亚鹏 on 2017/9/18.
//  Copyright © 2017年 辛亚鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJPlayerManagerCore/BJPlayerManagerCore.h>

typedef void(^PUBtnClickBlock)(void);

@interface BJDownloadingTableViewCell : UITableViewCell
@property (nonatomic)  UILabel *fileNameLabel;
@property (nonatomic)  UILabel *progressLabel;
@property (nonatomic)  UILabel *speedLabel;
@property (nonatomic)  UIProgressView *progressView;
@property (nonatomic)  UIButton *downloadBtn;

/** 下载按钮点击回调block */
@property (nonatomic, copy  ) PUBtnClickBlock  btnClickBlock;
/** 下载信息模型 */
@property (nonatomic, strong) BJFileModel      *fileInfo;
/** 该文件发起的请求 */
@property (nonatomic,retain ) BJHttpRequest    *request;

@end
