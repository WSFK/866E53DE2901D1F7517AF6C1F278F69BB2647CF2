//
//  WeiXinShare.h
//  handbooklite
//
//  Created by bao_wsfk on 13-7-2.
//
//

#import <Foundation/Foundation.h>

@interface WeiXinShare : NSObject

+ (void)sendShareWithImage:(UIImage *)image description:(NSString *)desc url:(NSString *)url;

@end
