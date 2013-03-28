//
//  WSYDDatabase.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-10.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "Config.h"

@interface WSYDDatabase : NSObject{
    
    FMDatabase *fmdatabse;
}
@property (nonatomic, strong) FMDatabase *fmdatabse;

+ (id)newInstance;

- (void)openDb;

- (void)closeDb;

@end
