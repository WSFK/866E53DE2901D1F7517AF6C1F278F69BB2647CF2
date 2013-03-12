//
//  TowCodeAlertView.m
//  Test
//
//  Created by bao_wsfk on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TowCodeAlertView.h"

@implementation TowCodeAlertView

@synthesize contentImage;

- (id)initWithContentImage:(UIImage *)image{
    
    if (self ==[super initWithBackgroundImage:[UIImage imageNamed:@"alert.png"]]) {
        self.contentImage =image;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    //二维码
//    if (contentImage) {
//        
//        CGSize contentSize =self.contentImage.size;
//        [self.contentImage drawInRect:CGRectMake(self.frame.size.width/3-20, self.frame.size.height/4-20, contentSize.width+30, contentSize.height+30)];
//    }
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if (isShowIng) {
        return;
    }
    
    //关闭按钮
    UIButton *btnClose =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setTag:11];
    UIImage *bg =[UIImage imageNamed:@"close.png"];
    [btnClose setBackgroundImage:bg forState:UIControlStateNormal];
    [btnClose setFrame:CGRectMake(self.frame.size.width-95,
                                   15,
                                   bg.size.width +10, 
                                   bg.size.height +10)];
    [btnClose addTarget:self
                  action:@selector(dismiss)
        forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnClose];
    
    if (contentImage) {
        CGSize contentSize =self.contentImage.size;
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/3-30, 
                                                                        self.frame.size.height/4-30, 
                                                                        contentSize.width+50, 
                                                                        contentSize.height+50)]
                           ;
        [bg setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:bg];
        
        UIImageView *twoCode =[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/3-20,
                                                                           self.frame.size.height/4-20,
                                                                           contentSize.width+30,
                                                                           contentSize.height+30)]
                               ;
        [twoCode setImage:contentImage];
        [self addSubview:twoCode];
        
    }
    
    isShowIng = YES;
    
}


- (void)dismiss{
    if ([delegate respondsToSelector:@selector(closeTowCodeAlert)]) {
        [delegate performSelector:@selector(closeTowCodeAlert)];
    }
    [super dismiss];
}

@end
