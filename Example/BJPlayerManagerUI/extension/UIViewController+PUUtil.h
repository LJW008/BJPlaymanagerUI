//
//  UIViewController+PUUtil.h
//  BJPlayerManagerUI_Example
//
//  Created by daixijia on 2018/3/29.
//  Copyright © 2018年 oushizishu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PUUtil)

- (void)addChildViewController:(UIViewController *)childController superview:(UIView *)superview;
- (void)removeFromParentViewControllerAndSuperiew;

+ (UIViewController *)topViewController;

@end
