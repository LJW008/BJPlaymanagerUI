//
//  BJPUFullBottomView.h
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import <UIKit/UIKit.h>
#import "BJPUProgressView.h"

@interface BJPUFullBottomView : UIView

@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *nextVideoButton;
@property (strong, nonatomic) UILabel *relTimeLabel;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) BJPUProgressView *progressView;

@end
