//
//  BJPUFullRightView.m
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import "BJPUFullRightView.h"
#import "BJPUTheme.h"

@implementation BJPUFullRightView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.rateButton];
        [self addSubview:self.definitionButton];
//        [self addSubview:self.lessonButton];
        
        [self.definitionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.offset(0);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(30);
        }];
        [self.rateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.definitionButton);
            make.bottom.equalTo(self.definitionButton.mas_top).offset(-10.f);
            make.width.height.equalTo(self.definitionButton);
        }];
//        [self.lessonButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.definitionButton);
//            make.top.equalTo(self.definitionButton.mas_bottom).offset(10.f);
//            make.width.height.equalTo(self.definitionButton);
//        }];
    }
    return self;
}

#pragma mark - set get
- (UIButton *)rateButton
{
    if (!_rateButton)
    {
        _rateButton = [[UIButton alloc] init];
        [_rateButton setTitle:@"倍速" forState:UIControlStateNormal];
        [_rateButton setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
        [_rateButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    }
    return _rateButton;
}
- (UIButton *)definitionButton
{
    if (!_definitionButton) {
        _definitionButton = [[UIButton alloc] init];
        [_definitionButton setTitle:@"清晰度" forState:UIControlStateNormal];
        [_definitionButton setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
        [_definitionButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    }
    return _definitionButton;
}

//- (UIButton *)lessonButton
//{
//    if (!_lessonButton)
//    {
//        _lessonButton = [[UIButton alloc] init];
//        [_lessonButton setTitle:@"选集" forState:UIControlStateNormal];
//        [_lessonButton setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
//        [_lessonButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    }
//    return _lessonButton;
//}

@end
