//
//  HttpHeader.m
//  handbook
//
//  Created by bao_wsfk on 12-11-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HttpHeader.h"

@implementation HttpHeader

static HttpHeader *instance =nil;
@synthesize tapTimes;

+ (id)shareInstance{
    
    @synchronized(self){
        if (instance == nil) {
            instance = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return instance;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareInstance] retain];
}

- (id) copyWithZone:(NSZone*)zone
{
    return self;
}

- (NSString *)httpHeader{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"httpHeader"]==nil?@"":[(NSString *)[defaults objectForKey:@"httpHeader"] stringByAppendingFormat:@"/"];    
}

- (void)updateHttpHeader:(NSString *)httpHeader{
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults setObject:httpHeader forKey:@"httpHeader"];
    [defaults synchronize];
}

@end
