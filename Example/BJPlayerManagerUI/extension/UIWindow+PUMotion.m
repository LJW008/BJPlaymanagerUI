//
//  UIWindow+PUMotion.m
//  BJPlayerManagerUI_Example
//
//  Created by daixijia on 2018/3/29.
//  Copyright © 2018年 oushizishu. All rights reserved.
//

#import "UIWindow+PUMotion.h"

NSString * const UIEventSubtypeMotionShakeNotification = @"UIEventSubtypeMotionShakeNotification";
NSString * const UIEventSubtypeMotionShakeStateKey = @"UIEventSubtypeMotionShakeState";

@implementation UIWindow (PUMotion)

#pragma mark -

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionBegan:motion withEvent:event];
    
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:UIEventSubtypeMotionShakeNotification
         object:self
         userInfo:@{ UIEventSubtypeMotionShakeStateKey: @(UIEventSubtypeMotionShakeStateBegan) }];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionEnded:motion withEvent:event];
    
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:UIEventSubtypeMotionShakeNotification
         object:self
         userInfo:@{ UIEventSubtypeMotionShakeStateKey: @(UIEventSubtypeMotionShakeStateEnded) }];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionCancelled:motion withEvent:event];
    
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:UIEventSubtypeMotionShakeNotification
         object:self
         userInfo:@{ UIEventSubtypeMotionShakeStateKey: @(UIEventSubtypeMotionShakeStateCancelled) }];
    }
}


@end
