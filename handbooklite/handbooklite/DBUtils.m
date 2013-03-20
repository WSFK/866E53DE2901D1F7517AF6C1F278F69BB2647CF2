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

//-------------------------手册表操作-------------------------------------------------------------

+ (BOOL)insertBook:(Book *)book{
  
  FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
  [db beginTransaction];
  
  BOOL result =[db executeUpdate:@"insert into t_book (name,downnum,dir,zip,icon,bookid,status,su,st,hash,openstatus) values(?,?,?,?,?,?,?,?,?,?,?)",
                book.name,
                book.downnum,
                book.dir,
                book.zip,
                book.icon,
                book.bookId,
                book.status,
                book.su,
                book.st,
                book.hash,
                book.openstatus];
  
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
    [book setStatus:[res stringForColumn:@"status"]];
    [book setSu:[res stringForColumn:@"su"]];
    [book setSt:[res stringForColumn:@"st"]];
    [book setHash:[res stringForColumn:@"hash"]];
    [book setOpenstatus:[res stringForColumn:@"openstatus"]];
    
    [books addObject:book];
  }
  
  [[WSYDDatabase newInstance] closeDb];
  return books;
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
    [book setStatus:[res stringForColumn:@"status"]];
    [book setSu:[res stringForColumn:@"su"]];
    [book setSt:[res stringForColumn:@"st"]];
    [book setHash:[res stringForColumn:@"hash"]];
    [book setOpenstatus:[res stringForColumn:@"openstatus"]];
    
    [[WSYDDatabase newInstance] closeDb];
    
    return book;
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
    [book setOpenstatus:[res stringForColumn:@"openstatus"]];
    
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
    
    result =[db executeUpdate:@"update t_book set name=?,downnum=?,dir=?,zip=?,icon=?,bookid=?,status=?,openstatus=? where id=?",
             book.name,
             book.downnum,
             book.dir,
             book.zip,
             book.icon,
             book.bookId,
             book.status,
             book.openstatus,
             [NSNumber numberWithInteger:book.ID]];
    
    [db commit];
  }
  [[WSYDDatabase newInstance] closeDb];
  
  return result;
}

+ (BOOL)isHasStatusDownloading{
  
  FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
  
  BOOL result =NO;
  FMResultSet *res =[db executeQuery:@"select id from t_book where status =?",STATUS_downloading];
  
  if ([res next]) {
    result =YES;
  }
  return result;
}

+ (NSMutableArray *)queryAllBookNotVerify{
  
  FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
  
  FMResultSet *res =[db executeQuery:@"select * from t_book where status =?",STATUS_already_enter_code];
  
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
    [book setStatus:[res stringForColumn:@"status"]];
    [book setSu:[res stringForColumn:@"su"]];
    [book setSt:[res stringForColumn:@"st"]];
    [book setHash:[res stringForColumn:@"hash"]];
    [book setOpenstatus:[res stringForColumn:@"openstatus"]];
    
    [books addObject:book];
  }
  
  [[WSYDDatabase newInstance] closeDb];
  return books;
}

+ (BOOL)updateBookStatus:(NSString *)status downnum:(NSString *)downnum{
  
  FMDatabase *db =[WSYDDatabase newInstance].fmdatabse;
  
  BOOL result =NO;
  
  if ([db beginTransaction]) {
    
    result =[db executeUpdate:@"update t_book set status=? where downnum=?",status,downnum];
    
    [db commit];
  }
  
  [[WSYDDatabase newInstance] closeDb];
  
  return result;
}

+ (BOOL)updateOpenStatus:(NSString *)status downnum:(NSString *)downnum{
  
  FMDatabase *db =[WSYDDatabase newInstance].fmdatabse;
  
  BOOL result =NO;
  
  if ([db beginTransaction]) {
    
    result =[db executeUpdate:@"update t_book set openstatus=? where downnum=?",status,downnum];
    
    [db commit];
  }
  
  [[WSYDDatabase newInstance] closeDb];
  
  return result;
}

//-------------------------推送信息表操作-------------------------------------------------------------

+ (BOOL)insertPushMsg:(PushMsg *)pushMsg{
  
  FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
  [db beginTransaction];
  
  BOOL result =[db executeUpdate:@"insert into t_push_msg (downnum,msg) values(?,?)",pushMsg.downnum,pushMsg.msg];
  
  [db commit];
  
  [[WSYDDatabase newInstance] closeDb];
  
  return result;
}

+ (BOOL)deletePushMsgByDownnum:(NSString *)downnum{
  
  FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
  
  BOOL result =NO;
  
  if([db beginTransaction]){
    
    result =[db executeUpdate:@"delete from t_push_msg where downnum=?",downnum];
    
    [db commit];
  }
  [[WSYDDatabase newInstance] closeDb];
  
  return result;
}

+ (NSMutableArray *)queryPushMsgByDownnum:(NSString *)downnum{
  
  FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
  
  FMResultSet *res =[db executeQuery:@"select * from t_push_msg where downnum =?",downnum];
  
  NSMutableArray *pushMsgs = [[NSMutableArray alloc] init];
  while ([res next]) {
    
    PushMsg *pm =[[PushMsg alloc] init];
    
    [pm setID:[res intForColumn:@"id"]];
    [pm setDownnum:[res stringForColumn:@"downnum"]];
    [pm setMsg:[res stringForColumn:@"msg"]];
    
    [pushMsgs addObject:pm];
  }
  
  [[WSYDDatabase newInstance] closeDb];
  return pushMsgs;
}

+ (NSUInteger)queryCountOfPushMsgByDownnum:(NSString *)downnum{
  
  FMDatabase *db = [WSYDDatabase newInstance].fmdatabse;
  
  FMResultSet *res =[db executeQuery:@"select count(ID) from t_push_msg where downnum =?",downnum];
  
  NSUInteger count =0;
  
  while ([res next]) {
    
    count =[res intForColumnIndex:0];
  }
  
  [[WSYDDatabase newInstance] closeDb];
  
  return count;
}

@end
