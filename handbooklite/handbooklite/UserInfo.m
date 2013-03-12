//
//  UserInfo.m
//  handbooklite
//
//  Created by bao_wsfk on 13-3-8.
//
//

#import "UserInfo.h"
#import "UUID.h"

@implementation UserInfo

+ (NSString *)getUID{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"uid"] !=nil) {
        return [defaults objectForKey:@"uid"];
    }
    
    NSString *uid =[UUID getUUIDToString];
    
    [defaults setObject:uid forKey:@"uid"];
    [defaults synchronize];
    return uid;
}

@end
