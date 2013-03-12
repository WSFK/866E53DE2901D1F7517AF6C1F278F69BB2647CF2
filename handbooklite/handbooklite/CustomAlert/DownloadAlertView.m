//
//  DownloadAlertView.m
//  handbooklite
//
//  Created by bao_wsfk on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DownloadAlertView.h"

@implementation DownloadAlertView

@synthesize delegate,tf_text;


- (id)initWithImage:(UIImage *)image{
    
    return [super initWithBackgroundImage:image];
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if (isShowIng) {
        return;
    }
    
    //添加拍照按钮
    UIImage *img_photo =[UIImage imageNamed:@"photo.png"];
    
    UIButton *btn_photo =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn_photo setTag:1001];
    [btn_photo setFrame:CGRectMake(53,
                                   85,
                                   img_photo.size.width,
                                   img_photo.size.height)];
    
    [btn_photo setBackgroundImage:img_photo forState:UIControlStateNormal];
    [btn_photo addTarget:self action:@selector(goPhotoView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn_photo];
    
    //添加提交按钮
    UIImage *img_commit =[UIImage imageNamed:@"btn_green.png"];
    
    UIButton *btn_commit =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn_commit setTag:1002];
    [btn_commit setFrame:CGRectMake(200,
                                    150,
                                    img_commit.size.width, 
                                    img_commit.size.height)];
    
    [btn_commit setBackgroundImage:img_commit forState:UIControlStateNormal];
    [btn_commit addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    [btn_commit setTitle:@"确  定" forState:UIControlStateNormal];
    [[btn_commit titleLabel] setFont:[UIFont fontWithName:@"Microsoft YaHei" size:16]];
    [self addSubview:btn_commit];
    
    //添加label
    UILabel *lb_mark1 =[[UILabel alloc] initWithFrame:
                       CGRectMake(200 , 65, 80, 20)];
    [lb_mark1 setTag:1003];
    [lb_mark1 setTextAlignment:UITextAlignmentLeft];
    [lb_mark1 setText:@"输入下载码"];
    [lb_mark1 setBackgroundColor:[UIColor clearColor]];
    [lb_mark1 setTextColor:[UIColor whiteColor]];
    [lb_mark1 setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [self addSubview:lb_mark1];
    
    UILabel *lb_mark2 =[[UILabel alloc] initWithFrame:
                        CGRectMake(79, 163, 80, 20)];
    [lb_mark2 setTag:1004];
    [lb_mark2 setTextAlignment:UITextAlignmentLeft];
    [lb_mark2 setText:@"拍照"];
    [lb_mark2 setBackgroundColor:[UIColor clearColor]];
    [lb_mark2 setTextColor:[UIColor whiteColor]];
    [lb_mark2 setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [self addSubview:lb_mark2];
    
    //添加文本框
    UIImage *bg =[UIImage imageNamed:@"input.png"];
    UIImageView *imageView =[[UIImageView alloc] initWithImage:bg];
    [imageView setTag:1005];
    [imageView setFrame:CGRectMake(200, 
                                   94, 
                                   bg.size.width,
                                   bg.size.height)];
    [self addSubview:imageView];
    
    tf_text =[[UITextField alloc]
                            initWithFrame:CGRectMake(205,
                                                     94,
                                                     bg.size.width-5, 
                                                     bg.size.height)];
    [tf_text setTag:1006];
    [tf_text setBorderStyle:UITextBorderStyleNone];
    [tf_text setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [tf_text setFont:[UIFont fontWithName:@"Microsoft YaHei" size:18]];
    //[tf_text setBackground:bg];
    //[tf_text setBackgroundColor:[UIColor colorWithPatternImage:bg]];
    [self addSubview:tf_text];
    
    UIImage *close =[UIImage imageNamed:@"close.png"];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTag:1007];
    [cancelBtn setBackgroundImage:close forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(self.frame.size.width-95,15, close.size.width+10, close.size.height+10)];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    UIImageView *line =[[UIImageView alloc] initWithFrame:CGRectMake(172, 26, 1, 252)];
    [line setTag:1008];
    [line setBackgroundColor:[UIColor lightGrayColor]];
    [line setAlpha:0.3];
    [self addSubview:line];
    
    isShowIng =YES;
}

- (void)dismiss{
    [tf_text resignFirstResponder];
    [super dismiss];
}

- (void)cancel{
    [self dismiss];
}

- (void)goPhotoView{
    
    [self dismiss];
    if ([delegate respondsToSelector:@selector(goPhotoView)]) {
        [delegate performSelector:@selector(goPhotoView)];
    }
}

- (void)commit{
    
    [tf_text resignFirstResponder];
    [self dismiss];
    if ([delegate respondsToSelector:@selector(commitWithText:)]) {
        [delegate performSelector:@selector(commitWithText:) withObject:[tf_text text]];
    }
}

@end
