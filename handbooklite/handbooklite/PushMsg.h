//
//  PushMsg.h
//  handbooklite
//
//  Created by bao_wsfk on 13-3-20.
//
//

#import <Foundation/Foundation.h>

@interface PushMsg : NSObject{
    
    NSInteger ID;
    NSString *downnum;
    NSString *msg;
}
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy)   NSString *downnum;
@property (nonatomic, copy)   NSString *msg;

@end
