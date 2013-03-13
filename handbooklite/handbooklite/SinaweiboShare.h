//
//  SinaweiboShare.h
//  handbook
//
//  Created by bao_wsfk on 12-10-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinaWeibo.h"

@interface SinaweiboShare : NSObject<SinaWeiboDelegate,SinaWeiboRequestDelegate>{
    
    NSMutableDictionary *data;
}

+ (SinaweiboShare *)sharedInstance;

- (void)login;

- (void)logout;

- (void)postMessage:(NSString *)message withPic:(UIImage *)pic;


@end
