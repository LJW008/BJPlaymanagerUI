//
//  BJPUViewController.h
//  Pods
//
//  Created by DLM on 2017/4/26.
//
//

#import <UIKit/UIKit.h>
#import "BJPUViewControllerProtocol.h"
 
@interface BJPUViewController : UIViewController <BJPUViewControllerProtocol>

@property (assign, nonatomic) CGRect smallScreenFrame;
@property (assign, nonatomic) BJPUScreenType screenType;
@property (strong, nonatomic, readonly) BJPlayerManager *playerManager;

//设置在线视频播放,不自动播放
- (void)playWithVid:(NSString *)vid token:(NSString *)token PM_Will_DEPRECATED("playWithVid:token:shouldAutoPlay:");

//设置在线视频播放,shouldAutoPlay设置是否自动播放
- (void)playWithVid:(NSString *)vid token:(NSString *)token shouldAutoPlay:(BOOL)shouldAutoPlay;

//本地视频播放,默认自动播放的
- (void)playWithVideoPath:(NSString *)path definitionType:(NSInteger)definitionType;

/**
 进度条是否可以拖拽
 
 @param mayDrag mayDrag
 */
- (void)sliderMayDrag:(BOOL)mayDrag;

#pragma mark - 添加方法

- (BOOL)isLockedNow;//锁屏

@property (copy, nonatomic) void(^exitBlock)(void);

//播放完毕回调
@property (copy, nonatomic) void(^finishPlayBlock)(void);


//视频的title
@property (nonatomic , copy) NSString  *courseTitle;

@end
