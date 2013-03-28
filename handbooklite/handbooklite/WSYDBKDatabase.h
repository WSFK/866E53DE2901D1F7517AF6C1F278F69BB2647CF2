//
//  WSYDBKDatabase.h
//  handbooklite
//
//  Created by bao_wsfk on 13-3-27.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "Config.h"

@interface WSYDBKDatabase : NSObject{
    
    FMDatabase *fmdatabse;
}
@property (nonatomic, strong) FMDatabase *fmdatabse;

+ (id)newInstance;

- (void)openDb;

- (void)closeDb;

@end
