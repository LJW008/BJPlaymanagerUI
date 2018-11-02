//
//  UIWindow+PUMotion.h
//  BJPlayerManagerUI_Example
//
//  Created by daixijia on 2018/3/29.
//  Copyright © 2018年 oushizishu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const UIEventSubtypeMotionShakeNotification;
extern NSString * const UIEventSubtypeMotionShakeStateKey;

typedef NS_ENUM(NSInteger, UIEventSubtypeMotionShakeState) {
    UIEventSubtypeMotionShakeStateBegan,
    UIEventSubtypeMotionShakeStateEnded,
    UIEventSubtypeMotionShakeStateCancelled
};

@interface UIWindow (PUMotion)

@end
