//
//  UIAlertView+bjp.h
//  BJVideoPlayerManager
//
//  Created by 辛亚鹏 on 2017/5/27.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteBlock) (NSInteger buttonIndex);

@interface UIAlertView (bjp)

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showAlertViewWithCompleteBlock:(CompleteBlock) block;

@end
