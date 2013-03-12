//
//  PathUtils.m
//  handbook
//
//  Created by bao_wsfk on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PathUtils.h"

@implementation PathUtils

+ (NSString *)resourcePath{
    return [[NSBundle mainBundle]resourcePath];
}

+ (NSString *)documentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
            lastObject];
}

+ (NSString *)cachePath{
    NSString *cache =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
                      lastObject];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cache]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return cache;
}

+ (NSString *)libraryPath{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) 
             lastObject];
}

+ (NSString *)tempPath{
    
    return [[[PathUtils documentPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"tmp"];
}

+(NSString*) getDayString{
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyyMMddHHmmssSSS"];
  
  NSDate *now = [[NSDate alloc] init];
  NSString *nowString = [dateFormat stringFromDate:now];
  return nowString;
}

@end
