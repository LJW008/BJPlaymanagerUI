//
//  PUPlayOptionsViewController.m
//  BJPlayerManagerUI_Example
//
//  Created by daixijia on 2018/8/2.
//  Copyright © 2018年 oushizishu. All rights reserved.
//

#import "PUPlayOptionsViewController.h"
#import <Masonry.h>

@implementation PUPlayOptions

+ (instancetype)shareInstance {
    static PUPlayOptions *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[PUPlayOptions alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.advertisementEnabled = NO;
        self.autoplay = YES;
        self.sliderDragEnabled = YES;
        self.playTimeRecordEnabled = YES;
        self.encryptEnabled = NO;
        self.backgroundAudioEnabled = YES;
        self.playRate = 1.0;
        self.preferredDefinitionList = @[@(-2),@(0),@(1),@(2),@(3),@(4)];
        self.playRate = 1.0;
    }
    return self;
}

#pragma mark - <YYModel>

- (void)encodeWithCoder:(NSCoder *)aCoder { [self bjlyy_modelEncodeWithCoder:aCoder]; }
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self bjlyy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(nullable NSZone *)zone { return [self bjlyy_modelCopy]; }
- (NSUInteger)hash { return [self bjlyy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self bjlyy_modelIsEqual:object]; }

@end

static NSInteger initialTag = 1000;

@interface PUPlayOptionsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *nameTextField, *numberTextField, *selectDefinitionTextField;
@property (strong, nonatomic) UILabel *adLabel, *sliderLabel, *autoPlayLabel, *encryptLabel, *memoryLabel, *backgroundPlayLabel, *nameLabel, *numberLabel, *definitionLabel;
@property (strong, nonatomic) UISwitch *adSwitch, *sliderSwitch, *autoPlaySwitch, *encryptSwitch, *memorySwitch, *backgroundPlaySwitch;
@property (strong, nonatomic) NSArray<NSString *> *definitionTitles;
@property (strong, nonatomic) NSArray<UIButton *> *definitionButtons;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *preferredDefinitions;
@property (strong, nonatomic) UIButton *confirmButton;

@end

@implementation PUPlayOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    
    PUPlayOptions *options = [PUPlayOptions shareInstance];
    self.adSwitch.on = options.advertisementEnabled;
    self.autoPlaySwitch.on = options.autoplay;
    self.sliderSwitch.on = options.sliderDragEnabled;
    self.memorySwitch.on = options.playTimeRecordEnabled;
    self.encryptSwitch.on = options.encryptEnabled;
    self.backgroundPlaySwitch.on = options.backgroundAudioEnabled;
    self.nameTextField.text = options.userName;
    self.numberTextField.text = [NSString stringWithFormat:@"%ti", options.userNumber];
    
    // 偏好清晰度
    self.preferredDefinitions = [options.preferredDefinitionList mutableCopy];
    [self updateDefinitionControls];
}

#pragma mark - subViews

