//
//  BJDownloadedTableViewCell.m
//  BJPlaybackCore
//
//  Created by 辛亚鹏 on 2017/9/18.
//  Copyright © 2017年 辛亚鹏. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "BJDownloadedTableViewCell.h"

@implementation BJDownloadedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.fileNameLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label];
        label;
    });
    self.sizeLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label];
        label.textAlignment = NSTextAlignmentRight;
        label;
    });
    
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(10);
    }];
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileNameLabel.mas_bottom).offset(10);
        make.right.offset(-10);
        make.left.mas_greaterThanOrEqualTo(10);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFileInfo:(BJFileModel *)fileInfo
{
    _fileInfo = fileInfo;
    NSString *totalSize = [BJCommonHelper getFileSizeString:fileInfo.fileSize];
    NSString *fileReceivedSize = [BJCommonHelper getFileSizeString:fileInfo.fileReceivedSize];
    self.fileNameLabel.text = fileInfo.fileName;
    if(fileInfo.downloadState == BJDownloadedError) {
        self.sizeLabel.text = [NSString stringWithFormat:@"下载出错-%@/%@", fileReceivedSize, totalSize];
    }
    else {
        self.sizeLabel.text = [NSString stringWithFormat:@"%@/%@", fileReceivedSize, totalSize];
    }
}

@end
