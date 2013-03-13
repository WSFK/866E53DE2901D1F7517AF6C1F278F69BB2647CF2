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
+ (NSString *) getDeviceId;   //获取设备id
+(NSString*) getDayString;    //获取当前时间字符串
+(UIImage *) getShareTwoCode:(NSString *) currentBookDownNum; //获取分享用二维码

@end
