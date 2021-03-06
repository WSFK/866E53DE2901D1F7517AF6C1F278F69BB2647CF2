//
//  _mailDelegate.m
//  Test
//
//  Created by bao_wsfk on 12-9-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareActionSheet.h"
#import "SinaweiboShare.h"
#import "iToast.h"
#import "WeiXinShare.h"

@implementation ShareActionSheet

//@synthesize mailDelegate;

+ (ShareActionSheet *)actionSheetForTarget:(UIViewController *)target
                                 sendImage:(UIImage *)image
                                   sendPdf:(NSString*) pdfFilePath
                               sendPdfName:(NSString*) pdfFileName
                              bookShareUrl:(NSString *)bookShareUrl
                                  indexPic:(UIImage *)indexPic
                                  bookName:(NSString *)name{
    
    ShareActionSheet *as = [[ShareActionSheet alloc] initWithTitle:@"分享"
                                                          delegate:(id)self
                                                 cancelButtonTitle:nil
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:nil];
    [as setMyTarget:target];
    [as setSendImage:image];
    [as setIndexImage:indexPic];
    [as setPdfPath:pdfFilePath];
    [as setPdfName:pdfFileName];
    [as setBookName:name];
    [as addButtonWithTitle:@"新浪微博"];
    [as addButtonWithTitle:@"微 信"];
    [as addButtonWithTitle:@"Email"];
    [as setBookShareUrl:bookShareUrl];
	return as;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    
    switch (buttonIndex) {
        case 0:
            [self shareSinaWeibo];
            break;
        case 1:
            [self shareWeiXin];
            break;
        case 2:
            [self sendMail];
            break;
        default:
            break;
    }
    
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

//微信分享
- (void)shareWeiXin{
    UIImage *img =_indexImage?_indexImage:_sendImage;
    [WeiXinShare sendShareWithImage:img
                        description:[NSString stringWithFormat:@"《%@》 精彩内容",_bookName]
                                url:_bookShareUrl];
}

//新浪微博分享
- (void)shareSinaWeibo{
    
    /**判断二维码是否存在
     if (_sendImage == nil) {
     
     iToast *toast =[iToast makeToast:@"网络连接异常，请稍后再试"];
     [toast setToastPosition:kToastPositionBottom];
     [toast setToastDuration:kToastDurationNormal];
     [toast show];
     return;
     }
     */
  NSMutableString *weiboContent = [[NSMutableString alloc] initWithString:_pdfName];
  [weiboContent appendFormat:@"(四维册分享：%@)",HANDBOOKLITEAPPSTORE];
  [weiboContent appendString:@"使用四维册拍取二维码，下载手册"];
  
    [[SinaweiboShare sharedInstance] postMessage:weiboContent withPic:_sendImage];
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

    mailPicker =[[MFMailComposeViewController alloc] init];
    
    [mailPicker setMailComposeDelegate:self];
    
    //设置主题
    [mailPicker setSubject:[NSString stringWithFormat:@"%@(四维册分享)",_pdfName]];
    
    NSData *imgData =UIImagePNGRepresentation(_sendImage);
    [mailPicker addAttachmentData:imgData mimeType:@"image/png" fileName:@"image.png"];
    
    NSMutableString *mailContent = [[NSMutableString alloc] initWithFormat:@"《%@》<br/>",_pdfName];
    [mailContent appendFormat:@"扫描以下二维码，下载<a href='%@'>《%@》</a><br>",_bookShareUrl,_pdfName];
    //  [mail_bookShareUrllndFormat:@"点击下载<a href='%@'>四维册阅读客户端</a><br>",HANDBOOKLITEAPPSTORE];
    //  [mailContent appendFormat:@"点击查看<a href='%@'>pdf版</a><br>",_pdfPath];
    [mailContent appendFormat:@"<a href='%@'>查看更多帮助内容</a><br>",WEBHELP];
    [mailContent appendString:@"感谢您使用四维册。"];
    
    [mailPicker setMessageBody:mailContent isHTML:YES];
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
    if ([_mailDelegate respondsToSelector:@selector(didSendMailCancelled:)]) {
        [_mailDelegate performSelector:@selector(didSendMailCancelled:) withObject:self];
    }
}

- (void)sendMailSaveFinished{
    if ([_mailDelegate respondsToSelector:@selector(didSaveMailFinished:)]) {
        [_mailDelegate performSelector:@selector(didSaveMailFinished:) withObject:self];
    }
}

- (void)sendMailFinished{
    if ([_mailDelegate respondsToSelector:@selector(didSendMailFinished:)]) {
        [_mailDelegate performSelector:@selector(didSendMailFinished:) withObject:self];
    }
}

- (void)sendMailFailed{
    if ([_mailDelegate respondsToSelector:@selector(didSendMailFailure:)]) {
        [_mailDelegate performSelector:@selector(didSendMailFailure:) withObject:self];
    }
}

- (void)notOpenMail{
    if ([_mailDelegate respondsToSelector:@selector(notOpenMail:)]) {
        [_mailDelegate performSelector:@selector(notOpenMail:) withObject:self];
    }
}

@end
