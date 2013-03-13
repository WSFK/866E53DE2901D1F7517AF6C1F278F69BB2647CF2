//
//  Util.m
//  handbooklite
//
//  Created by han on 13-3-12.
//
//

#import "Util.h"

@implementation Util
+ (NSString *) getDeviceId{
  NSString *deviceId = [[UIDevice currentDevice] uniqueIdentifier];
  return deviceId;
}

+(NSString*) getDayString{
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
  
  NSDate *now = [[NSDate alloc] init];
  NSString *nowString = [dateFormat stringFromDate:now];
  return nowString;
}

+(UIImage *) getShareTwoCode:(NSString *) currentBookDownNum{
  NSMutableString *shareUrl = [[NSMutableString alloc] init];
  [shareUrl appendString:DOWNLOAD_URL]; //下载接口地址
  [shareUrl appendFormat:@"?su=%@",USERUUID];          //参数：分享者id
  [shareUrl appendFormat:@"&st=%@",[Util getDayString]];          //参数：分享时间
  [shareUrl appendFormat:@"&downloadnum=%@",currentBookDownNum];          //参数：下载码
  [shareUrl appendFormat:@"&hash=%d",[shareUrl hash]];          //参数：hash
  
  UIImage *twImage = [QRCodeGenerator qrImageForString:shareUrl imageSize:139];
  return twImage;
}
@end
