//
//  MyHttpRequest.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-12.
//
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@protocol MyHttpRequestDelegate <NSObject>

- (void)didRequestFailedWidthError:(NSString *)error;

- (void)didRequestFinishedWidthResponseData:(NSDictionary *)responseData;

@end

@interface MyHttpRequest : NSObject<ASIHTTPRequestDelegate>{
    
    id<MyHttpRequestDelegate> __weak delegate;
}
@property (nonatomic, weak)id<MyHttpRequestDelegate> delegate;

- (void)sendPostValue:(NSString *)value key:(NSString *)key forUrl:(NSString *)url;

@end
