//
//  Book.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-10.
//
//

#import <Foundation/Foundation.h>

#define STATUS_already_enter_code           @"already_enter_code"
#define STATUS_already_enter_code_suspend   @"already_enter_code_suspend"
#define STATUS_already_enter_code_error     @"already_enter_code_error"
#define STATUS_downloading                  @"downloading"
#define STATUS_downloading_suspend          @"downloading_suspend"
#define STATUS_downloading_waitting         @"downloading_waitting"
#define STATUS_downloading_exception        @"downloading_exception"
#define STATUS_already_download             @"already_download"
#define STATUS_already_download_not_look    @"already_download_not_look"

@interface Book : NSObject{
    
    NSInteger ID;
    NSString *name;
    NSString *downnum;
    NSString *dir;
    NSString *zip;
    NSString *icon;
    NSString *bookId;
    NSString *status;
    NSString *su;
    NSString *st;
    NSString *hash;
}

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *downnum;
@property (nonatomic, copy) NSString *dir;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *bookId;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *su;
@property (nonatomic, copy) NSString *st;
@property (nonatomic, copy) NSString *hash;

- (NSString *)getIconName;
@end
