//
//  MyHttpRequest.m
//  handbooklite
//
//  Created by bao_wsfk on 12-12-12.
//
//

#import "MyHttpRequest.h"
#import "JSONKit.h"
#import "TokenUtil.h"

@implementation MyHttpRequest

@synthesize delegate;


- (void)sendPostValue:(NSString *)value key:(NSString *)key forUrl:(NSString *)url{
    
    //请求数据
    ASIFormDataRequest *request =[ASIFormDataRequest
                                  requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    //不再重用上一个url
    [request setShouldAttemptPersistentConnection:NO];
    [request setTimeOutSeconds:10];
    [request setPostValue:value forKey:key];
    [request setPostValue:[TokenUtil getLocalToken] forKey:@"token"];
    [request startAsynchronous];
}


- (void)requestFailed:(ASIHTTPRequest *)request{
    
    if ([delegate respondsToSelector:@selector(didRequestFailedWidthError:)]) {
        [delegate performSelector:@selector(didRequestFailedWidthError:) withObject:@"网络故障，请稍后再试！"];
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    
    if ([request responseStatusCode] ==200) {
        NSDictionary *data = [(NSDictionary *)[[request responseData] objectFromJSONData]
                              objectForKey:@"handbookMsg"];
        
        if ([@"success" isEqualToString:[data objectForKey:@"status"]]) {
            
            if ([delegate respondsToSelector:@selector(didRequestFinishedWidthResponseData:)]) {
                [delegate performSelector:@selector(didRequestFinishedWidthResponseData:) withObject:(NSDictionary *)[[request responseData] objectFromJSONData]];
            }
        }
        else {
            
            if ([delegate respondsToSelector:@selector(didRequestFailedWidthError:)]) {
                [delegate performSelector:@selector(didRequestFailedWidthError:) withObject:[data objectForKey:@"error"]];
            }
        }
        
    }else {

        if ([delegate respondsToSelector:@selector(didRequestFailedWidthError:)]) {
            [delegate performSelector:@selector(didRequestFailedWidthError:) withObject:[NSString stringWithFormat:@"请求错误码:%i",[request responseStatusCode]]];
        }
    }
    
}

@end
