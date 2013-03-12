//
//  ProgressAlertView.h
//  Test
//
//  Created by bao_wsfk on 12-10-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAlertView.h"

@interface ProgressAlertView : BaseAlertView{
    
    UIProgressView *progressView;
}
@property (readwrite, strong) UIProgressView *progressView;

- (id)init;

- (UIProgressView *)showPrg;

@end
