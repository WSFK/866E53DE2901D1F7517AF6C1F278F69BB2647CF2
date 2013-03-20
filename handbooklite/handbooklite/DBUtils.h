//
//  DBUtils.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-10.
//
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface DBUtils : NSObject

+ (BOOL)insertBook:(Book *)book;

+ (NSMutableArray *)queryAllBooks;

//判断手册是否存在
+ (BOOL)isExistBookByDownnum:(NSString *)downnum;

+ (BOOL)deleteBookById:(NSInteger)bookId;

+ (BOOL)deleteBookByDownnum:(NSString *)downnum;

+ (Book *)queryBookById:(NSInteger)bookId;

+ (Book *)queryBookByDownnum:(NSString *)downnum;

+ (BOOL)updateBook:(Book *) book;

+ (BOOL)isHasStatusDownloading;

//查询所有未验证的手册
+ (NSMutableArray *)queryAllBookNotVerify;

+ (BOOL)updateBookStatus:(NSString *)status downnum:(NSString *)downnum;

+ (BOOL)updateOpenStatus:(NSString *)status downnum:(NSString *)downnum;


@end