- (void)setupSubviews {
    // 确认按钮
    self.confirmButton = ({
        UIButton *button = [[UIButton alloc] init];
        button.backgroundColor = [UIColor redColor];
        button.layer.cornerRadius = 5.0;
        [button setTitle:@"确认" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [button addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-30.0);
        make.left.equalTo(self.view).offset(30.0);
        make.right.equalTo(self.view).offset(-30.0);
        make.height.equalTo(@30.0);
    }];
    
    // scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.confirmButton.mas_top).offset(-30.0);
    }];
    
    UIView *contentView = [[UIView alloc] init];
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@[self.view, scrollView]);
        make.top.bottom.equalTo(scrollView);
    }];
    
    CGSize labelSize = CGSizeMake(180.0, 30.0);
    
    [contentView addSubview:self.adLabel];
    [self.adLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(40.0);
        make.left.equalTo(contentView).offset(30.0);
        make.size.mas_equalTo(labelSize);
    }];
    
    [self.view addSubview:self.adSwitch];
    [self.adSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel.mas_right).offset(20.0);
        make.top.bottom.equalTo(self.adLabel);
    }];
    
    [contentView addSubview:self.sliderLabel];
    [self.sliderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel);
        make.top.equalTo(self.adLabel.mas_bottom).offset(30.0);
        make.size.mas_equalTo(labelSize);
    }];
    
    [contentView addSubview:self.sliderSwitch];
    [self.sliderSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sliderLabel.mas_right).offset(20.0);
        make.top.bottom.equalTo(self.sliderLabel);
    }];
    
    [contentView addSubview:self.autoPlayLabel];
    [self.autoPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel);
        make.top.equalTo(self.sliderLabel.mas_bottom).offset(30.0);
        make.size.mas_equalTo(labelSize);
    }];
    
    [contentView addSubview:self.autoPlaySwitch];
    [self.autoPlaySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.autoPlayLabel.mas_right).offset(20.0);
        make.top.bottom.equalTo(self.autoPlayLabel);
    }];
    
    [contentView addSubview:self.encryptLabel];
    [self.encryptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel);
        make.top.equalTo(self.autoPlayLabel.mas_bottom).offset(30.0);
        make.size.mas_equalTo(labelSize);
    }];
    
    [contentView addSubview:self.encryptSwitch];
    [self.encryptSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.encryptLabel.mas_right).offset(20.0);
        make.top.bottom.equalTo(self.encryptLabel);
    }];
    
    [contentView addSubview:self.memoryLabel];
    [self.memoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel);
        make.top.equalTo(self.encryptLabel.mas_bottom).offset(30.0);
        make.size.mas_equalTo(labelSize);
    }];
    
    [contentView addSubview:self.memorySwitch];
    [self.memorySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.memoryLabel.mas_right).offset(20.0);
        make.top.bottom.equalTo(self.memoryLabel);
    }];
    
    [contentView addSubview:self.backgroundPlayLabel];
    [self.backgroundPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel);
        make.top.equalTo(self.memoryLabel.mas_bottom).offset(30.0);
        make.size.mas_equalTo(labelSize);
    }];
    
    [contentView addSubview:self.backgroundPlaySwitch];
    [self.backgroundPlaySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundPlayLabel.mas_right).offset(20.0);
        make.top.bottom.equalTo(self.backgroundPlayLabel);
    }];
    
    [contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel);
        make.top.equalTo(self.backgroundPlayLabel.mas_bottom).offset(30.0);
        make.size.mas_equalTo(labelSize);
    }];
    
    [contentView addSubview:self.nameTextField];
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(20.0);
        make.top.bottom.equalTo(self.nameLabel);
        make.width.equalTo(@(100.0));
    }];
    
    [contentView addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(30.0);
        make.size.mas_equalTo(labelSize);
    }];
    
    [contentView addSubview:self.numberTextField];
    [self.numberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.numberLabel.mas_right).offset(20.0);
        make.top.bottom.equalTo(self.numberLabel);
        make.width.equalTo(@(100));
    }];
    
    [contentView addSubview:self.definitionLabel];
    [self.definitionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.adLabel);
        make.top.equalTo(self.numberLabel.mas_bottom).offset(30.0);
        make.size.mas_equalTo(CGSizeMake(100.0, 30.0));
    }];
    
    [contentView addSubview:self.selectDefinitionTextField];
    [self.selectDefinitionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.definitionLabel.mas_right).offset(5.0);
        make.top.bottom.equalTo(self.definitionLabel);
        make.width.greaterThanOrEqualTo(@(80.0));
    }];
    
    CGFloat leftOffset = 0.0;
    CGSize buttonSize = CGSizeMake(50.0, 25.0);
    for (UIButton *button in self.definitionButtons) {
        [contentView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.definitionLabel.mas_bottom).offset(5.0);
            make.left.equalTo(self.definitionLabel).offset(leftOffset);
            make.bottom.equalTo(contentView);
            make.size.mas_equalTo(buttonSize);
        }];
        leftOffset += buttonSize.width + 5;
    }
}

#pragma mark - action

- (void)confirmAction {
    PUPlayOptions *options = [PUPlayOptions shareInstance];
    options.advertisementEnabled = self.adSwitch.on;
    options.autoplay = self.autoPlaySwitch.on;
    options.sliderDragEnabled = self.sliderSwitch.on;
    options.playTimeRecordEnabled = self.memorySwitch.on;
    options.encryptEnabled = self.encryptSwitch.on;
    options.backgroundAudioEnabled = self.backgroundPlaySwitch.on;
    options.userName = self.nameTextField.text;
    options.userNumber = [self.numberTextField.text integerValue];
    // 偏好清晰度
    options.preferredDefinitionList = [NSArray arrayWithArray:self.preferredDefinitions];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectionButtonOnClick:(UIButton *)button {
    NSInteger index = button.tag - initialTag;
//    index = index != 0 ?: -2;
    if (button.selected) {
        // 取消
        if ([self.preferredDefinitions containsObject:@(index)]) {
            [self.preferredDefinitions removeObject:@(index)];
        }
        else {
            return;
        }
    }
    else {
        // 选中
        if ([self.preferredDefinitions containsObject:@(index)]) {
            return;
        }
        else {
            [self.preferredDefinitions addObject:@(index)];
        }
    }
    [self updateDefinitionControls];
}

#pragma mark - getters

- (UILabel *)adLabel {
    if (!_adLabel) {
        _adLabel = [self labelWithText:@"片头片尾广告:(ijk无效) "];
    }
    return _adLabel;
}

- (UISwitch *)adSwitch {
    if (!_adSwitch) {
        _adSwitch = [[UISwitch alloc] init];
    }
    return _adSwitch;
}

- (UILabel *)sliderLabel {
    if (!_sliderLabel) {
        _sliderLabel = [self labelWithText:@"拖拽进度条: "];
    }
    return _sliderLabel;
}

- (UISwitch *)sliderSwitch {
    if (!_sliderSwitch) {
        _sliderSwitch = [[UISwitch alloc] init];
        _sliderSwitch.on = YES;
    }
    return _sliderSwitch;
}

- (UILabel *)autoPlayLabel {
    if (!_autoPlayLabel) {
        _autoPlayLabel = [self labelWithText:@"自动播放: "];
    }
    return _autoPlayLabel;
}

- (UISwitch *)autoPlaySwitch {
    if (!_autoPlaySwitch) {
        _autoPlaySwitch = [[UISwitch alloc] init];
    }
    return _autoPlaySwitch;
}

- (UILabel *)encryptLabel {
    if (!_encryptLabel) {
        _encryptLabel = [self labelWithText:@"视频加密: "];
    }
    return _encryptLabel;
}

- (UISwitch *)encryptSwitch {
    if (!_encryptSwitch) {
        _encryptSwitch = [[UISwitch alloc] init];
    }
    return _encryptSwitch;
}

- (UILabel *)memoryLabel {
    if (!_memoryLabel) {
        _memoryLabel = [self labelWithText:@"记忆播放: "];
    }
    return _memoryLabel;
}

- (UISwitch *)memorySwitch {
    if (!_memorySwitch) {
        _memorySwitch = [[UISwitch alloc] init];
    }
    return _memorySwitch;
}

- (UILabel *)backgroundPlayLabel {
    if (!_backgroundPlayLabel) {
        _backgroundPlayLabel = [self labelWithText:@"后台播放: "];
    }
    return _backgroundPlayLabel;
}

-  (UISwitch *)backgroundPlaySwitch {
    if (!_backgroundPlaySwitch) {
        _backgroundPlaySwitch = [[UISwitch alloc] init];
    }
    return _backgroundPlaySwitch;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [self labelWithText:@"用户名"];
    }
    return _nameLabel;
}

