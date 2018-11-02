//
//  BJPUFullBottomView.m
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import "BJPUFullBottomView.h"
#import "BJPUTheme.h"

@implementation BJPUFullBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.playButton];
        [self addSubview:self.pauseButton];
        [self addSubview:self.nextVideoButton];
        [self addSubview:self.relTimeLabel];
        [self addSubview:self.durationLabel];
        [self addSubview:self.progressView];
//        self.progressView.backgroundColor = [UIColor redColor];
//        self.relTimeLabel.backgroundColor = [UIColor yellowColor];
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(10.f);
            make.centerY.offset(0);
            make.width.height.mas_equalTo(30.f);
        }];
        [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playButton);
        }];
        [self.nextVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.playButton.mas_trailing).offset(10.f);
            make.centerY.offset(0);
//            make.width.height.mas_equalTo(30.f);
            make.height.mas_equalTo(30.f);
            make.width.mas_equalTo(0.f);
        }];
        
        self.nextVideoButton.hidden = YES;
        
        [self.relTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            //原版
//            make.leading.mas_equalTo(self.nextVideoButton.mas_trailing).offset(10.f);
//            make.centerY.offset(0);
            //修改
            make.left.mas_equalTo(self.nextVideoButton.mas_right).offset(10.f);
            make.centerY.offset(0);
            make.width.lessThanOrEqualTo(@40.0);
        }];
        [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            //原版
//            make.trailing.offset(-10.f);
//            make.centerY.offset(0);
            //修改
            make.right.equalTo(self.mas_right).offset(-10.f);
            make.centerY.offset(0);
            make.width.lessThanOrEqualTo(@40.0);
        }];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.relTimeLabel.mas_right).offset(20.f);
            make.right.equalTo(self.durationLabel.mas_left).offset(-20.f);
//            make.top.offset(15.f);
            make.centerY.equalTo(self.relTimeLabel);
            make.height.mas_equalTo(10.f);
            //修改添加
            make.width.greaterThanOrEqualTo(@300.0);

        }];
    }
    return self;
}

- (void)layoutSubviews
{
//    CGFloat x = self.relTimeLabel.frame.origin.x + self.relTimeLabel.frame.size.width + 20;
//    CGFloat width = self.durationLabel.frame.origin.x - 20 - x;
//    self.progressView.frame = CGRectMake(x, 15, width, 10);
//    [super layoutSubviews];
//    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.relTimeLabel.mas_right).offset(20.f);
//        make.right.equalTo(self.durationLabel.mas_left).offset(-20.f);
//        //            make.top.offset(15.f);
//        make.centerY.equalTo(self.relTimeLabel);
//        make.height.equalTo(@10);
//    }];

    
}

#pragma mark - set get
- (UIButton *)playButton
{
    if (!_playButton)
    {
        _playButton = [UIButton new];
        [_playButton setImage:[BJPUTheme playButtonImage] forState:UIControlStateNormal];
    }
    return _playButton;
}
- (UIButton *)pauseButton
{
    if (!_pauseButton)
    {
        _pauseButton = [UIButton new];
        _pauseButton.hidden = YES;
        [_pauseButton setImage:[BJPUTheme pauseButtonImage] forState:UIControlStateNormal];
    }
    return _pauseButton;
}
- (UIButton *)nextVideoButton
{
    if (!_nextVideoButton)
    {
        _nextVideoButton = [UIButton new];
        [_nextVideoButton setImage:[BJPUTheme nextButtonImage] forState:UIControlStateNormal];
    }
    return _nextVideoButton;
}
- (BJPUProgressView *)progressView
{
    if (!_progressView) {
//        _progressView = [[BJPUProgressView alloc] initWithFrame:CGRectMake(-100, 20, 100, 10)];
        _progressView = [[BJPUProgressView alloc] init];
    }
    return _progressView;
}
- (UILabel *)relTimeLabel
{
    if (!_relTimeLabel)
    {
        _relTimeLabel = [UILabel new];
        _relTimeLabel.text = @"00:00";
        _relTimeLabel.textColor = [BJPUTheme defaultTextColor];
        _relTimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _relTimeLabel;
}
- (UILabel *)durationLabel
{
    if (!_durationLabel) {
        _durationLabel = [UILabel new];
        _durationLabel.textColor = [BJPUTheme defaultTextColor];
        _durationLabel.font = [UIFont systemFontOfSize:10];
    }
    return _durationLabel;
}

@end
