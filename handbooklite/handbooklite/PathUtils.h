//
//  PathUtils.h
//  handbook
//
//  Created by bao_wsfk on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathUtils : NSObject

+ (NSString *)resourcePath;

+ (NSString *)cachePath;

+ (NSString *)libraryPath;

+ (NSString *)tempPath;

+(NSString*) getDayString;
@end
