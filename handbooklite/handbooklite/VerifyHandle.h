//
//  VerifyHandle.h
//  handbooklite
//
//  Created by bao_wsfk on 13-3-15.
//
//  这里是验证下载码有效性的触发机制
//  使用- (void)startVerify方法可以触发该机制
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "Book.h"

#define VERIFY_TYPE_SIMPLE @"verify_type_simple"
#define VERIFY_TYPE_MORE   @"verify_type_more"

@class VerifyHandle;

@protocol VerifyHandleDelegate <NSObject>

@required
- (NSMutableArray *)verifyDataSource:(VerifyHandle *)verifyHandle downnum:(NSString *)downnum verifyType:(NSString *)verifyType;

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

- (void)startVerifyWithDownnum:(NSString *)downum verifyType:(NSString *)type;//启动机制

@end
