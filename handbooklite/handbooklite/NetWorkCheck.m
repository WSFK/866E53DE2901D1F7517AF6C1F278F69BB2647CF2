//
//  NetWorkCheck.m
//  handbooklite
//
//  Created by bao_wsfk on 12-10-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NetWorkCheck.h"
#import "Reachability.h"

#define NETWORK_STATE_NOT_REACHABLE @"notreachable"
#define NETWORK_STATE_REACHABLE_VIAWWAN @"reachableviaWWAN"
#define NETWORK_STATE_REACHABLE_VIAWIFI @"reachableviaWiFi"

@implementation NetWorkCheck

+ (BOOL)checkIs3G{
    
    if ([[NetWorkCheck netWorkState] isEqualToString:NETWORK_STATE_REACHABLE_VIAWWAN])
    {
        return YES;
    }
    return NO;
}

+ (BOOL)checkReachable{
    
    if ([[NetWorkCheck netWorkState] isEqualToString:NETWORK_STATE_NOT_REACHABLE])
    {
        return NO;
    }
    return YES;
}

+ (NSString *)netWorkState{
    
    NSString *state= [NSString string];
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            state =NETWORK_STATE_NOT_REACHABLE;
            break;
        case ReachableViaWWAN:
            state=NETWORK_STATE_REACHABLE_VIAWWAN;
            break;
        case ReachableViaWiFi:
            state=NETWORK_STATE_REACHABLE_VIAWIFI;
    }
    return state;
}


@end
