//
//  Book.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-10.
//
//

#import <Foundation/Foundation.h>

#define STATUS_already_enter_code               @"already_enter_code"//已录码
#define STATUS_already_enter_code_suspend       @"already_enter_code_suspend"//已录码暂停(未验证)
#define STATUS_already_enter_code_not_found     @"already_enter_code_not_found"//已录码未找到
#define STATUS_already_enter_code_not_share     @"already_enter_code_not_share"//已录码未发布
#define STATUS_already_enter_code_out_date      @"already_enter_code_out_date"//已录码已过期

#define STATUS_downloading                      @"downloading"//下载中
#define STATUS_downloading_suspend              @"downloading_suspend"//下载中暂停
#define STATUS_downloading_waitting             @"downloading_waitting"//下载中等待
#define STATUS_downloading_exception            @"downloading_exception"//下载中异常
#define STATUS_already_download                 @"already_download"//已下载


#define OPEN_STATUS_YES                         @"yes"//已打开
#define OPEN_STATUS_NO                          @"no"//未打开

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
    NSString *openstatus;
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
@property (nonatomic, copy) NSString *openstatus;

- (NSString *)getIconName;
@end
