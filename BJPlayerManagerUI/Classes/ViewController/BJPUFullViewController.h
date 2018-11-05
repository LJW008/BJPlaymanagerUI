//
//  PMBigViewController.h
//  Pods
//
//  Created by DLM on 2016/11/7.
//
//

#import <UIKit/UIKit.h>
#import "BJPUDisplayViewController.h"
#import "BJPUFullBottomView.h"

@interface BJPUFullViewController : BJPUDisplayViewController

@property (nonatomic, readonly) BJPUFullBottomView *bottomBarView;

@property (nonatomic , copy) NSString  * courseTitle;


- (BOOL)isLocked;

- (void)setupSubviews;


@end