- (UITextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = ({
            UITextField *textField = [self textFieldWithPlaceholder:@"上报统计"];
            textField.returnKeyType = UIReturnKeyDone;
            textField.delegate = self;
            textField;
        });
    }
    return _nameTextField;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [self labelWithText:@"用户编号"];
    }
    return _numberLabel;
}

- (UITextField *)numberTextField {
    if (!_numberTextField) {
        _numberTextField = ({
            UITextField *textField = [self textFieldWithPlaceholder:@"上报统计"];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.returnKeyType = UIReturnKeyDone;
            textField.delegate = self;
            textField;
        });
    }
    return _numberTextField;
}

-  (UILabel *)definitionLabel {
    if (!_definitionLabel) {
        _definitionLabel = [self labelWithText:@" 偏好清晰度"];
    }
    return _definitionLabel;
}

- (UITextField *)selectDefinitionTextField {
    if (!_selectDefinitionTextField) {
        _selectDefinitionTextField = ({
            UITextField *textField = [self textFieldWithPlaceholder:@" 优先级递减"];
            textField.font = [UIFont systemFontOfSize:14.0];
            textField.enabled = NO;
            textField;
        });
    }
    return _selectDefinitionTextField;
}

- (NSArray<UIButton *> *)definitionButtons {
    if (!_definitionButtons) {
        _definitionButtons = ({
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 0; i < self.definitionTitles.count; i ++) {
                NSString *title = self.definitionTitles[i];
                UIButton *definitionButton = [self selectionButtonWithTitle:title];
                if (i == 0) {
                    definitionButton.tag = initialTag - 2;
                }
                else {
                    definitionButton.tag = initialTag + i - 1;
                }
                [array addObject:definitionButton];
            }
            array;
        });
    }
    return _definitionButtons;
}

- (NSMutableArray<NSNumber *> *)preferredDefinitions {
    if (!_preferredDefinitions) {
        _preferredDefinitions = [NSMutableArray array];
    }
    return _preferredDefinitions;
}

- (NSArray<NSString *> *)definitionTitles {
    if (!_definitionTitles) {
        _definitionTitles = @[@"音频", @"标清", @"高清", @"超清", @"720P", @"1080P"];
    }
    return _definitionTitles;
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - private

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.layer.borderColor = [UIColor grayColor].CGColor;
    textField.layer.borderWidth = 0.5;
    textField.layer.cornerRadius = 5.f;
    return textField;
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@" %@", text];
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.cornerRadius = 3.0;
    label.layer.borderWidth = 0.5;
    return label;
}

- (UIButton *)selectionButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.cornerRadius = 3.0;
    [button addTarget:self action:@selector(selectionButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)updateDefinitionControls {
    for (UIButton *button in self.definitionButtons) {
        button.selected = NO;
        button.layer.borderColor = [UIColor grayColor].CGColor;
    }
    
    NSString *definitionString = self.preferredDefinitions.count? @" " : nil;
    for (NSNumber *number in self.preferredDefinitions) {
        NSInteger index = [number integerValue];
        if (index == -2) {
            index = 0;
        }
        else {
            index++;
        }
        if (index >= 0 && index < self.definitionTitles.count) {
            NSString *title = self.definitionTitles[index];
            definitionString = [NSString stringWithFormat:@"%@ %@", definitionString, title];
        }
        
        if (index >= 0 && index < self.definitionButtons.count) {
            UIButton *button = self.definitionButtons[index];
            button.selected = YES;
            button.layer.borderColor = [UIColor blueColor].CGColor;
        }
        
    }
    self.selectDefinitionTextField.text = definitionString;
}

@end
