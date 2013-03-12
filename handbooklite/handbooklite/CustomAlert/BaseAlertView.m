//
//  BaseAlertView.m
//  handbooklite
//
//  Created by bao_wsfk on 12-11-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseAlertView.h"

@implementation BaseAlertView

@synthesize backgroundImage,isShowIng,isKeyboardShow;


- (id)initWithBackgroundImage:(UIImage *)image{
  self =[super init];
//    if (self ==[super init]) {
  
        self.backgroundImage =image;
        self.isShowIng =NO;
//    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGSize imageSize =self.backgroundImage.size;
    CCLog(@"--------------%.0f-------%.0f",imageSize.width,imageSize.height);
    [self.backgroundImage drawInRect:CGRectMake(0, 0, imageSize.width+10, imageSize.height)];
}

- (void)setFrame:(CGRect)frame{
    CGSize imageSize =self.backgroundImage.size;
    [super setFrame:CGRectMake(224.0, 225.0, imageSize.width+10, imageSize.height)];
}


- (void)layoutSubviews{
    
    //屏蔽系统的Imageview 和 Button
    for (UIView *v in [self subviews]) {
        
        if ([v class] == [UIImageView class]) {
            [v setHidden:YES];
        }
        NSLog(@"%d",v.tag);
        if ([v isKindOfClass:[UIButton class]] || [v isKindOfClass:NSClassFromString(@"UIThreePartButton")]) {
            if (v.tag==0) {
                [v setHidden:YES];
            }
        
        }
        
    }
    
    CGSize imageSize =self.backgroundImage.size;
    self.bounds = CGRectMake(0, 0, imageSize.width+10, imageSize.height);

}


- (void)show{
    
    isKeyboardShow =NO;
    //添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [super show];
    //    CGSize imageSize =self.backgroundImage.size;
    //    self.bounds = CGRectMake(0, 0, imageSize.width+10, imageSize.height);
}

//键盘弹出
- (void)keyboardWasShown:(NSNotification *)notification{
    
    NSDictionary *info =[notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (!isKeyboardShow) {
        self.center =CGPointMake(self.center.x, self.center.y - kbSize.width/2);
    }
    isKeyboardShow =YES;
}

//键盘消失
- (void)keyboardWillBeHidden:(NSNotification *)notification{
    
    isKeyboardShow =NO;
    //这里不需要再 + kbSize.width/2
    //self.center =CGPointMake(self.center.x, self.center.y + kbSize.width/2);
}

- (void)dismiss{
    
    //清除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    isShowIng =NO;
    [self dismissWithClickedButtonIndex:0 animated:YES];
}


@end
