//
//  NetWorkCheck.h
//  handbooklite
//
//  Created by bao_wsfk on 12-10-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetWorkCheck : NSObject

+ (BOOL)checkIs3G;

//查看能否联网
+ (BOOL)checkReachable;

@end
