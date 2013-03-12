//
//  WSYDDatabase.m
//  handbooklite
//
//  Created by bao_wsfk on 12-12-10.
//
//

#import "WSYDDatabase.h"
#import "FMDatabase.h"
#import "Config.h"

@implementation WSYDDatabase

static WSYDDatabase *dbInstance =nil;

@synthesize fmdatabse;

+ (id)newInstance{
    
    @synchronized(self){
        if (dbInstance ==nil) {
            dbInstance =[[WSYDDatabase alloc] init];
            [dbInstance openDb];
        }
    }
    return dbInstance;
}


+ (id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if(dbInstance ==nil){
            dbInstance =[super allocWithZone:zone];
        }
    }
    return dbInstance;
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (void)openDb{
    if (!self.fmdatabse) {
        self.fmdatabse = [FMDatabase databaseWithPath:DB_PATH];
        [self.fmdatabse open];
    }
}

- (void)closeDb{
    if (self.fmdatabse) {
        [self.fmdatabse close];
        dbInstance = nil;
    }
}

@end
