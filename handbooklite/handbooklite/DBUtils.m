//
//  DBUtils.m
//  handbooklite
//
//  Created by bao_wsfk on 12-12-10.
//
//

#import "DBUtils.h"
#import "WSYDDatabase.h"
#import "FMDatabase.h"

@implementation DBUtils


+ (void)insertBook:(Book *)book{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    [db beginTransaction];
    
    [db executeUpdate:@"insert into t_book (name,downnum,dir,zip,icon,bookid) values(?,?,?,?,?,?)",
        book.name,
        book.downnum,
        book.dir,
        book.zip,
        book.icon,
        book.bookId];
    
    [db commit];
    
    [[WSYDDatabase newInstance] closeDb];
}

+ (BOOL)insertTemp:(Temp *)temp{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    [db beginTransaction];
    
    BOOL result =NO;

    result =[db executeUpdate:@"insert into t_temp (name,downnum,savedate) values(?,?,?)",
     temp.name,
     temp.downnum,
     temp.savedate];
    
    [db commit];
    
    [[WSYDDatabase newInstance] closeDb];
    return result;
}

+ (NSMutableArray *)queryAllBooks{
    
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    
    FMResultSet *res =[db executeQuery:@"SELECT * FROM t_book order by id"];
    
     NSMutableArray *books = [[NSMutableArray alloc] init];
    while ([res next]) {
        
        Book *book = [[Book alloc] init];
        [book setID:[res intForColumn:@"id"]];
        [book setName:[res stringForColumn:@"name"]];
        [book setDownnum:[res stringForColumn:@"downnum"]];
        [book setDir:[res stringForColumn:@"dir"]];
        [book setZip:[res stringForColumn:@"zip"]];
        [book setIcon:[res stringForColumn:@"icon"]];
        [book setBookId:[res stringForColumn:@"bookid"]];
        [books addObject:book];
    }
    
    [[WSYDDatabase newInstance] closeDb];
    return books;
}

+ (NSMutableArray *)queryAllTemps{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    
    FMResultSet *res =[db executeQuery:@"SELECT * FROM t_temp order by id"];
    
    NSMutableArray *temps = [[NSMutableArray alloc] init];
    while ([res next]) {
        
        Temp *temp =[[Temp alloc] init];
        [temp setID:[res intForColumn:@"id"]];
        [temp setName:[res stringForColumn:@"name"]];
        [temp setDownnum:[res stringForColumn:@"downnum"]];
        [temp setSavedate:[res dateForColumn:@"savedate"]];
        [temps addObject:temp];
    }
    
    [[WSYDDatabase newInstance] closeDb];
    return temps;
}

+ (BOOL)isExistBookByDownnum:(NSString *)downnum{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    FMResultSet *res =[db executeQuery:@"SELECT * FROM t_book where downnum =?",downnum];
    
    if([res next]){
        
        [[WSYDDatabase newInstance] closeDb];
        return YES;
    }
    [[WSYDDatabase newInstance] closeDb];
    return NO;
}

+ (BOOL)isExisttempByDownnum:(NSString *)downnum{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    FMResultSet *res =[db executeQuery:@"SELECT * FROM t_temp where downnum =?",downnum];
    
    if([res next]){
        
        [[WSYDDatabase newInstance] closeDb];
        return YES;
    }
    [[WSYDDatabase newInstance] closeDb];
    return NO;
}

+ (BOOL)deleteBookById:(NSInteger)bookId{
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    
    BOOL result =NO;
    
    if([db beginTransaction]){
        
        result =[db executeUpdate:@"delete from t_book where id=?",[NSNumber numberWithInteger:bookId]];
        
        [db commit];
    }
    [[WSYDDatabase newInstance] closeDb];
    return result;
}

+ (BOOL)deleteBookByDownnum:(NSString *)downnum{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    
    BOOL result =NO;
    
    if([db beginTransaction]){
        
        result =[db executeUpdate:@"delete from t_book where downnum=?",downnum];
        
        [db commit];
    }
    [[WSYDDatabase newInstance] closeDb];
    
    return result;
}

+ (BOOL)deleteTempById:(NSInteger)bookId{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    
    BOOL result =NO;
    
    if([db beginTransaction]){
        
        result =[db executeUpdate:@"delete from t_temp where id=?",[NSNumber numberWithInteger:bookId]];
        
        [db commit];
    }
    [[WSYDDatabase newInstance] closeDb];
    
    return result;
}

+ (Book *)queryBookById:(NSInteger)bookId{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    
    FMResultSet *res =[db executeQuery:@"select * from t_book where id =?",[NSNumber numberWithInteger:bookId]];
    if([res next]){
        Book *book =[[Book alloc] init];
        [book setID:[res intForColumn:@"id"]];
        [book setName:[res stringForColumn:@"name"]];
        [book setDownnum:[res stringForColumn:@"downnum"]];
        [book setDir:[res stringForColumn:@"dir"]];
        [book setZip:[res stringForColumn:@"zip"]];
        [book setIcon:[res stringForColumn:@"icon"]];
        [book setBookId:[res stringForColumn:@"bookid"]];
        
        [[WSYDDatabase newInstance] closeDb];
        
        return book;
    }
    [[WSYDDatabase newInstance] closeDb];
    return nil;
}

+ (Temp *)queryTempById:(NSInteger)bookId{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    
    FMResultSet *res =[db executeQuery:@"select * from t_temp where id =?",[NSNumber numberWithInteger:bookId]];
    if([res next]){
        Temp *temp =[[Temp alloc] init];
        [temp setID:[res intForColumn:@"id"]];
        [temp setName:[res stringForColumn:@"name"]];
        [temp setDownnum:[res stringForColumn:@"downnum"]];
        [temp setSavedate:[res dateForColumn:@"savedate"]];
        
        [[WSYDDatabase newInstance] closeDb];
        return temp;
    }
    [[WSYDDatabase newInstance] closeDb];
    return nil;
}

+ (Book *)queryBookByDownnum:(NSString *)downnum{
    
    FMDatabase *db =[WSYDDatabase newInstance].fmdatabse;
    
    FMResultSet *res =[db executeQuery:@"select * from t_book where downnum =?",downnum];
    if ([res next]) {
        Book *book =[[Book alloc] init];
        [book setID:[res intForColumn:@"id"]];
        [book setName:[res stringForColumn:@"name"]];
        [book setDownnum:[res stringForColumn:@"downnum"]];
        [book setDir:[res stringForColumn:@"dir"]];
        [book setZip:[res stringForColumn:@"zip"]];
        [book setIcon:[res stringForColumn:@"icon"]];
        [book setBookId:[res stringForColumn:@"bookid"]];
        [book setStatus:[res stringForColumn:@"status"]];
        [book setSu:[res stringForColumn:@"su"]];
        [book setSt:[res stringForColumn:@"st"]];
        [book setHash:[res stringForColumn:@"hash"]];
        
        [[WSYDDatabase newInstance] closeDb];
        
        return book;
    }
    [[WSYDDatabase newInstance] closeDb];
    return nil;
}

+ (BOOL)updateBook:(Book *)book{
    
    FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
    
    BOOL result =NO;
    
    if([db beginTransaction]){
        
        result =[db executeUpdate:@"update t_book set name=?,downnum=?,dir=?,zip=?,icon=?,bookid=?,status=? where id=?",
                 book.name,
                 book.downnum,
                 book.dir,
                 book.zip,
                 book.icon,
                 book.bookId,
                 book.status,
                 [NSNumber numberWithInteger:book.ID]];
        
        [db commit];
    }
    [[WSYDDatabase newInstance] closeDb];
    
    return result;
}


@end
