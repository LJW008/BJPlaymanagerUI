//
//  BJPUProgressView.h
//  Pods
//
//  Created by DLM on 2017/4/26.
//
//

#import <UIKit/UIKit.h>

@class BJPUVideoSlider;
@interface BJPUProgressView : UIView

@property (nonatomic, strong) BJPUVideoSlider *slider;

-(void)setValue:(float)value cache:(float)cache duration:(float)duration;

@end


@interface BJPUVideoSlider : UISlider

@end
