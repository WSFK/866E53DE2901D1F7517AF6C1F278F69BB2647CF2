//
//  CostomAlertView.h
//  handbooklite
//
//  Created by bao_wsfk on 12-10-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAlertView.h"

@protocol CostomAlertViewDelegate <NSObject>

@required
- (void)didComfirm;
@required
- (void)didCancel;

@end

@interface CostomAlertView : BaseAlertView{
    
    NSString *_message;
    
    id<CostomAlertViewDelegate> __weak delegate;
}
@property (nonatomic, copy) NSString *message;
@property (nonatomic, weak) id<CostomAlertViewDelegate> delegate;

- (id)initWithMessage:(NSString *)message;
@end
