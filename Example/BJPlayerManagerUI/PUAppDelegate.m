//
//  PUAppDelegate.m
//  BJPlayerManagerUI
//
//  Created by oushizishu on 06/02/2017.
//  Copyright (c) 2017 oushizishu. All rights reserved.
//

#import <IQKeyboardManager/IQKeyboardManager.h>
#import <BJPlayerManagerCore/BJPlayerManagerCore.h>
#import <Reachability/Reachability.h>
#import <Foundation/Foundation.h>
#import "PUMainViewController.h"
#import "PUAppDelegate.h"

#import "UIWindow+PUMotion.h"
#import "UIViewController+PUUtil.h"
//#import <Bugly/Bugly.h>
//
//#if DEBUG
//#import <FLEX/FLEXManager.h>
//#endif


#import "UIViewController+PUUtil.h"
#import "UIWindow+PUMotion.h"

@interface PUAppDelegate()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@end

@implementation PUAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    PUMainViewController *vc = [[PUMainViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
    // !!!: 使用前请仔细阅读 iOS 文件存储文档 https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW28
    NSString *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL];
    if (!exists) {
        NSError *error = nil;
        exists = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!exists) {
            NSLog(@"%@", error.localizedDescription);
            NSAssert(exists, error.localizedDescription);
        }
    }
    
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    // !!!: 避免下载目录被备份到 iCloud、占用过多 iCloud 存储空间
    if (![url setResourceValue:@YES
                        forKey:NSURLIsExcludedFromBackupKey
                         error:&error]) {
        NSLog(@"Error excluding %@ from backup %@", url.lastPathComponent, error.localizedDescription);
    }
    else {
        NSLog(@"Yay");
    }
    
    //使用BJDownloadManager时需要设置根路径
    [[BJCommonHelper sharedCommonHelper] setRootPath:path];
    //或者使用PMDownloadManager时需要设置根路径
    [PMDownloadManager downloadManagerWithRootPath:path];
    
    NSLog(@"PUAppDelegate---didFinishLaunchingWithOptions");
    [self chooseResumeActionInapplicationWillEnterForeground];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //即将退到后台
    NSLog(@"PUAppDelegate---applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"PUAppDelegate---applicationDidEnterBackground");
    if([[PMDownloadManager downloadManager].downloadingList count]) {
        NSMutableArray<PMDownloader *> *downloadingList = [NSMutableArray arrayWithArray:[PMDownloadManager downloadManager].downloadingList];
        for (PMDownloader *downloader in downloadingList) {
            if (downloader.downloadModel.state == PMDownloadState_Start) {
                if(downloader.downloadModel.downloadFileType == PMDownloadFileType_Video) {
                    NSLog(@"pause vid: %@", downloader.downloadModel.vid);
                    [[PMDownloadManager downloadManager] pause:downloader.downloadModel.vid];
                }
                else {
                    NSLog(@"pause classid: %@", downloader.downloadModel.classId);
                    [[PMDownloadManager downloadManager] pause:downloader.downloadModel.classId sessionId:downloader.downloadModel.sessionId];
                }
            }
        }
    }
    [self comeToBackgroundMode];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //即将进入前台.判断如果是wifi,就自动resume,否则就弹框给用户选择
    NSLog(@"PUAppDelegate---applicationWillEnterForeground");
    
    //进前台的时候结束掉bgTask
    if (self.bgTask != UIBackgroundTaskInvalid) {
        UIApplication *app = [UIApplication sharedApplication];
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
    
    [self chooseResumeActionInapplicationWillEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"PUAppDelegate---applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"PUAppDelegate---applicationWillTerminate");
}

#pragma mark - private

-(void)comeToBackgroundMode{
    //初始化一个后台任务BackgroundTask，这个后台任务的作用就是告诉系统当前app在后台有任务处理，需要时间
    UIApplication *app = [UIApplication sharedApplication];
    @YPWeakObj(self);
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        @YPStrongObj(self);
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
}

//app即将进入前台的时候,如果是wifi就自动下载,否则如果有下载任务就弹框让用户选择,
//如果用户设置了app只在wifi下使用,那就算有4g网,也不会弹框给用户选择
- (void)chooseResumeActionInapplicationWillEnterForeground {
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    static BOOL alwaysResume = NO;
    switch ([reach currentReachabilityStatus]) {
        case NotReachable: {
            break;
        }
        case ReachableViaWiFi: {
            NSArray<PMDownloader *> *downloadingList = [PMDownloadManager downloadManager].downloadingList;
            [self resumeDownloadingList:downloadingList];
            break;
        }
        default: {
            NSArray<PMDownloader *> *downloadingList = [PMDownloadManager downloadManager].downloadingList;
            if (downloadingList.count <= 0) break;
            
            if (alwaysResume) {
                [self resumeDownloadingList:downloadingList];
                break;
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"正在使用蜂窝网络，是否恢复未完成的下载任务？" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"恢复" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self resumeDownloadingList:downloadingList];
            }];
            
            UIAlertAction *alwaysAction = [UIAlertAction actionWithTitle:@"恢复且不再提示" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                alwaysResume = YES;
                [self resumeDownloadingList:downloadingList];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [alert addAction:sureAction];
            [alert addAction:alwaysAction];
            [alert addAction:cancelAction];
            
            [self.window.rootViewController presentViewController:alert animated:NO completion:nil];
            
            break;
        }
    }
}

- (void)resumeDownloadingList:(NSArray<PMDownloader *> *)downloadingList {
    for (PMDownloader *downloader in downloadingList) {
        if (downloader.downloadModel.state == PMDownloadState_Suspended
            || downloader.downloadModel.state == PMDownloadState_Failed) {
            
            if(downloader.downloadModel.downloadFileType == PMDownloadFileType_Video) {
                NSLog(@"resume vid:%@", downloader.downloadModel.vid);
                [[PMDownloadManager downloadManager] resume:downloader.downloadModel.vid];
            }
            else {
                NSLog(@"resume classid:%@", downloader.downloadModel.classId);
                [[PMDownloadManager downloadManager] resume:downloader.downloadModel.classId sessionId:downloader.downloadModel.sessionId];
            }
        }
    }
}

@end
