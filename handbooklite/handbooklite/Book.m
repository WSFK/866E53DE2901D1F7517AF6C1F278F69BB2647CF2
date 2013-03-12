//
//  Book.m
//  handbooklite
//
//  Created by bao_wsfk on 12-12-10.
//
//

#import "Book.h"

@implementation Book

@synthesize ID,name,downnum,dir,zip,icon,bookId,status,su,st,hash;


- (NSString *)getIconName{
    
    return icon?[icon lastPathComponent]:@"";
}

@end
