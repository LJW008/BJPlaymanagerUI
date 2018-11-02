//
//  BJPIJKViewController.h
//  BJPlayerManagerUI
//
//  Created by 凡义 on 2018/1/2.
//

#import <UIKit/UIKit.h>
#import "BJPUViewControllerProtocol.h"

@interface BJPIJKViewController : UIViewController <BJPUViewControllerProtocol>

@property (assign, nonatomic) CGRect smallScreenFrame;
@property (assign, nonatomic) BJPUScreenType screenType;
@property (strong, nonatomic, readonly) BJPlayerManager *playerManager;

/*
 * !!!:如果希望播放器支持后台播放,除了打开Background Modes, 还需要调用该初始化方法设置为YES, 默认是不支持后台播放的
 */
- (instancetype)initWithNeedBackgroundModes:(BOOL)needBackgroundModes;

//设置在线视频播放,shouldAutoPlay设置是否自动播放 默认使用的不加密视频
- (void)playWithVid:(NSString *)vid token:(NSString *)token shouldAutoPlay:(BOOL)shouldAutoPlay needEncrypt:(BOOL)needEncrypt;

//本地视频播放,默认自动播放的
- (void)playWithVideoPath:(NSString *)path definitionType:(NSInteger)definitionType;

/**
 进度条是否可以拖拽
 
 @param mayDrag mayDrag
 */
- (void)sliderMayDrag:(BOOL)mayDrag;

@property (strong, nonatomic, readonly) BJPlayerManager *ijkPlayerManager DEPRECATED_ATTRIBUTE;

@end
