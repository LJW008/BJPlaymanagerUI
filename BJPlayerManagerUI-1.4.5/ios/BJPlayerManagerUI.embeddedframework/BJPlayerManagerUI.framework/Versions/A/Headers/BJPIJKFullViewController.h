//
//  BJPIJKFullViewController.h
//  BJPlayerManagerUI
//
//  Created by 凡义 on 2018/1/2.
//

#import "BJPIJKDisplayViewController.h"
#import "BJPUFullBottomView.h"
#import "BJPUDefinitionView.h"

@interface BJPIJKFullViewController : BJPIJKDisplayViewController

@property (nonatomic, readonly) BJPUFullBottomView *bottomBarView;
@property (nonatomic, readonly) BJPUDefinitionView *definitionView;

- (BOOL)isLocked;

- (void)setupSubviews;

@end
