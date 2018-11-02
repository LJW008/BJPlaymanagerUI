//
//  BJPIJKSmallViewController.h
//  BJPlayerManagerUI
//
//  Created by 凡义 on 2018/1/2.
//

#import "BJPIJKDisplayViewController.h"
#import "BJPUProgressView.h"

@interface BJPIJKSmallViewController : BJPIJKDisplayViewController

//小屏底部进度条
@property (nonatomic, readonly) BJPUProgressView *progressView;

- (void)setupSubviews;

@end
