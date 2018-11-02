//
//  PUPlayViewController.h
//  BJHL-VideoPlayer-UI
//
//  Created by DLM on 2017/4/26.
//  Copyright © 2017年 杨健. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PUPlayerType) {
    PUPlayerType_AVPlayer,
    PUPlayerType_IJKPlayer,
};

//在线视频播放页面
@interface PUPlayViewController : UIViewController

- (instancetype)initWithVid:(NSString *)vid
                      token:(NSString *)token
                   isNeedAD:(BOOL)isNeedAD
                    mayDrag:(BOOL)mayDrag
             shouldAutoPlay:(BOOL)shouldAutoPlay
                needEncrypt:(BOOL)needEncrypt
       enableplayTimeRecord:(BOOL)enablePlayTimeRecord
                 playerType:(PUPlayerType)playerType;

// 本地播放
- (instancetype)initWithPath:(NSString *)path
              definitionType:(NSInteger)definitionType
                  playerType:(PUPlayerType)playerType;


@end
