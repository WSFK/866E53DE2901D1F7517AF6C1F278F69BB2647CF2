//
//  ShareAlertView.m
//  handbook
//
//  Created by bao_wsfk on 12-10-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareAlertView.h"
#import "SinaweiboShare.h"

@implementation ShareAlertView

@synthesize backgroundImage;
@synthesize myTarget =_myTarget;
@synthesize sendImage =_sendImage;

- (id)initWithTarget:(UIViewController *)target sendImage:(UIImage *)image{
    
    if (self =[super init]) {
        self.backgroundImage =[UIImage imageNamed:@"alert.png"];
        
        [self setMyTarget:target];
        [self setSendImage:image];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGSize imageSize =self.backgroundImage.size;
    [self.backgroundImage drawInRect:CGRectMake(0, 0, imageSize.width+10, imageSize.height)];
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
    
    double aw =self.frame.size.width;
    
    //新浪微博分享按钮
    UIButton *sinaweiboBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *bg =[UIImage imageNamed:@"btn_green.png"];
    
    int x =(aw - bg.size.width)/2;
    
    [sinaweiboBtn setBackgroundImage:bg forState:UIControlStateNormal];
    [sinaweiboBtn setFrame:CGRectMake(x,
                                   100,
                                   bg.size.width, 
                                   bg.size.height)];
    [sinaweiboBtn setTitle:@"新浪微博" forState:UIControlStateNormal];
    [sinaweiboBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[sinaweiboBtn titleLabel] setFont:[UIFont fontWithName:@"Microsoft YaHei" size:16]];
    [sinaweiboBtn addTarget:self
                  action:@selector(sendSinaweiboShare) 
        forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:sinaweiboBtn];
    
    
    //邮件分享按钮
    UIButton *emailShareBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *bg2 =[UIImage imageNamed:@"btn_blue.png"];
    
    [emailShareBtn setBackgroundImage:bg forState:UIControlStateNormal];
    [emailShareBtn setFrame:CGRectMake(x, 150, bg2.size.width, bg2.size.height)];
    
    [emailShareBtn setTitle:@"Email" forState:UIControlStateNormal];
    [emailShareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[emailShareBtn titleLabel] setFont:[UIFont fontWithName:@"Microsoft YaHei" size:16]];
    [emailShareBtn addTarget:self
                     action:@selector(sendEmailShare) 
           forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:emailShareBtn];
    
    UIImage *close =[UIImage imageNamed:@"close.png"];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setBackgroundImage:close forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(self.frame.size.width-95,15, close.size.width+10, close.size.height+10)];
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
}

- (void)show{
    
    [super show];
    CGSize imageSize =self.backgroundImage.size;
    self.bounds = CGRectMake(0, 0, imageSize.width+10, imageSize.height);
}



//发送新浪微博分享
- (void)sendSinaweiboShare{
    
    [[SinaweiboShare sharedInstance] postMessage:@"四维册应用分享" withPic:_sendImage];
//    [self dismiss];
}

//发送邮件分享
- (void)sendEmailShare{
    [self sendMail];
    [self dismiss];
}

- (void)sendMail{
    
    Class mailClass =NSClassFromString(@"MFMailComposeViewController");
    
    if (mailClass !=nil) {
        if ([MFMailComposeViewController canSendMail]) {
            //可以发送邮件
            [self displayComposerSheet];
        }else {
            //不能发送
            [self notOpenMail];
        }
    }else {
        //不能发送
        [self notOpenMail];
    }
    
}

- (void)displayComposerSheet{
    MFMailComposeViewController *mailPicker =[[MFMailComposeViewController alloc] init];
    
    [mailPicker setMailComposeDelegate:self];
    
    //设置主题
    [mailPicker setSubject:@"四维册应用分享"];
    
    NSData *imgData =UIImagePNGRepresentation(_sendImage);
    [mailPicker addAttachmentData:imgData mimeType:@"image/png" fileName:@"image.png"];
    
    NSString *body =@"点击连接下载客户端:http://www.wsfk.cn";
    
    [mailPicker setMessageBody:body isHTML:YES];
    [_myTarget presentModalViewController:mailPicker animated:YES];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [_myTarget dismissModalViewControllerAnimated:YES];
    NSString *msg =[NSString string];
    
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            [self sendMailCancelled];
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            [self sendMailSaveFinished];
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            [self sendMailFinished];
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            [self sendMailFailed];
            break;
        default:
            break;
    }
    NSLog(@"sendMail---log:%@",msg);
}

- (void)sendMailCancelled{
    if ([_mailDelegate respondsToSelector:@selector(didSendMailCancelled)]) {
        [_mailDelegate performSelector:@selector(didSendMailCancelled)];
    }
}

- (void)sendMailSaveFinished{
    if ([_mailDelegate respondsToSelector:@selector(didSaveMailFinished)]) {
        [_mailDelegate performSelector:@selector(didSaveMailFinished)];
    }
}

- (void)sendMailFinished{
    if ([_mailDelegate respondsToSelector:@selector(didSendMailFinished)]) {
        [_mailDelegate performSelector:@selector(didSendMailFinished)];
    }
}

- (void)sendMailFailed{
    if ([_mailDelegate respondsToSelector:@selector(didSendMailFailure)]) {
        [_mailDelegate performSelector:@selector(didSendMailFailure)];
    }
}

- (void)notOpenMail{
    if ([_mailDelegate respondsToSelector:@selector(notOpenMail)]) {
        [_mailDelegate performSelector:@selector(notOpenMail)];
    }
}


- (void)dismiss{
    [self dismissWithClickedButtonIndex:0 animated:YES];
}

@end
