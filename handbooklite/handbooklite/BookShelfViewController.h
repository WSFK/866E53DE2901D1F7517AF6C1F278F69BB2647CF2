//
//  BookShelfViewController.h
//  handbooklite
//
//  Created by bao_wsfk on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController_Extension.h"
#import "Config.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "InterceptorWindow.h"
#import "MMGridView.h"
#import "ZXingWidgetController.h"
#import "DownloadAlertView.h"
#import "ContactUsViewController.h"
#import "CostomAlertView.h"
#import "Book.h"
#import "VerifyHandle.h"
#import "TwoCapture.h"

@interface BookShelfViewController : UIViewController
<ASIHTTPRequestDelegate,
MMGridViewDelegate,
MMGridViewDataSource,
DownloadAlertViewDelegate,
CostomAlertViewDelegate,
UIAlertViewDelegate,VerifyHandleDelegate>

{
    
    NSString *_books_path;
    
    
    
    
    
    NSMutableArray *_books;
    NSMutableDictionary *cellStatusDic;
    IBOutlet MMGridView *_gridView;
    
    
    
    
    
    
    
    
    IBOutlet UILabel *_lbTitle;
    IBOutlet UILabel *_lbPhoto;
    IBOutlet UILabel *_lbLxwm;
    IBOutlet UILabel *_lbEdit;
    
    IBOutlet UIImageView *leftMenuImgView;
    
    
    InterceptorWindow *_myWindow;
    NSString *_cacheBookPath;
    NSString *_bundleBookPath;
    NSString *_defaultScreeshotsPath;
    
    DownloadAlertView *_downloadAlertView;
    
    ContactUsViewController *_contactUsView;
    
    CostomAlertView *promptAlert;
    
    NSMutableDictionary *_downloadTempDic;;

    
    VerifyHandle *verifyHandle;
    
    BOOL isVerify;
    
    
}
@property (nonatomic ,copy) NSString *books_path;



@property (nonatomic, strong) NSMutableArray *books;
@property (nonatomic, strong) NSMutableDictionary *cellStatusDic;
@property (nonatomic, strong) MMGridView *gridView;





@property (nonatomic, strong) UILabel *lbTitle;
@property (nonatomic, strong) UILabel *lbPhoto;
@property (nonatomic, strong) UILabel *lbLxwm;
@property (nonatomic, strong) UILabel *lbEdit;

@property (nonatomic, strong) UIImageView *leftMenuImgView;

@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) InterceptorWindow *myWindow;
@property (nonatomic, strong) NSString *cacheBookPath;
@property (nonatomic, strong) NSString *bundleBookPath;
@property (nonatomic, strong) NSString *defaultScreeshotsPath;

@property (nonatomic, strong) DownloadAlertView *downloadAlertView;

@property (nonatomic, strong) ContactUsViewController *contactUsView;

@property (nonatomic, strong) NSMutableDictionary *downloadTempDic;

@property (nonatomic, strong) VerifyHandle *verifyHandle;



- (IBAction)scanClickSelector:(id)sender;

- (IBAction)toContactUsViewSelector:(id)sender;

- (IBAction)clickEditSelector:(id)sender;

//重构二维码
- (NSString *)saxReader:(NSString *)str isPushVerify:(BOOL)isPushVerify;

//通过URL打开手册
- (void)openBookByURL:(NSString *)urlString;


@end
