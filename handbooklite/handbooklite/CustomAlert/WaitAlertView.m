//
//  WaitAlertView.m
//  handbooklite
//
//  Created by bao_wsfk on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WaitAlertView.h"

@implementation WaitAlertView

- (id)init{
  self = [super init];
//    if (self == [super init])
//    {
        isShowIng =NO;
//    }
    return self;
}

- (void)layoutSubviews{
    
    //屏蔽系统的Imageview 和 Button
    for (UIView *v in [self subviews]) {
        
        if ([v class] == [UIImageView class]) {
            [v setHidden:YES];
        }
        
        if ([v isKindOfClass:[UIButton class]] || [v isKindOfClass:NSClassFromString(@"UIThreePartButton")]) {
            [v setHidden:YES];
        }
        
    }
    
    if (isShowIng) {
        return;
    }
    
    //添加等待的小圆圈
    UIActivityIndicatorView *progressInd = [[UIActivityIndicatorView alloc]
                   initWithFrame:CGRectMake(self.frame.size.width/2 , self.frame.size.height/2, 32.0, 32.0)];
    
    [progressInd startAnimating];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self addSubview:progressInd];
    
    isShowIng = YES;
}

- (void)show{
    [super show];
}

- (void)dismiss{
    isShowIng =NO;
    [self dismissWithClickedButtonIndex:0 animated:YES];
}



@end
