//
//  PUPlayViewController+playerDelagate.m
//  BJPlayerManagerUI_Example
//
//  Created by xyp on 2018/6/7.
//  Copyright © 2018年 oushizishu. All rights reserved.
//

#import "PUPlayViewController+playerDelagate.h"

@implementation PUPlayViewController (playerDelagate)

- (void)addPlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCallback:)
                                                 name:PMPlayStateChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCallback:)
                                                 name:PMPlayerCreateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCallback:)
                                                 name:PMPlayerWillPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCallback:)
                                                 name:PMPlayerFileInvalidNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCallback:)
                                                 name:PMPlayerFileNotExistNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCallback:)
                                                 name:PMPlayerWillSeekNotification object:nil];
}

- (void)notiCallback:(NSNotification *)note {
    if ([note.name isEqualToString:PMPlayStateChangeNotification]) {
        [self playstate:note];
    }
    else if ([note.name isEqualToString:PMPlayerCreateNotification]) {
    }
    else if ([note.name isEqualToString:PMPlayerWillPlayNotification]) {
    }
    else if ([note.name isEqualToString:PMPlayerFileInvalidNotification]) {
    }
    else if ([note.name isEqualToString:PMPlayerFileNotExistNotification]) {
    }
    else if ([note.name isEqualToString:PMPlayerWillSeekNotification]) {
    }
}

- (void)playstate:(NSNotification *)noti {
    BJPlayerManager *playerMnaager = (BJPlayerManager *)noti.object;
    switch (playerMnaager.player.playbackState) {
        case PKMoviePlaybackStateStopped:
            NSLog(@"%s, line:%d, PKMoviePlaybackStateStopped", __func__, __LINE__);
            break;

        case PKMoviePlaybackStatePlaying:
            NSLog(@"%s, line:%d, PKMoviePlaybackStatePlaying", __func__, __LINE__);
            break;

        case PKMoviePlaybackStatePaused:
            NSLog(@"%s, line:%d, PKMoviePlaybackStatePaused", __func__, __LINE__);
            break;

        case PKMoviePlaybackStateInterrupted:
            NSLog(@"%s, line:%d, PKMoviePlaybackStateInterrupted", __func__, __LINE__);
            break;

        case PKMoviePlaybackStateSeekingForward:
            NSLog(@"%s, line:%d, PKMoviePlaybackStateSeekingForward", __func__, __LINE__);
            break;

        case PKMoviePlaybackStateSeekingBackward:
            NSLog(@"%s, line:%d, PKMoviePlaybackStateSeekingBackward", __func__, __LINE__);
            break;

        default:
            break;
    }
}

#pragma mark - delegate

- (void)videoplayer:(BJPlayerManager *)playerManager throwPlayError:(NSError *)error {
    NSLog(@"line: %d, %s, error:%@", __LINE__, __func__, error);
}

- (void)videoDidFinishPlayInVideoPlayer:(BJPlayerManager *)playerManager {
    
}

- (void)videoPlayPauseInVideoPlayer:(BJPlayerManager *)playerManager {

}

@end
