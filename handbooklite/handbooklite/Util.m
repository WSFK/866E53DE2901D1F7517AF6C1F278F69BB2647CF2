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

+(NSString *) getShareTwoCodeUrlString:(NSString *) currentBookDownNum{
  NSMutableString *shareUrl = [[NSMutableString alloc] init];
  [shareUrl appendString:DOWNLOAD_URL]; //下载接口地址
  [shareUrl appendFormat:@"?downloadnum=%@",currentBookDownNum];  //参数：下载码
  [shareUrl appendFormat:@"&su=%@",USERUUID];                     //参数：分享者id
  [shareUrl appendFormat:@"&st=%@",[Util getDayString]];          //参数：分享时间
  [shareUrl appendFormat:@"&hash=%d",[shareUrl hash]];            //参数：hash
  return shareUrl;
}

+(UIImage *) getShareTwoCode:(NSString *) currentBookDownNum{
    UIImage *twImage = [QRCodeGenerator qrImageForString:[self getShareTwoCodeUrlString:currentBookDownNum] imageSize:139];
    return twImage;
}

+(void) writeToLog:(NSString *) Uid type:(NSString *) Utype bookId:(NSString *) BookId{
  NSFileManager *fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:LOGFILEPATH]) {
    [@"" writeToFile:LOGFILEPATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
  }
  
  NSString *logString = [NSString stringWithContentsOfFile:LOGFILEPATH encoding:NSUTF8StringEncoding error:nil];
  NSDictionary *logDict = [logString objectFromJSONString];
  NSMutableArray *logArray = [[NSMutableArray alloc] init];
  if ([logDict objectForKey:@"logs"] != nil) {
    [logArray addObjectsFromArray:[logDict objectForKey:@"logs"]];
  }
  NSDictionary *log = @{@"logtime":[self getDayString],@"uid":Uid,@"type":Utype,@"bookid":BookId};
  [logArray addObject:[log JSONString]];
  
  NSString *outLog = [NSString stringWithFormat:@"{\"logs\":%@}", [logArray JSONString] ];
  [outLog writeToFile:LOGFILEPATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+(BOOL) commitLog{
    
    BOOL result =NO;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:LOGFILEPATH]) {
        NSString *logString = [NSString stringWithContentsOfFile:LOGFILEPATH encoding:NSUTF8StringEncoding error:nil];
        NSString *commitString = [NSString stringWithFormat:@"loginfo=%@",logString];
        NSData *commitData = [commitString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURL * requestUrl = [[NSURL alloc] initWithString:LOGCOMMIT_URL];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:requestUrl cachePolicy:0 timeoutInterval:10];
        [request setHTTPBody:commitData];
        [request setHTTPMethod:@"POST"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSDictionary *json = [data objectFromJSONData];
        
        if (json != nil) {
            NSDictionary *message = [json objectForKey:@"message"];
            NSLog(@"%@",[message objectForKey:@"status"]);
            if ([[message objectForKey:@"status"] isEqualToString:@"sucess"]) {
                [fm removeItemAtPath:LOGFILEPATH error:nil];
                result =YES;
            }
        }
    }
    return result;
}
    
+ (NSUInteger)daysOfFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    unsigned int unitFlags =NSDayCalendarUnit;
    
    NSCalendar *calendar =[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *comps =[calendar components:unitFlags fromDate:fromDate toDate:toDate options:0];
    
    return [comps day];
}
@end
