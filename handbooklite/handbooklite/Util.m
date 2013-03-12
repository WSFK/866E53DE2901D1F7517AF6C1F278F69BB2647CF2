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
@end
