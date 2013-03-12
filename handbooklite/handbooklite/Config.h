//
//  Config.h
//  handbooklite
//
//  Created by bao_wsfk on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PathUtils.h"

#define ORIENTATION @"landscape"

#define RESOURCE_PATH [PathUtils resourcePath]
#define CACHE_PATH [PathUtils cachePath]
#define LIBRARY_PATH [PathUtils libraryPath]
#define TMP_PATH [PathUtils tempPath]

#define DB_PATH [[PathUtils cachePath] stringByAppendingPathComponent:@"books/db.sqlite3"]

//#define BASE_URL @"http://192.168.1.100:8085/"
#define BASE_URL @"http://ms.thoughtfactory.com.cn/"
//#define BASE_URL [[[UIDevice currentDevice] model] isEqualToString:@"iPad Simulator"]?@"http://192.168.1.100:8085/":@"http://ms.thoughtfactory.com.cn/"
#define DOWNLOAD_URL [NSString stringWithFormat:@"%@%@",BASE_URL,@"client/interface_bookInfo"]

#define HELP_DOWNNUM @"TFFLHELP"