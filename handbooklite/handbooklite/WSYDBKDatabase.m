//
//  WSYDBKDatabase.m
//  handbooklite
//
//  Created by bao_wsfk on 13-3-27.
//
//

#import "WSYDBKDatabase.h"

@implementation WSYDBKDatabase

static WSYDBKDatabase *dbInstance =nil;

@synthesize fmdatabse;

+ (id)newInstance{
    
    @synchronized(self){
        if (dbInstance ==nil) {
            dbInstance =[[WSYDBKDatabase alloc] init];
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
        self.fmdatabse = [FMDatabase databaseWithPath:DB_OLD_PATH];
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
