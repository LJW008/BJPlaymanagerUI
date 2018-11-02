//
//  NSString+md5.h
//  BJPlayerManagerUI
//
//  Created by 辛亚鹏 on 2017/6/22.
//  Copyright © 2017年 oushizishu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (md5)

/**
 获取string的MD5
 
 @return MD5
 */
- (NSString *)pm_stringFromMD5;

/**
 获取文件 MD5, 需要使用文件绝对路径来调用
 
 @return MD5
 */
- (NSString *)pm_fileMD5;

- (NSString *)pm_SHA1StringWithKey:(NSString *)key;
- (NSString *)pm_SHA256StringWithKey:(NSString *)key;
- (NSString *)pm_SHA512StringWithKey:(NSString *)key;

@property (readonly) NSString *md5String;
@property (readonly) NSString *sha1String;
@property (readonly) NSString *sha256String;
@property (readonly) NSString *sha512String;

@end
