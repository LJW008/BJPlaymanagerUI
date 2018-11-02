//
//  PUPlayOptionsViewController.h
//  BJPlayerManagerUI_Example
//
//  Created by daixijia on 2018/8/2.
//  Copyright © 2018年 oushizishu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveBase/NSObject+BJLYYModel.h>

@interface PUPlayOptions : NSObject <BJLYYModel>

@property (nonatomic, assign) BOOL advertisementEnabled;        // 播放广告
@property (nonatomic, assign) BOOL notAutoStartImageAD;         // 不自动开始
@property (nonatomic, assign) BOOL autoplay;                    // 自动播放
@property (nonatomic, assign) BOOL sliderDragEnabled;           // 能否拖动进度条
@property (nonatomic, assign) BOOL playTimeRecordEnabled;       // 开启记忆播放
@property (nonatomic, assign) BOOL encryptEnabled;              // 开启加密
@property (nonatomic, assign) BOOL backgroundAudioEnabled;      // 开启后台播放
@property (nonatomic, strong) NSString *exclusiveDomain;        // 专属域名

/**
 播放倍速
 
 #discussion 设置播放倍速，如果设置了这个值，之后所有的视频都通过这个倍速来控制
 #discussion 如果在播放视频的时候改变了倍速，将记住该倍速
 */
@property (nonatomic, assign) CGFloat playRate;

/**
 偏好清晰度列表
 
 #discussion 优先使用此列表中的清晰度播放在线视频，优先级按数组元素顺序递减
 #discussion 列表元素为 PMVideoDefinitionType 转换成的 NSNumber， 如 @[@(DT_HIGH)]
 #discussion 此设置对播放视频无效，仅用于下载
 */
@property (nonatomic, strong) NSArray<NSNumber *> *preferredDefinitionList;

/**
 第三方用户名和编号
 
 #discussion 用于上报统计
 */
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger userNumber;

+ (instancetype)shareInstance;

@end

@interface PUPlayOptionsViewController : UIViewController

@end
