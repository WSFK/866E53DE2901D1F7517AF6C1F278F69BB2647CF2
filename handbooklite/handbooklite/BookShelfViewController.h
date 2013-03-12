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
#import "ProgressAlertView.h"
#import "DownloadUtil.h"
#import "CostomAlertView.h"
#import "DownloadListViewController.h"
#import "Temp.h"

@interface BookShelfViewController : UIViewController<ASIHTTPRequestDelegate,ZXingDelegate,MMGridViewDelegate,MMGridViewDataSource,DownloadAlertViewDelegate,DownloadUtilDelegate,CostomAlertViewDelegate,UIAlertViewDelegate,DownloadListViewDelegate>{
    
    ASINetworkQueue *_networkQueue;
    NSString *_books_path;
    
    NSMutableArray *_books;
    IBOutlet MMGridView *_gridView;
    
    IBOutlet UILabel *_lbTitle;
    IBOutlet UILabel *_lbPhoto;
    IBOutlet UILabel *_lbLxwm;
    IBOutlet UILabel *_lbEdit;
    IBOutlet UILabel *_lbDownloadList;
    
    IBOutlet UIImageView *leftMenuImgView;
    
    UIProgressView *_progress;
    
    InterceptorWindow *_myWindow;
    NSString *_cacheBookPath;
    NSString *_bundleBookPath;
    NSString *_defaultScreeshotsPath;
    
    DownloadAlertView *_downloadAlertView;
    
    ContactUsViewController *_contactUsView;
    
    DownloadUtil *downloadUtil;
    ProgressAlertView *progressAlert;
    CostomAlertView *promptAlert;
    
    NSDictionary *_paramBookDic;
    Temp *paramTemp;//定义全局变量 在是否立刻下载中用到
    
    NSDictionary *paramPushData;//推送过来的数据  全局变量
    
    DownloadListViewController *downloadListView;
    
    ASIFormDataRequest *formDataRequest;
}
@property (nonatomic ,strong) ASINetworkQueue *networkQueue;
@property (nonatomic ,copy) NSString *books_path;
@property (nonatomic, strong) NSArray *books;
@property (nonatomic, strong) MMGridView *gridView;

@property (nonatomic, strong) UILabel *lbTitle;
@property (nonatomic, strong) UILabel *lbPhoto;
@property (nonatomic, strong) UILabel *lbLxwm;
@property (nonatomic, strong) UILabel *lbEdit;
@property (nonatomic, strong) UILabel *lbDownloadList;

@property (nonatomic, strong) UIImageView *leftMenuImgView;

@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) InterceptorWindow *myWindow;
@property (nonatomic, strong) NSString *cacheBookPath;
@property (nonatomic, strong) NSString *bundleBookPath;
@property (nonatomic, strong) NSString *defaultScreeshotsPath;

@property (nonatomic, strong) DownloadAlertView *downloadAlertView;
@property (nonatomic, strong) WaitAlertView *waitAlertView;

@property (nonatomic, strong) ContactUsViewController *contactUsView;

@property (nonatomic, strong) NSDictionary *paramBookDic;

- (void)toDownloadViewByBookCell:(MMGridViewCell *)bookCell;

- (void)toBookViewController:(int)index;

- (void)updateBooks;

- (IBAction)scanClickSelector:(id)sender;

- (IBAction)toContactUsViewSelector:(id)sender;

- (IBAction)clickEditSelector:(id)sender;

//添加一本手册
- (void)addBookCell;

//下载列表
- (IBAction)clickDownloadListSelector:(id)sender;

//重构二维码
- (NSString *)saxReader:(NSString *)str;

//通过URL打开手册
- (void)openBookByURL:(NSString *)urlString;

@end
