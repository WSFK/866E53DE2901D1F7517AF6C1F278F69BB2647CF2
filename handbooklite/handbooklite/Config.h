//
//  Config.h
//  handbooklite
//
//  Created by bao_wsfk on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PathUtils.h"

//默认右下角title字体大小
#define DEFAULT_TITLE_FONT_SIZE        16
//默认控制区按钮字体大小
#define DEFAULT_BUTTON_FONT_SIZE 12
//默认字体
#define DEFAULT_FONT(s) [UIFont fontWithName:@"Microsoft YaHei" size:s]

#define ORIENTATION @"landscape"

#define RESOURCE_PATH [PathUtils resourcePath]
#define CACHE_PATH [PathUtils cachePath]
#define LIBRARY_PATH [PathUtils libraryPath]
#define TMP_PATH [PathUtils tempPath]

#define DB_OLD_PATH [[PathUtils cachePath] stringByAppendingPathComponent:@"books/db.sqlite3"]
#define DB_PATH [[PathUtils cachePath] stringByAppendingPathComponent:@"books/db_v3.sqlite3"]

//#define BASE_URL @"http://192.168.1.102:8085/"
#define BASE_URL @"http://ms.thoughtfactory.com.cn/"
//#define BASE_URL [[[UIDevice currentDevice] model] isEqualToString:@"iPad Simulator"]?@"http://192.168.1.100:8085/":@"http://ms.thoughtfactory.com.cn/"

#define VERIFY_URL [NSString stringWithFormat:@"%@%@",BASE_URL,@"client/interface_bookInfov3"]
#define DOWNLOAD_URL [NSString stringWithFormat:@"%@%@",BASE_URL,@"client/interface_qxz"]

//日志提交接口
#define LOGCOMMIT_URL [NSString stringWithFormat:@"%@%@",BASE_URL,@"client/interface_sblog"]

//请求pdf下载地址
#define PDFREQUEST [NSString stringWithFormat:@"%@%@",BASE_URL,@"client/interface_pdfUrl?"]
//网站帮助页面地址
#define WEBHELP [NSString stringWithFormat:@"%@help",BASE_URL]
//四维册阅读版appstore中下载地址
#define HANDBOOKLITEAPPSTORE  @"https://itunes.apple.com/us/app/si-wei-ce-yue-du/id573415099?mt=8"


#define HELP_DOWNNUM @"TFFLHELP"