//
//  CostomAlertView.m
//  handbooklite
//
//  Created by bao_wsfk on 12-10-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CostomAlertView.h"

@implementation CostomAlertView

@synthesize delegate;
@synthesize message =_message;

- (id)initWithMessage:(NSString *)message{
  self =[super initWithBackgroundImage:[UIImage imageNamed:@"alert.png"]];
//    if (self ==[super initWithBackgroundImage:[UIImage imageNamed:@"alert.png"]]) {
        self.message =message;
//    }
    return self;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if (isShowIng) {
        return;
    }
    
    UILabel *lbMsg =[[UILabel alloc] initWithFrame:CGRectMake(120, 80, 281, 35)];
    [lbMsg setText:_message];
    [lbMsg setFont:[UIFont fontWithName:@"Microsoft YaHei" size:16]];
    [lbMsg setTextColor:[UIColor whiteColor]];
    [lbMsg setTextAlignment:UITextAlignmentCenter];
    [lbMsg setBackgroundColor:[UIColor clearColor]];
    [self addSubview:lbMsg];
    
    UIImage *bg1 =[UIImage imageNamed:@"btn_green.png"];
    UIButton *btnConfirm =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnConfirm setTag:1];
    [btnConfirm setTitle:@"确  定" forState:UIControlStateNormal];
    [[btnConfirm titleLabel] setFont:[UIFont fontWithName:@"Microsoft YaHei" size:16]];
    [btnConfirm setFrame:CGRectMake(120, 155, bg1.size.width, bg1.size.height)];
    [btnConfirm setBackgroundImage:bg1 forState:UIControlStateNormal];
    [btnConfirm addTarget:self action:@selector(clickConfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnConfirm];

    
    
    
    UIImage *bg2 =[UIImage imageNamed:@"btn_blue.png"];
    UIButton *btnCancel =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTag:2];
    [btnCancel setTitle:@"取  消" forState:UIControlStateNormal];
    [[btnCancel titleLabel] setFont:[UIFont fontWithName:@"Microsoft YaHei" size:16]];
    [btnCancel setFrame:CGRectMake(120, 216, bg2.size.width, bg2.size.height)];
    [btnCancel setBackgroundImage:bg2 forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnCancel];
    
    isShowIng = YES;
    
}

- (void)clickConfirmBtn{
    [self dismiss];
    if ([delegate respondsToSelector:@selector(didComfirm)]) {
        [delegate performSelector:@selector(didComfirm)];
    }
}

- (void)clickCancelBtn{
    [self dismiss];
    if ([delegate respondsToSelector:@selector(didCancel)]) {
        [delegate performSelector:@selector(didCancel)];
    }
}

@end
