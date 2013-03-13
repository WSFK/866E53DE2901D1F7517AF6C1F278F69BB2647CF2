//
//  ShareAlertView.h
//  handbook
//
//  Created by bao_wsfk on 12-10-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@protocol SendMailDelegate <NSObject>

- (void)didSendMailFinished;
- (void)didSendMailFailure;
- (void)didSendMailCancelled;
- (void)didSaveMailFinished;
- (void)notOpenMail;

@end

@interface ShareAlertView : UIAlertView<MFMailComposeViewControllerDelegate,UIActionSheetDelegate>{
    
    UIImage *backgroundImage;
    
    UIViewController *_myTarget;
    UIImage *_sendImage;
}
@property (readwrite, retain) UIImage *backgroundImage;

@property (nonatomic, retain) UIViewController *myTarget;
@property (nonatomic, retain) UIImage *sendImage;
@property (nonatomic, assign) id<SendMailDelegate> mailDelegate;

- (id)initWithTarget:(UIViewController *)target sendImage:(UIImage *)image;
- (void)show;

@end
