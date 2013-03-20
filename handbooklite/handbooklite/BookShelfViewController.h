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


@interface BookShelfViewController : UIViewController
<ASIHTTPRequestDelegate,
ZXingDelegate,
MMGridViewDelegate,
MMGridViewDataSource,
DownloadAlertViewDelegate,
CostomAlertViewDelegate,
UIAlertViewDelegate,VerifyHandleDelegate>

{
    
    ASINetworkQueue *_networkQueue;
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
    
    NSDictionary *_paramBookDic;
    
    NSDictionary *paramPushData;//推送过来的数据  全局变量
    
    VerifyHandle *verifyHandle;
    
    BOOL isVerify;
    
    
}
@property (nonatomic ,strong) ASINetworkQueue *networkQueue;
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

@property (nonatomic, strong) NSDictionary *paramBookDic;

@property (nonatomic, strong) VerifyHandle *verifyHandle;



- (IBAction)scanClickSelector:(id)sender;

- (IBAction)toContactUsViewSelector:(id)sender;

- (IBAction)clickEditSelector:(id)sender;

<<<<<<< HEAD
//下载列表
- (IBAction)clickDownloadListSelector:(id)sender;
=======
>>>>>>> 提交最新代码2013-03-20

//重构二维码
- (NSString *)saxReader:(NSString *)str;

//通过URL打开手册
- (void)openBookByURL:(NSString *)urlString;


@end
