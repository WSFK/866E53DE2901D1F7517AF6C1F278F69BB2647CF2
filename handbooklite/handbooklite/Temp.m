//
//  Temp.m
//  handbooklite
//
//  Created by bao_wsfk on 12-12-12.
//
//

#import "Temp.h"

@implementation Temp

@synthesize ID,name,downnum,savedate;


- (NSString *)stringSaveDate{
    
    NSString *str =@"";
    
    if (savedate!=nil) {
        NSDateFormatter *df =[[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        str = [df stringFromDate:savedate];
    }
    return str;
}

@end
