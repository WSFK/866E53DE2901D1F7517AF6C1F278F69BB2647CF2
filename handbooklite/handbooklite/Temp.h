//
//  Temp.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-12.
//
//

#import <Foundation/Foundation.h>

@interface Temp : NSObject{
    
    NSInteger ID;
    NSString *name;
    NSString *downnum;
    NSDate *savedate;
}
@property (nonatomic, assign)NSInteger ID;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *downnum;
@property (nonatomic, copy)NSDate *savedate;

- (NSString *)stringSaveDate;
@end
