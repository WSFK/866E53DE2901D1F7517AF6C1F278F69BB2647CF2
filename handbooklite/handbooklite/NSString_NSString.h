//
//  NSString_NSString.h
//  handbook
//
//  Created by bao_wsfk on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_extension)

- (BOOL)isValidateEmail;

- (NSString *)trim;

- (BOOL)isEmpty;

@end



@implementation NSString (NSString_extension)

- (BOOL)isValidateEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:self];
}

-(NSString *)trim{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL)isEmpty{
    return [[self trim] isEqualToString:@""]?YES:NO;
}

@end