//
//  UUID.m
//  handbooklite
//
//  Created by bao_wsfk on 13-3-8.
//
//

#import "UUID.h"

@implementation UUID

+ (NSString *)getUUIDToString{
    
    CFUUIDRef uuid_ref =CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref =CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    
    NSString *uuid =[NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    
    return uuid;
}

+ (NSString *) getDeviceId{
  NSString *deviceId = [[UIDevice currentDevice] uniqueIdentifier];
  return deviceId;
}
@end
