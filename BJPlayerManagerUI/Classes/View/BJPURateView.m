//
//  BJPURateView.m
//  Pods,设置倍速view
//
//  Created by DLM on 2017/4/27.
//
//

#import "BJPURateView.h"
#import "BJPUTheme.h"

@interface BJPURateView ()

@property (strong, nonatomic) UIButton *rateButton0;//0.7
@property (strong, nonatomic) UIButton *rateButton1;//1.0
@property (strong, nonatomic) UIButton *rateButton2;//1.2
@property (strong, nonatomic) UIButton *rateButton3;//1.5
@property (strong, nonatomic) UIButton *rateButton4;//2.0

@end

@implementation BJPURateView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.5];
        [self addSubview:self.rateButton0];
        [self addSubview:self.rateButton1];
        [self addSubview:self.rateButton2];
        [self addSubview:self.rateButton3];
        [self addSubview:self.rateButton4];
        
        [self.rateButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.offset(0);
            make.width.mas_equalTo(50.f);
            make.height.mas_equalTo(20.f);
        }];
        [self.rateButton1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.bottom.equalTo(self.rateButton2.mas_top).offset(-20.f);
            make.width.height.equalTo(self.rateButton2);
        }];

        [self.rateButton0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.bottom.equalTo(self.rateButton1.mas_top).offset(-20.f);
            make.width.height.equalTo(self.rateButton2);
        }];
        [self.rateButton3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.rateButton2.mas_bottom).offset(20.f);
            make.width.height.equalTo(self.rateButton2);
        }];
        [self.rateButton4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.rateButton3.mas_bottom).offset(20.f);
            make.width.height.equalTo(self.rateButton2);
        }];

        if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0) {
            self.rateButton2.hidden = YES;
            [self resetConstraintsLowerIOS10];
        }

    }
    return self;
}

- (void)resetConstraintsLowerIOS10 {
    [self.rateButton1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.equalTo(self.mas_centerY).offset(-10.f);
        make.width.mas_equalTo(50.f);
        make.height.mas_equalTo(20.f);
    }];

    [self.rateButton0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.equalTo(self.rateButton1.mas_top).offset(-20.f);
        make.width.height.equalTo(self.rateButton1);
    }];
    [self.rateButton3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.mas_centerY).offset(10.f);
        make.width.height.equalTo(self.rateButton1);
    }];
    [self.rateButton4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.rateButton3.mas_bottom).offset(20.f);
        make.width.height.equalTo(self.rateButton1);
    }];
}

#pragma mark - action
- (void)changeRateAction:(UIButton *)button
{
    if ([button isEqual:self.rateButton0]) {
        self.rate = 0.7f;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0) {
            self.rate = 0.5f;
        }
    }
    else if ([button isEqual:self.rateButton1]) {
        self.rate = 1.0f;
    }
    else if ([button isEqual:self.rateButton2]) {
        self.rate = 1.2f;
    }
    else if ([button isEqual:self.rateButton3]) {
        self.rate = 1.5f;
    }
    else if ([button isEqual:self.rateButton4]) {
        self.rate = 2.0f;
    }
    
    [self.delegate rateView:self changeRate:self.rate];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        self.hidden = true;
        self.alpha = 1.f;
    }];
}

#pragma mark - set get
- (void)setRate:(CGFloat)rate
{
    _rate = rate;
    if (rate > 0.6 && rate < 0.8) {
        [_rateButton0 BJPURateViewSetSelected:true];
        [_rateButton1 BJPURateViewSetSelected:false];
        [_rateButton2 BJPURateViewSetSelected:false];
        [_rateButton3 BJPURateViewSetSelected:false];
        [_rateButton4 BJPURateViewSetSelected:false];
    }
    else if (rate > 0.9 && rate < 1.1) {
        [_rateButton0 BJPURateViewSetSelected:false];
        [_rateButton1 BJPURateViewSetSelected:true];
        [_rateButton2 BJPURateViewSetSelected:false];
        [_rateButton3 BJPURateViewSetSelected:false];
        [_rateButton4 BJPURateViewSetSelected:false];
    }
    else if (rate > 1.1 && rate < 1.3) {
        [_rateButton0 BJPURateViewSetSelected:false];
        [_rateButton1 BJPURateViewSetSelected:false];
        [_rateButton2 BJPURateViewSetSelected:true];
        [_rateButton3 BJPURateViewSetSelected:false];
        [_rateButton4 BJPURateViewSetSelected:false];
    }
    else if (rate > 1.4 && rate < 1.6) {
        [_rateButton0 BJPURateViewSetSelected:false];
        [_rateButton1 BJPURateViewSetSelected:false];
        [_rateButton2 BJPURateViewSetSelected:false];
        [_rateButton3 BJPURateViewSetSelected:true];
        [_rateButton4 BJPURateViewSetSelected:false];
    }
    else if (rate > 1.9 && rate < 2.1) {
        [_rateButton0 BJPURateViewSetSelected:false];
        [_rateButton1 BJPURateViewSetSelected:false];
        [_rateButton2 BJPURateViewSetSelected:false];
        [_rateButton3 BJPURateViewSetSelected:false];
        [_rateButton4 BJPURateViewSetSelected:true];
    }
}

- (UIButton *)rateButton0
{
    if (!_rateButton0) {
        _rateButton0 = [self rateButtonWithTitle:@"0.7x"];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0) {
            _rateButton0 = [self rateButtonWithTitle:@"0.5x"];
        }
    }
    return _rateButton0;
}

- (UIButton *)rateButton1
{
    if (!_rateButton1) {
        _rateButton1 = [self rateButtonWithTitle:@"1.0x"];
    }
    return _rateButton1;
}

- (UIButton *)rateButton2
{
    if (!_rateButton2) {
        _rateButton2 = [self rateButtonWithTitle:@"1.2x"];
    }
    return _rateButton2;
}

- (UIButton *)rateButton3
{
    if (!_rateButton3) {
        _rateButton3 = [self rateButtonWithTitle:@"1.5x"];
    }
    return _rateButton3;
}

- (UIButton *)rateButton4
{
    if (!_rateButton4) {
        _rateButton4 = [self rateButtonWithTitle:@"2.0x"];
    }
    return _rateButton4;
}

- (UIButton *)rateButtonWithTitle:(NSString *)title {
    UIButton *rateButton = [[UIButton alloc] init];
    [rateButton setTitle:title forState:UIControlStateNormal];
    [rateButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rateButton setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
    rateButton.layer.cornerRadius = 10.f;
    rateButton.layer.borderColor = [BJPUTheme defaultTextColor].CGColor;
    rateButton.layer.borderWidth = 1.f;
    [rateButton addTarget:self action:@selector(changeRateAction:) forControlEvents:UIControlEventTouchUpInside];
    return rateButton;
}

@end

@implementation UIButton (BJPURateView)

- (void)BJPURateViewSetSelected:(BOOL)selected
{
    if (selected) {
        [self setTitleColor:[BJPUTheme highlightTextColor] forState:UIControlStateNormal];
        self.layer.borderColor = [BJPUTheme highlightTextColor].CGColor;
    } else {
        [self setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
        self.layer.borderColor = [BJPUTheme defaultTextColor].CGColor;
    }
}

@end
