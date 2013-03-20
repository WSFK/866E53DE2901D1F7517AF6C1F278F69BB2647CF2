//
//  VerifyHandle.h
//  handbooklite
//
//  Created by bao_wsfk on 13-3-15.
//
//  这里是验证下载码有效性的触发机制
//  这是一个循环机制
//  使用- (void)startVerify方法可以触发该机制
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "Book.h"

@class VerifyHandle;

@protocol VerifyHandleDelegate <NSObject>

@required
- (NSMutableArray *)verifyDataSource:(VerifyHandle *)verifyHandle;

- (void)verifyFinished:(VerifyHandle *)verifyHandle request:(ASIHTTPRequest *)request;

- (void)verifyFailed:(VerifyHandle *)verifyHandle request:(ASIHTTPRequest *)request;


@end

@interface VerifyHandle : NSObject<ASIHTTPRequestDelegate>{
    
    BOOL isAction;
    
    @private
    ASIFormDataRequest *requestForm;
}

@property (nonatomic, assign) id<VerifyHandleDelegate> delegate;
@property (nonatomic, strong) ASIFormDataRequest *requestForm;
@property (nonatomic, assign) BOOL isAction;

- (void)startVerify;//启动机制

@end
