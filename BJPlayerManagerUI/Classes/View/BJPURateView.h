//
//  BJPURateView.h
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import <UIKit/UIKit.h>

@class BJPURateView;
@protocol BJPURateViewProtocol <NSObject>

@required
- (void)rateView:(BJPURateView *)rateView changeRate:(CGFloat)rate;

@end

@interface BJPURateView : UIView

@property (weak, nonatomic) id<BJPURateViewProtocol> delegate;

@property (assign, nonatomic) CGFloat rate;

@end

@interface UIButton (BJPURateView)

- (void)BJPURateViewSetSelected:(BOOL)selected;

@end
