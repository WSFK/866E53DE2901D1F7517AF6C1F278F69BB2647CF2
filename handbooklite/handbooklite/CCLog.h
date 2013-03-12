//
//  CCLog.h
//  handbooklite
//
//  Created by bao_wsfk on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifdef DEBUG
#define CCLog(format, ...)  //NSLog(format, ## __VA_ARGS__)
#else
#define CCLog(format, ...)
#endif
