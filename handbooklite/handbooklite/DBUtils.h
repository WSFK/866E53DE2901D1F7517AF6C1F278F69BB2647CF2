//
//  DBUtils.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-10.
//
//

#import <Foundation/Foundation.h>
#import "Book.h"
#import "Temp.h"

@interface DBUtils : NSObject

+ (void)insertBook:(Book *)book;

+ (NSMutableArray *)queryAllBooks;

//判断手册是否存在
+ (BOOL)isExistBookByDownnum:(NSString *)downnum;

+ (BOOL)deleteBookById:(NSInteger)bookId;

+ (BOOL)deleteBookByDownnum:(NSString *)downnum;

+ (Book *)queryBookById:(NSInteger)bookId;

+ (Book *)queryBookByDownnum:(NSString *)downnum;

+ (BOOL)updateBook:(Book *) book;



//下载缓存表
+ (BOOL)insertTemp:(Temp *)temp;

+ (NSMutableArray *)queryAllTemps;

+ (BOOL)deleteTempById:(NSInteger)tempId;

+ (Temp *)queryTempById:(NSInteger)tempId;

+ (BOOL)isExisttempByDownnum:(NSString *)downnum;

@end
