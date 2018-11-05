//
//  BJPUSmallViewController.h
//  Pods
//
//  Created by DLM on 2016/11/7.
//
//

#import <UIKit/UIKit.h>
#import "BJPUDisplayViewController.h"

@interface BJPUSmallViewController : BJPUDisplayViewController

@property (strong, nonatomic, readonly) BJPUProgressView *progressView;

- (void)setupSubViews;

@end
