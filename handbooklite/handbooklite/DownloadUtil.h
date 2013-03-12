//
//  DownloadUtil.h
//  handbooklite
//
//  Created by bao_wsfk on 12-10-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@protocol DownloadUtilDelegate <NSObject>

@required
- (void)didFinished;
- (void)didFailed;
- (void)didQueueFinished;

@end

@interface DownloadUtil : NSObject{
    
    ASINetworkQueue *_networkQueue;
    
    id<DownloadUtilDelegate> __weak delegate;
}
@property (nonatomic, strong) ASINetworkQueue *networkQueue;
@property (nonatomic, weak) id<DownloadUtilDelegate> delegate;

- (void)startDownloadBookDic:(NSDictionary *)bookDic progressView:(UIProgressView *)progressView;
@end
