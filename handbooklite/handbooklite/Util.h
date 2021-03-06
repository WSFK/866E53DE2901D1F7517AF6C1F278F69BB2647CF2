//
//  Util.h
//  handbooklite
//
//  Created by han on 13-3-12.
//
//

#import <Foundation/Foundation.h>
#import "PublicImport.h"
#import "QRCodeGenerator.h"

@interface Util : NSObject
//+ (NSString *) getDeviceId;   //获取设备id

+(NSString*) getDayString;    //获取当前时间字符串

//拼接客户端分享下载链接
+(NSString *) getShareTwoCodeUrlString:(NSString *) currentBookDownNum;
//把客户分享链接转为二维码
+(UIImage *) getShareTwoCode:(NSString *) currentBookDownNum; //获取分享用二维码

/**
 记录日志
 参数：使用者id，记录类型:打开推送、打开新增，打开书的id
 **/
+(void) writeToLog:(NSString *) Uid type:(NSString *) Utype bookId:(NSString *) BookId;

+(BOOL) commitLog;

//计算两个日期之间相差的天数
+ (NSUInteger)daysOfFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

+ (BOOL)isUrl:(NSString *)url;

//+(BOOL) getValueFromPlist:(NSString *) key;

//+(void) writeValueToPlist:(NSString *) key value:(BOOL) value;

+ (NSString *)getAppVersionFromSettingOfString;

+ (double)getAppVersionFromSetting;

+ (NSString *)getAppVersionFromAppInfoOfString;

+ (double)getAppVersionFromAppInfo;

+ (BOOL)isAppVersionUpdate;

+ (BOOL)updateAppVersionToSetting;

+ (BOOL)updateAppVersionToSetting:(NSString *)currentAppVersion;

+ (NSString *)subFileName:(NSString *)filePath;

@end
