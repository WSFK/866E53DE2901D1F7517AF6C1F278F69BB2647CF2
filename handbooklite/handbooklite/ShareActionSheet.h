//
//  ShareActionSheet.h
//  Test
//
//  Created by bao_wsfk on 12-9-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PublicImport.h"
#import "SendMailDelegate.h"

@interface ShareActionSheet : UIActionSheet<MFMailComposeViewControllerDelegate,UIActionSheetDelegate>{
  MFMailComposeViewController *mailPicker;
}
@property (nonatomic, retain) UIViewController *myTarget;
@property (nonatomic, retain) UIImage *sendImage;
@property (nonatomic, retain) UIImage *indexImage;
@property (nonatomic, retain) NSString *pdfPath;
@property (nonatomic, retain) NSString *pdfName;
@property (nonatomic, retain) NSString *bookShareUrl;
@property (nonatomic, copy)   NSString *bookName;

@property (nonatomic, assign) id<SendMailDelegate> mailDelegate;

+ (ShareActionSheet *)actionSheetForTarget:(UIViewController *)target
                                 sendImage:(UIImage *)image
                                   sendPdf:(NSString*) pdfFilePath
                               sendPdfName:(NSString*) pdfFileName
                              bookShareUrl:(NSString *)bookShareUrl
                                  indexPic:(UIImage *)indexPic
                                  bookName:(NSString *)name;

@end
