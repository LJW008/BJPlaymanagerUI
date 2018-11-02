//
//  BJPUProgressView.m
//  Pods
//
//  Created by DLM on 2017/4/26.
//
//

#import "BJPUProgressView.h"
#import "BJPUAppearance.h"

@interface BJPUProgressView ()
@property (nonatomic, strong) UIView *sliderBgView;
@property (nonatomic, strong) UIView *cacheView;
@property (nonatomic, strong) UIImageView *progressView;
@property (nonatomic, strong) UIImageView *durationView;

@end

@implementation BJPUProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self makeConstraints];
        [self setValue:0 cache:0 duration:0];
    }
    return self;
}

- (void)dealloc {
    self.sliderBgView = nil;
    self.slider = nil;
    self.cacheView = nil;
    self.progressView = nil;
}

- (void)setupViews {
    self.sliderBgView = [[UIView alloc] init];
    self.sliderBgView.layer.masksToBounds = YES;
    self.sliderBgView.layer.cornerRadius = self.sliderBgView.frame.size.height / 2.0;
    
    self.slider = [[BJPUVideoSlider alloc] init];
    //    self.slider.touchToChanged = NO;
    self.slider.backgroundColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = [UIColor clearColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    
    UIImage *leftStretch = [[UIImage bjpu_imageNamed:@"ic_player_progress_orange_n.png"]
                            stretchableImageWithLeftCapWidth:4.0
                            topCapHeight:1.0];
    UIImage *rightStretch = [[UIImage bjpu_imageNamed:@"ic_player_progress_gray_n.png"]
                             stretchableImageWithLeftCapWidth:4.0
                             topCapHeight:1.0];
    
    // iOS 8 以下用自定义的
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0)
    {
        [self.slider setMinimumTrackImage:leftStretch forState:UIControlStateNormal];
    }
    //        [self.slider setMaximumTrackImage:rightStretch forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage bjpu_imageNamed:@"ic_player_current_n.png"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage bjpu_imageNamed:@"ic_player_current_big_n.png"] forState:UIControlStateHighlighted];
    
    self.cacheView = [[UIView alloc] init];
    
    self.cacheView.layer.masksToBounds = YES;
    self.cacheView.layer.cornerRadius = 1;
    self.cacheView.backgroundColor = [UIColor whiteColor];
    
    self.progressView = [[UIImageView alloc] init];
    
    self.progressView.layer.masksToBounds = YES;
    self.progressView.image = leftStretch;
    
    self.durationView = [[UIImageView alloc] init];
    
    self.durationView.layer.cornerRadius = 1;
    self.durationView.layer.masksToBounds = YES;
    self.durationView.image = rightStretch;
    
    [self.sliderBgView addSubview:self.durationView];
    [self.sliderBgView addSubview:self.cacheView];
    [self.sliderBgView addSubview:self.progressView];
    
    [self addSubview:self.sliderBgView];
    [self addSubview:self.slider];
}

- (void)makeConstraints {
    [self.sliderBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.right.equalTo(self);
        make.height.equalTo(@2.0);
    }];
    
    [self.durationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sliderBgView).offset(2.0);
        make.top.bottom.equalTo(self);
        make.width.equalTo(self.sliderBgView);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(2.0);
        make.centerY.equalTo(self).offset(-1.0);
        make.height.width.equalTo(self);
    }];
    
    [self.cacheView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self.sliderBgView).offset(2.0);
        make.width.equalTo(@0.0);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self.sliderBgView).offset(2.0);
        make.width.equalTo(@0.0);
    }];
}

- (void)setValue:(float)value cache:(float)cache duration:(float)duration {
    CGFloat progressWidth = CGRectGetWidth(self.frame) - 2.0;
    self.slider.maximumValue = duration;
    self.slider.value = value;
    if (duration) {
        CGFloat progressF = value / duration;
        CGFloat cacheF = cache / duration;
        [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(progressWidth * progressF));
        }];
        [self.cacheView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(progressWidth * cacheF));
        }];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if (CGRectContainsPoint(self.slider.frame, point)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

@end


@implementation BJPUVideoSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    thumbRect.origin.x = (self.maximumValue > 0?(value / self.maximumValue * self.frame.size.width):0) - self.currentThumbImage.size.width / 2;
    thumbRect.origin.y = 0;
    thumbRect.size.height = bounds.size.height;

    return thumbRect;
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds {
    return CGRectZero;
}

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds {
    return CGRectZero;
}

@end
