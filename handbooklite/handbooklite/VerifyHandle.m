//
//  VerifyHandle.m
//  handbooklite
//
//  Created by bao_wsfk on 13-3-15.
//
//

#import "VerifyHandle.h"
#import "Config.h"
#import "TokenUtil.h"
#import "PublicImport.h"

@implementation VerifyHandle

@synthesize delegate,isAction;

@synthesize requestForm;


- (void)startVerify{
    
    NSMutableArray *books =nil;
    
    if ([delegate respondsToSelector:@selector(verifyDataSource:)]) {
        
        books =[delegate verifyDataSource:self];
    }
    
    if ([books count] >0) {
        //去验证
        [self send:books];
    }
    
}


- (void)send:(NSMutableArray *)books{
    
    isAction =YES;
    
    if (!self.requestForm) {
        self.requestForm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:VERIFY_URL]];
    }
    
    
    NSString *param =[self getParam:books];
    
    [self.requestForm setDelegate:self];
    [self.requestForm setShouldAttemptPersistentConnection:NO];
    [self.requestForm setTimeOutSeconds:10];
    [self.requestForm setPostValue:param forKey:@"verifyString"];
    
    [self.requestForm startAsynchronous];
    
}


/**
 
 {
 "verifyParam": [
                    {
                        "downnum": "123",
                        "token": "122232",
                        "uid": "121",
                        "st": "201202023",
                        "su": "23232",
                        "hash": "5"
                    }
                ]
 }
 
 */

- (NSString *)getParam:(NSMutableArray *)books{
    
    NSMutableString *param =[[NSMutableString alloc] init];
    
    [param appendString:@"{\"verifyParam\":["];
    for (Book *book in books) {
        
        [param appendString:@"{"];
        [param appendFormat:@"\"downnum\":\"%@\",",[book downnum]];
        [param appendFormat:@"\"token\":\"%@\",",[TokenUtil getLocalToken]];
        [param appendFormat:@"\"uid\":\"%@\",",USERUUID];
        [param appendFormat:@"\"st\":\"%@\",",[book st]];
        [param appendFormat:@"\"su\":\"%@\",",[book su]];
        [param appendFormat:@"\"hash\":\"%@\"",[book hash]];
        [param appendString:@"}"];
        [param appendString:@","];
    }
    
    [param appendString:@"]}"];
    
    
    NSUInteger index =[param rangeOfString:@"," options:NSBackwardsSearch].location;
    
    NSString *str1 =[param substringToIndex:index];
    NSString *str2 =[param substringFromIndex:index+1];
    
    return [NSString stringWithFormat:@"%@%@",str1,str2];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    
    if (request.responseStatusCode ==200) {
        
        if ([delegate respondsToSelector:@selector(verifyFinished:request:)]) {
            
            [delegate verifyFinished:self request:request];
        }
    }
    
    self.requestForm =nil;
    
    isAction =NO;
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    
    if ([delegate respondsToSelector:@selector(verifyFailed:request:)]) {
        
        [delegate verifyFailed:self request:request];
        
    }
    
    self.requestForm =nil;
    
    isAction =NO;
}

@end
