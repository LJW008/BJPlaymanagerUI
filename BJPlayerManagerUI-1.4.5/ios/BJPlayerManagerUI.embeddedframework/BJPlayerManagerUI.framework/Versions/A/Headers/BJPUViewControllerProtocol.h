//
//  BJPUViewControllerProtocol.h
//  Pods
//
//  Created by DLM on 2017/4/26.
//
//

#import <Foundation/Foundation.h>
#import "BJPUMacro.h"

@protocol BJPUViewControllerProtocol <NSObject>

@optional

#pragma mark - AVPlayer

//设置在线视频播放,shouldAutoPlay设置是否自动播放
- (void)playWithVid:(NSString *)vid token:(NSString *)token shouldAutoPlay:(BOOL)shouldAutoPlay;

#pragma mark - IJKPlayer

/*
 * !!!:如果希望播放器支持后台播放,除了打开Background Modes, 还需要调用该初始化方法设置为YES, 默认是不支持后台播放的
 */
- (instancetype)initWithNeedBackgroundModes:(BOOL)needBackgroundModes;

//设置在线视频播放,shouldAutoPlay设置是否自动播放 默认使用的不加密视频
- (void)playWithVid:(NSString *)vid token:(NSString *)token shouldAutoPlay:(BOOL)shouldAutoPlay needEncrypt:(BOOL)needEncrypt;

@required

#pragma mark - common

@property (assign, nonatomic) CGRect smallScreenFrame;
@property (assign, nonatomic) BJPUScreenType screenType;
@property (strong, nonatomic, readonly) BJPlayerManager *playerManager;

//本地视频播放,默认自动播放的
- (void)playWithVideoPath:(NSString *)path definitionType:(NSInteger)definitionType;

/**
 进度条是否可以拖拽
 
 @param mayDrag mayDrag
 */
- (void)sliderMayDrag:(BOOL)mayDrag;

/**
 横竖屏切换

 @param type 横竖屏类型
 */
- (void)changeScreenType:(BJPUScreenType)type;

@end
