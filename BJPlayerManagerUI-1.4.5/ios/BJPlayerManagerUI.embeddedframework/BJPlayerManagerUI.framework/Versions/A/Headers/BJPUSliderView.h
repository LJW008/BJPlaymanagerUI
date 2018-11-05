//
//  BJPUSliderView.h
//  Pods
//
//  Created by DLM on 2017/4/26.
//
//

#import <UIKit/UIKit.h>

@class BJPUSliderView;
@protocol BJPUSliderProtocol <NSObject>
@optional
- (CGFloat)originValueForTouchSlideView:(BJPUSliderView *)touchSlideView;
- (CGFloat)durationValueForTouchSlideView:(BJPUSliderView *)touchSlideView;
- (void)touchSlideView:(BJPUSliderView *)touchSlideView finishHorizonalSlide:(CGFloat)value;

@end

@interface BJPUSliderView : UIView

@property (weak, nonatomic) id<BJPUSliderProtocol> delegate;

@end

@interface BJPUSliderLightView : UIView

@end

@interface BJPUSliderSeekView : UIView
- (void)resetRelTime:(long)relTime duration:(long)duration difference:(long)difference;

@end
