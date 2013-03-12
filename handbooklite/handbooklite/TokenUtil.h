//
//  TokenUtil.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-18.
//
//

#import <Foundation/Foundation.h>

@interface TokenUtil : NSObject

+ (NSString *)getLocalToken;

+ (void)updateLocalToken:(NSString *)token;

@end
