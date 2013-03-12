//
//  TokenUtil.m
//  handbooklite
//
//  Created by bao_wsfk on 12-12-18.
//
//

#import "TokenUtil.h"

@implementation TokenUtil

+ (NSString *)getLocalToken{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"token"];
}

+ (void)updateLocalToken:(NSString *)token{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token"];
    [defaults synchronize];
}

@end
