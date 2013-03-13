//
//  PublicImport.h
//  handbooklite
//
//  Created by han on 13-3-12.
//
//

#ifndef handbooklite_PublicImport_h
#define handbooklite_PublicImport_h

#import "UUID.h"
#import "Util.h"
#import "Config.h"
#import "TokenUtil.h"
#import "JSONKit.h"

#define DEVICEUUID [Util getDeviceId]
#define USERUUID [UUID getUUIDToString]
#define DEVICETOKEN [TokenUtil getLocalToken]

#endif
