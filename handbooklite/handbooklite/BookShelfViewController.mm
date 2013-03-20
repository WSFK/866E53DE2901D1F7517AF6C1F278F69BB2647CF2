//
//  BookShelfViewController.m
//  handbooklite
//
//  Created by bao_wsfk on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookShelfViewController.h"
#import "JSONKit.h"
#import "BookCellView.h"
#import "BookViewController.h"
#import "QRCodeReader.h"
#import "NSString_NSString.h"
#import "NetWorkCheck.h"
#import "DBUtils.h"
#import "Book.h"
#import "HttpHeader.h"
#import "TokenUtil.h"
#import "UserInfo.h"

@interface BookShelfViewController ()

@end

@implementation BookShelfViewController

@synthesize networkQueue =_networkQueue;
@synthesize books_path =_books_path;
@synthesize progress =_progress;

@synthesize books =_books;
@synthesize gridView =_gridView;

@synthesize lbTitle =_lbTitle;
@synthesize lbPhoto =_lbPhoto;
@synthesize lbLxwm =_lbLxwm;
@synthesize lbEdit =_lbEdit;
@synthesize lbDownloadList =_lbDownloadList;

@synthesize leftMenuImgView;

@synthesize myWindow =_myWindow;
@synthesize bundleBookPath =_bundleBookPath;
@synthesize cacheBookPath = _cacheBookPath;
@synthesize defaultScreeshotsPath =_defaultScreeshotsPath;

@synthesize downloadAlertView =_downloadAlertView;

@synthesize contactUsView =_contactUsView;

@synthesize paramBookDic =_paramBookDic;

#define BOOK_CELL_NUMBER 5
#define BOOKS_DIRECTOR @"books"
#define SCREENSHOT_DIRECTOR @"wsyd-screenshots"

#define ALERT_DOWNLOAD_TAG 1001
#define ALERT_3G_TAG 1002
#define ALERT_PUSH_DOWNLOAD 1004

#define REQUEST_TYPE_DOWNNUM_CHECK @"downnum_check"


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title =@"免费版";
    }
    return self;
}

- (void)viewDidLoad
{
    [self.lbTitle setFont:[UIFont fontWithName:@"Microsoft YaHei" size:16]];
    [self.lbTitle setTextAlignment:UITextAlignmentRight];
    [self.lbTitle setTextColor:[UIColor whiteColor]];
    [self.lbTitle setText:@"维思远达"];
    
    [self.lbPhoto setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [self.lbPhoto setTextColor:[UIColor whiteColor]];
    [self.lbPhoto setTextAlignment:UITextAlignmentCenter];
    [self.lbPhoto setText:@"拍照"];
    
    [self.lbLxwm setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [self.lbLxwm setTextColor:[UIColor whiteColor]];
    [self.lbLxwm setTextAlignment:UITextAlignmentCenter];
    [self.lbLxwm setText:@"联系我们"];
    
    [self.lbEdit setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [self.lbEdit setTextColor:[UIColor whiteColor]];
    [self.lbEdit setTextAlignment:UITextAlignmentCenter];
    [self.lbEdit setText:@"编辑"];
    
    [self.lbDownloadList setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [self.lbDownloadList setTextColor:[UIColor whiteColor]];
    [self.lbDownloadList setTextAlignment:UITextAlignmentCenter];
    [self.lbDownloadList setText:@"下载列表"];
    
    self.books_path =[CACHE_PATH stringByAppendingPathComponent:BOOKS_DIRECTOR];
    self.bundleBookPath =[RESOURCE_PATH stringByAppendingPathComponent:BOOKS_DIRECTOR];
    self.cacheBookPath =[CACHE_PATH stringByAppendingPathComponent:BOOKS_DIRECTOR];
    self.defaultScreeshotsPath =[CACHE_PATH stringByAppendingPathComponent:SCREENSHOT_DIRECTOR];
    
    
    NSArray * windows =[UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        if ([window isKindOfClass:[InterceptorWindow class]]) {
            self.myWindow =(InterceptorWindow *)window;
            [_myWindow setDisableTap:YES];
        }
    }
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [self updateBooks];
    [self setUpMMGridView];
    
    _contactUsView =[[ContactUsViewController alloc]
                                             initWithNibName:@"ContactUsViewController"
                                             bundle:nil];
    [_contactUsView setViewHidden:YES withAnimation:NO];
    [self.view addSubview:_contactUsView.view];
    
    //下载列表
    downloadListView = [[DownloadListViewController alloc] init];
    [downloadListView setDelegate:self];
    [self.view insertSubview:downloadListView.view belowSubview:leftMenuImgView];
    [downloadListView setViewHidden:YES withAnimation:NO];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *prompt =[defaults objectForKey:@"prompt"];
    if (![prompt isEqualToString:@"YES"]) {
        
        [self performSelector:@selector(showPromptAlert) withObject:nil afterDelay:0.5];
    }
    
    //添加左右滑动事件
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeToLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeToRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    [super viewDidLoad];
  //注册推送接受通知
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushMessage:) name:@"push_notification" object:nil];
  
}

//接受推送数据的提示
- (void)showPushMessage:(NSNotification *)notifi{
    
    NSDictionary *pushData =[notifi object];
    paramPushData =pushData;
    
    NSString *msg =[paramPushData objectForKey:@"message"];
    NSString *downnum =[paramPushData objectForKey:@"downnum"];
    NSString *message =[NSString stringWithFormat:@"%@\n手册下载码:%@",msg,downnum];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"四维册推送"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"取  消"
                                         otherButtonTitles:@"确  定", nil];
    [alert setTag:ALERT_PUSH_DOWNLOAD];
    [alert show];
    
}


- (void)showPromptAlert{
    
    promptAlert =[[CostomAlertView alloc] initWithMessage:@"是否要下载本软件的使用帮助手册?"];
    [promptAlert setDelegate:self];
    [promptAlert show];
}

- (void)didSwipeToLeft{
    [_contactUsView setViewHidden:NO withAnimation:YES];
}

- (void)didSwipeToRight{
    [_contactUsView setViewHidden:YES withAnimation:YES];
}

#pragma -mark CostomAlertDelegate
- (void)didComfirm{
    
    
    [self requestDataByDownnum:HELP_DOWNNUM];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES" forKey:@"prompt"];
    [defaults synchronize];
}

- (void)didCancel{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES" forKey:@"prompt"];
    [defaults synchronize];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden =YES;
    [_myWindow setDisableTap:YES];
    //取消编辑
    [self cancelEdit];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
  NSLog(@"===> BookShelf unload!");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.networkQueue =nil;
    self.books_path =nil;
    self.books =nil;
    self.bundleBookPath =nil;
    self.cacheBookPath =nil;
    self.defaultScreeshotsPath =nil;
//    self.gridView =nil;
  
    self.lbTitle =nil;
    self.lbPhoto =nil;
    self.lbLxwm =nil;
    self.lbEdit =nil;
    self.lbDownloadList =nil;
    self.leftMenuImgView =nil;
    
    self.progress =nil;
    
    self.paramBookDic =nil;
    
    downloadListView =nil;
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    CCLog(@"------------------BookShelfViewController----------memoryWaining");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [self orientationByString:ORIENTATION InterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate
{
  return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscape;
}

//列表
#pragma - MMGridViewDataSource

- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView
{
    return ([_books count]%BOOK_CELL_NUMBER)>0?
    [_books count]+(BOOK_CELL_NUMBER-([_books count]%BOOK_CELL_NUMBER)):[_books count]+BOOK_CELL_NUMBER;
}

#pragma - MMGridViewDataSource
- (MMGridViewCell *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index
{
    BookCellView *cell = [[BookCellView alloc] initWithFrame:CGRectNull andIndex:index];
    [cell setIsClick:YES];
    [cell.title setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [cell.title setTextColor:[UIColor whiteColor]];
    [cell.title setTextAlignment:UITextAlignmentCenter];
    
    
    if ((index+1) >[_books count]) {
        cell.title.text = [NSString stringWithFormat:@"点击获取"];
        cell.backgroundView.image = [UIImage imageNamed:@"kw.png"];
        [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
        [cell.backgroundView setContentMode:UIViewContentModeCenter];
    }else{
        Book *book =[_books objectAtIndex:index];
        NSString *iconPath =[self.books_path stringByAppendingFormat:@"/icons/%@",[book getIconName]];
        [cell setBookId:[book ID]];
        CCLog(@"bookId:%i",[book ID]);
        CCLog(@"iconPath:%@",iconPath);
        
        UIImage *iconimg = [UIImage imageWithContentsOfFile:iconPath];
        double ih = iconimg.size.height;
        double iw = iconimg.size.width;
        
        double ifw = cell.bookIconView.frame.size.width;
        double ifh = cell.bookIconView.frame.size.height;
        
        if (iw > ih) {
            double nifh = ifh * ih / iw;
            double difh = ifh - nifh;
            
            CGRect newIconFrame = cell.bookIconView.frame;
            cell.bookIconView.frame = CGRectMake(newIconFrame.origin.x , newIconFrame.origin.y + difh , newIconFrame.size.width, newIconFrame.size.height - difh);
            
            CGRect newBackGroudFrame = cell.backgroundView.frame;
            cell.backgroundView.frame = CGRectMake(newBackGroudFrame.origin.x  , newBackGroudFrame.origin.y + difh, newBackGroudFrame.size.width, newBackGroudFrame.size.height - difh);
            
            CGRect delFrame =CGRectMake(newIconFrame.origin.x+newIconFrame.size.width-21,
                                        newIconFrame.origin.y + difh-21,
                                        42, 42);
            [cell.deleteBtn setFrame:delFrame];
        }
        
        if (iw < ih) {
            double nifw = ifw * iw / ih;
            double difw = ifw - nifw;
            
            CGRect newIconFrame = cell.bookIconView.frame;
            cell.bookIconView.frame = CGRectMake(newIconFrame.origin.x + difw / 2 , newIconFrame.origin.y , newIconFrame.size.width- difw, newIconFrame.size.height);
            
            CGRect newBackGroudFrame = cell.backgroundView.frame;
            cell.backgroundView.frame = CGRectMake(newBackGroudFrame.origin.x + difw / 2 , newBackGroudFrame.origin.y, newBackGroudFrame.size.width - difw, newBackGroudFrame.size.height);
            
            CGRect delFrame =CGRectMake(newIconFrame.origin.x + difw / 2 + newIconFrame.size.width- difw -21,
                                        newIconFrame.origin.y-21,
                                        42, 42);
            [cell.deleteBtn setFrame:delFrame];
        }
        
        [cell setIsHas:YES];
        NSString *bookTitle =[book name];
        cell.bookIconView.image = [UIImage imageWithContentsOfFile:iconPath];
        [cell.title setText:bookTitle];
        
        //编辑
        if ([_gridView isEdit]) {
            [cell startDeleteIndex:index andTarget:self];
        }
    }
    
    return cell;
}

// ----------------------------------------------------------------------------------

#pragma - MMGridViewDelegate

- (void)gridView:(MMGridView *)gridView didSelectCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index
{
    //[(BookCellView *)cell startProgress];
    
    //编辑状态不做操作
    if ([_gridView isEdit]) {
        return;
    }
    
    CCLog(@"----------index:%i",index);
    //判断当前点击的是否存在手册
    if ((index+1)>[self.books count] || ![self isHasBook:index]) {
        CCLog(@"--------当前没有手册 进入下载");
        [self toDownloadViewByBookCell:cell];
    }else {
        
        if ([self isHasBook:index]) {
            CCLog(@"-------有手册 进入手册观看");
            [self toBookViewController:index];
        }
    }
    
}

//判断本地手册是否存在
- (BOOL)isHasBook:(int)index{
    Book *book =[_books objectAtIndex:index];
    
    if (book ==nil) {
        return NO;
    }
    
    NSString *bookDocPath = [_cacheBookPath stringByAppendingPathComponent:[book dir]];
    
    NSFileManager *fm =[NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:bookDocPath] && 
        [fm fileExistsAtPath:[bookDocPath stringByAppendingPathComponent:@"book.json"]]) 
    {
        return YES;
    }
    return NO;
}

#pragma - MMGridViewDelegate
- (void)gridView:(MMGridView *)gridView didDoubleTapCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index
{
    //双击事件
}

#pragma - MMGridViewDelegate
- (void)gridView:(MMGridView *)theGridView changedPageToIndex:(NSUInteger)index
{
    CCLog(@"----------changedPageToIndex:%i",index);
}

//初始化MMGridView
- (void)setUpMMGridView{
    self.gridView.cellMargin = 20;
    self.gridView.numberOfRows = BOOK_CELL_NUMBER;
    self.gridView.numberOfColumns = 3;
    //self.gridView.layoutStyle = HorizontalLayout; //水平布局
    self.gridView.layoutStyle = VerticalLayout;     //垂直布局
    //[self.gridView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [self.gridView setBackgroundColor:[UIColor clearColor]];
}

- (void)toDownloadViewByBookCell:(MMGridViewCell *)bookCell{
    
    _downloadAlertView =[[DownloadAlertView alloc] initWithImage:[UIImage imageNamed:@"alert.png"]];
    [_downloadAlertView setDelegate:self];
    
    [_downloadAlertView show];
}

#pragma -mark DownloadAlertViewDelegate
- (void)cancelPhoto{
}

#pragma -mark DownloadAlertViewDelegate
- (void)goPhotoView{
    [self scanClickSelector:nil];
}

#pragma -mark DownloadAlertViewDelegate
- (void)commitWithText:(NSString *)text{
    
    paramTemp =[[Temp alloc] init];
    
    [paramTemp setDownnum:text];
    
    //提示是否立刻下载
    [self showImmediatelyDownloadAlert];
}

//刷新手册列表
- (void)updateBooks{
    
    if (_books.count>0) {
        [_books removeAllObjects],_books =nil;
    }
    //初始化数据
    _books = [DBUtils queryAllBooks];
    
    CCLog(@"----book counts:%i",[_books count]);
}

//观看
- (void)toBookViewController:(int)index{
  HttpHeader *hh = [HttpHeader shareInstance];
  hh.tapTimes += 1;
  [iConsole log:[NSString stringWithFormat:@"打开手册次数：%d",hh.tapTimes]];
  
    Book *book =[_books objectAtIndex:index];
    
    NSString *bookCachePath = [_cacheBookPath stringByAppendingPathComponent:[book dir]];
    NSString *bookBundlePath = [_bundleBookPath stringByAppendingPathComponent:[book dir]];
    
    BookViewController *bookViewController = 
    [[BookViewController alloc] initWithCachesBookPath:bookCachePath
                                        bundleBookPath:bookBundlePath
                                 defaultScreeshotsPath:[_defaultScreeshotsPath
                                                        stringByAppendingPathComponent:[book dir]]
                                                target:self
                                               book:book];
    [_myWindow setDisableTap:NO];
    [_myWindow setTarget:[bookViewController scrollView] eventsDelegate:bookViewController];
    
    [bookViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    //不用push  因为push切换界面后 界面的方向旋转总是有问题
    // Check if iOS4 or 5
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        // iOS 5
        [self presentViewController:bookViewController animated:YES completion:nil];
    } else {
        // iOS 4
        [self presentModalViewController:bookViewController animated:YES];
    }
    //[bookViewController setTitle:[bookDic objectForKey:@"name"]];
    //[self.navigationController pushViewController:bookViewController animated:YES];
    //由于这两个方法暂时不知道为什么不能执行 现在使用通知的方式执行它们
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willRotate" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRotate" object:nil];
    
    
    
}

//点击拍照按钮
- (void)scanClickSelector:(id)sender{
  //显示二维码
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTwoCodeResult:) name:@"TWOCODEWITHRRESULT" object:nil];
  TwoCapture *tc = [TwoCapture newInstence];
  tc.isSendTwoCodeNoti = NO;
    
  UIViewController *cap = [[NSClassFromString(@"CaptureViewController") alloc] initWithNibName:@"CaptureViewController" bundle:nil];
  [self presentModalViewController:cap animated:YES];
  
  /**
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self 
                                                                                showCancel:YES 
                                                                                  OneDMode:NO];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    widController.readers = readers;
    NSBundle *mainBundle = [NSBundle mainBundle];
    //声音播放
    widController.soundToPlay =
    [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
    [self presentModalViewController:widController animated:YES];
   **/
}

#pragma mark -- new Zxing Function
-(void) showTwoCodeResult:(NSNotification *)notifi{
  [self dismissModalViewControllerAnimated:YES];
  
  TwoCapture *tc = [TwoCapture newInstence];
  if (tc.isSendTwoCodeNoti) {
    //显示二维码
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TWOCODEWITHRRESULT" object:nil];
    tc.isSendTwoCodeNoti = NO;
    NSString *result = [notifi object];
    //解析二维码
    paramTemp =[self tempFromString:result];
    //提示是否立刻下载
    [self showImmediatelyDownloadAlert];
  }
  
}

#pragma mark-ZXingDelegate
- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark-ZXingDelegate
- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result{
    if (self.isViewLoaded) {
        /**
         例子：http://ms.thoughtfactory.com.cn/client/interface_qxz?downloadnum=TFFLHELP&su=123
         
         解析后：wsydlite://www.wsyd.com?downloadnum=TFFLHELP&su=123
         */
        //解析二维码
        
        paramTemp =[self tempFromString:result];
        
        //提示是否立刻下载
        [self performSelector:@selector(showImmediatelyDownloadAlert) withObject:nil afterDelay:0.5];
        
    }
    [self dismissModalViewControllerAnimated:NO];
}

- (void)requestDataByDownnum:(NSString *)downnum{
    
    CCLog(@"----------downnum:%@",downnum);
    if (downnum ==nil || [downnum isEmpty]) {
        [self showMessage:@"该二维码不能下载手册"];
        return;
    }
    
    if ([DBUtils isExistBookByDownnum:downnum]) {
        [self showMessage:@"您已经下载过这本手册了"];
        return;
    }
    
    //请求数据
    ASIFormDataRequest *request =[ASIFormDataRequest
                                  requestWithURL:[NSURL URLWithString:DOWNLOAD_URL]];
    [request setDelegate:self];
    //不再重用上一个url
    [request setShouldAttemptPersistentConnection:NO];
    [request setTimeOutSeconds:10];
    [request setPostValue:downnum forKey:@"downloadnum"];
    [request setPostValue:[TokenUtil getLocalToken] forKey:@"token"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:downnum forKey:@"downnum"]];
    [request startAsynchronous];
    [self showWaitting];
    
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request{
    [self dismissWaitting];
    [self showMessage:@"网络故障，请稍后再试！"];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    [self dismissWaitting];
    
    if ([request responseStatusCode] ==200) {
        
        if ([(NSString *)[[request userInfo] objectForKey:@"type"] isEqualToString:REQUEST_TYPE_DOWNNUM_CHECK]) {
            //处理下载码验证信息
            [self handleCheckInfo:request];
            
        }
        
        NSDictionary *data = [(NSDictionary *)[[request responseData] objectFromJSONData]
                              objectForKey:@"handbookMsg"];
       
        if ([@"success" isEqualToString:[data objectForKey:@"status"]]) {
            
            NSString *downnum =[[request userInfo] objectForKey:@"downnum"];
            NSString *httpHeader =[(NSDictionary *)[[request responseData] objectFromJSONData] objectForKey:@"httpImage"];
            //更新httpHeader
            [[HttpHeader shareInstance] updateHttpHeader:httpHeader];
            
            NSMutableDictionary *book =[[data objectForKey:@"book"] mutableCopy];
            [book setObject:downnum forKey:@"downnum"];
            
            [request clearDelegatesAndCancel];
            
            [self setParamBookDic:book];//设置全局变量
            
            
            //通知下载
            [self performSelector:@selector(checkNetWorkToDownload) withObject:nil afterDelay:0.5];
            
        }
        else {
            [self showMessage:[data objectForKey:@"error"]];
        }
        
    }else {
        [self showMessage:[NSString stringWithFormat:@"请求错误:%i",[request responseStatusCode]]];
    }
}

#pragma -mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==ALERT_3G_TAG && buttonIndex == 1) {
        [self performSelector:@selector(downloadBook:) withObject:_paramBookDic afterDelay:0.5];
    }
    else if (alertView.tag == ALERT_DOWNLOAD_TAG)
    {
        //提示是否立刻下载操作
        if (buttonIndex ==0) {
            
            /**
                稍后下载 将Temp信息存入下载列表中
                判断列表中是否存在downnum 不存在添加
             */
            
            if(![DBUtils isExisttempByDownnum:[paramTemp downnum]]){
                
                [paramTemp setSavedate:[NSDate date]];
                if([DBUtils insertTemp:paramTemp]){
                    [self showMessage:@"成功保存到下载列表!"];
                }else{
                    [self showMessage:@"保存到下载列表失败!"];
                }
                
            }else{
                [self showMessage:@"下载列表中已存在!"];
            }
            
            
        }else if(buttonIndex ==1)
        {
            //立刻下载
            [self performSelector:@selector(requestDataByDownnum:) withObject:[paramTemp downnum] afterDelay:0.5];
        }
        
        paramTemp =nil;
    }else if(alertView.tag == ALERT_PUSH_DOWNLOAD){
        
        if (buttonIndex == 1) {
            //下载推送过来的手册
            [self downloadPushHandbook];
        }else{
            paramPushData =nil;
        }
    }

}

- (void)downloadPushHandbook{
    
    //根据下载码删除已有的手册记录
    CCLog(@"----------%@",paramPushData);
    NSString *downnum =[paramPushData objectForKey:@"downnum"];
    [DBUtils deleteBookByDownnum:downnum];
    
    [self requestDataByDownnum:downnum];
    
    paramPushData =nil;
    
}

- (void)ShowNetWorkWarn{
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示" 
                                                   message:@"当前属于3G网络，是否要继续下载?" 
                                                  delegate:self 
                                         cancelButtonTitle:@"取消" 
                                         otherButtonTitles:@"继续", 
                         nil];
    alert.tag =ALERT_3G_TAG;
    [alert show];
}

- (void)showImmediatelyDownloadAlert{
    
    //判断paramTemp是否为空 如果为空则不是该应用的二维码 做出提示
    if (paramTemp != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"是否立刻下载?"
                                                       delegate:self
                                              cancelButtonTitle:@"稍后下载"
                                              otherButtonTitles:@"立刻下载", nil];
        alert.tag = ALERT_DOWNLOAD_TAG;
        [alert show];
    }else{
        [self showMessage:@"该二维码不属于本应用！"];
    }
}

//检查网络类型 开始下载
- (void)checkNetWorkToDownload{
    
    //判断当前网络类型
    if ([NetWorkCheck checkIs3G]) {
        
        [self ShowNetWorkWarn];

    }else{
        [self performSelector:@selector(downloadBook:) withObject:_paramBookDic afterDelay:0.5];
    }

    
}

- (void)downloadBook:(NSDictionary *)book{
   
    progressAlert = [[ProgressAlertView alloc] init];
    downloadUtil = [[DownloadUtil alloc] init];
    CCLog(@"-------bookDic:%@",book);
    [downloadUtil startDownloadBookDic:book progressView:[progressAlert showPrg]];
    [downloadUtil setDelegate:self];
}

#pragma -mark DownloadUtilDelegate
- (void)didQueueFinished{
    [progressAlert dismiss];
}

- (void)didFailed{
    
    Temp *tp =[[Temp alloc] init];
    [tp setDownnum:[_paramBookDic objectForKey:@"downnum"]];
    [tp setName:[_paramBookDic objectForKey:@"name"]];
    [DBUtils insertTemp:tp];
    
    [self showMessage:@"下载失败，您可以到下载列表中找到继续下载！"];
}

- (void)didFinished{
    [self updateBooks];
    [self.gridView reloadData];
    [self showMessage:@"下载成功"];
}

//联系我们
- (void)toContactUsViewSelector:(id)sender{
    [_contactUsView setViewHidden:![_contactUsView isHidden] withAnimation:YES];
}

//编辑
- (void)clickEditSelector:(id)sender{
    
    //是否存在手册的标示
    BOOL isHasBook =NO;
    
    for (BookCellView *cell in [_gridView bookCells]) {
        //不是空位
        if ([cell isHas]) {
            [cell startDeleteIndex:cell.index andTarget:self];
            isHasBook =YES;
        }
    }
    if (isHasBook) {
        [_gridView setIsEdit:![_gridView isEdit]];
    }
}
//取消编辑状态
- (void)cancelEdit{
    
    [_gridView setIsEdit:NO];
    
    for (BookCellView *cell in [_gridView bookCells]) {
        //不是空位
        if ([cell isHas]) {
            [cell cancelEditBtn];
        }
    }
}

- (void)setParamBookDic:(NSDictionary *)paramBookDic{
    if (_paramBookDic) {
        _paramBookDic =nil;
    }
    _paramBookDic =paramBookDic;
}

//判断目录是否存在 如果不存在创建
- (void)createPath:(NSString *)path{
    NSFileManager *fm =[NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        BOOL result =[fm createDirectoryAtPath:path 
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        if (!result) {
            CCLog(@"------create %@:failed",path);
        }
    }
}

- (void)clickDownloadListSelector:(id)sender{
    
    [downloadListView setViewHidden:![downloadListView isHidden] withAnimation:YES];
}

#pragma -mark DownloadListViewDelegate
- (void)didDownloadFinished{
    [self updateBooks];
    [self.gridView reloadData];
}

//截取下载码和手册名称 返回temp
- (Temp *)tempFromString:(NSString *)str{
    
    Temp *temp =nil;
    NSDictionary *jsonData =[str objectFromJSONString];
    
    NSRange range1 =[str rangeOfString:@"&downnum=" options:NSBackwardsSearch];
    NSRange range2 =[str rangeOfString:@"&name=" options:NSBackwardsSearch];
    if (range1.location !=NSNotFound && range2.location !=NSNotFound) {
        
        NSString *tempStr =[str substringFromIndex:range1.location];
        tempStr =[tempStr substringFromIndex:[tempStr rangeOfString:@"="].location+1];
        
        NSString *downnum =[tempStr substringToIndex:[tempStr rangeOfString:@"&"].location];
        NSString *name =[tempStr substringFromIndex:[tempStr rangeOfString:@"="].location+1];
        temp=[[Temp alloc] init];
        [temp setName:name];
        [temp setDownnum:downnum];
    }else if(jsonData!=nil && [jsonData objectForKey:@"number"] !=[NSNull null]){
        
        temp=[[Temp alloc] init];
        [temp setDownnum:[jsonData objectForKey:@"number"]];
    
    }else{
        CCLog(@"Not the application of two-dimension code");
    }
    return temp;
}

//重构二维码内容
- (NSString *)saxReader:(NSString *)str{
    /**
     例子：http://ms.thoughtfactory.com.cn/client/interface_qxz?downloadnum=TFFLHELP&su=123&st=20130305122323&hash=5
     
     重构后：wsydlite://www.wsyd.com?downloadnum=TFFLHELP&su=123&st=20130305122323&hash=5
     */
    
    if (!str) {
        return @"";
    }
    if (str.length<10) {
        return [NSString stringWithFormat:@"wsydlite://www.wsyd.com?downloadnum=%@&su=0&st=0&hash=0",str];
        
    }
    
    return [str stringByReplacingOccurrencesOfString:
            [str substringToIndex:[str rangeOfString:@"?"].location]
                                          withString:@"wsydlite://www.wsyd.com"];
}

- (void)openBookByURL:(NSString *)urlString{
    /**
     url:wsydlite://www.wsyd.com?downloadnum=%@&su=&st=&hash=
     */
    
    if ([urlString isEqualToString:@""]) {
        CCLog(@"URL resutlt is null");
        return;
    }
    NSString *temp =[urlString substringFromIndex:([urlString rangeOfString:@"downloadnum="].location+[@"downloadnum=" length])];
    NSString *downnum =[temp substringToIndex:[temp rangeOfString:@"&"].location];
    
    temp =[urlString substringFromIndex:([urlString rangeOfString:@"su="].location+[@"su=" length])];
    NSString *su =[temp substringToIndex:[temp rangeOfString:@"&"].location];
    
    temp =[urlString substringFromIndex:([urlString rangeOfString:@"st="].location+[@"st=" length])];
    NSString *st =[temp substringToIndex:[temp rangeOfString:@"&"].location];
    
    NSString *hash =[urlString substringFromIndex:([urlString rangeOfString:@"hash="].location+[@"hash=" length])];
    
    CCLog(@"su:%@--st:%@--hash:%@",su,st,hash);
    
    Book *book =[DBUtils queryBookByDownnum:downnum];
    
    
    if([self isHasBookLocation:book]){
        //本地手册已经存在  直接打开手册
        [self toBookView:book];
        return;
    }
    if (![DBUtils isExistBookByDownnum:downnum]) {
        //数据库中不存在   添加一本手册
        Book *bk =[[Book alloc] init];
        [bk setDownnum:downnum];
        [bk setStatus:STATUS_already_enter_code];
        [DBUtils insertBook:book];
        
        
        if ([NetWorkCheck checkReachable]) {
            //有网络
            formDataRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:DOWNLOAD_URL]];
            
            [formDataRequest setDelegate:self];
            [formDataRequest setShouldAttemptPersistentConnection:NO];
            [formDataRequest setTimeOutSeconds:10];
            [formDataRequest setPostValue:downnum forKey:@"downloadnum"];
            [formDataRequest setPostValue:[TokenUtil getLocalToken] forKey:@"token"];
            [formDataRequest setPostValue:[UserInfo getUID] forKey:@"uid"];
            [formDataRequest setPostValue:st forKey:@"st"];
            [formDataRequest setPostValue:su forKey:@"su"];
            [formDataRequest setPostValue:hash forKey:@"hash"];
            
            [formDataRequest setUserInfo:[NSDictionary dictionaryWithObject:REQUEST_TYPE_DOWNNUM_CHECK forKey:@"type"]];
            [formDataRequest startAsynchronous];
        }
        return;
    }
    if ([[book status] isEqualToString:STATUS_downloading]) {
        //当前手册下载中  滚动到相应位置
        
        return;
    }
}

//处理验证下载码结果
- (void)handleCheckInfo:(ASIHTTPRequest *) request{
    
    NSDictionary *data = [(NSDictionary *)[[request responseData] objectFromJSONData]
                          objectForKey:@"handbookMsg"];
    NSString *httpHeader =[(NSDictionary *)[[request responseData] objectFromJSONData] objectForKey:@"httpImage"];
    //更新httpHeader
    [[HttpHeader shareInstance] updateHttpHeader:httpHeader];
    
    if ([@"success" isEqualToString:[data objectForKey:@"status"]]) {
        
        NSDictionary *book =[data objectForKey:@"book"];
        //存储数据到数据库
        Book *b =[DBUtils queryBookByDownnum:[data objectForKey:@"downnum"]];
        [b setName:[book objectForKey:@"name"]];
        [b setDir:[book objectForKey:@"downnum"]];
        [b setIcon:[book objectForKey:@"icon"]];
        [b setZip:[book objectForKey:@"zip"]];
        [b setBookId:[book objectForKey:@"id"]];
        
        [DBUtils updateBook:b];
        
    }
}

- (void)toBookView:(Book *)book{
    
    NSString *bookCachePath = [_cacheBookPath stringByAppendingPathComponent:[book dir]];
    NSString *bookBundlePath = [_bundleBookPath stringByAppendingPathComponent:[book dir]];
    
    BookViewController *bookViewController =
    [[BookViewController alloc] initWithCachesBookPath:bookCachePath
                                        bundleBookPath:bookBundlePath
                                 defaultScreeshotsPath:[_defaultScreeshotsPath
                                                        stringByAppendingPathComponent:[book dir]]
                                                target:self
                                                  book:book];
    [_myWindow setDisableTap:NO];
    [_myWindow setTarget:[bookViewController scrollView] eventsDelegate:bookViewController];
    
    [bookViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    //不用push  因为push切换界面后 界面的方向旋转总是有问题
    // Check if iOS4 or 5
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        // iOS 5
        [self presentViewController:bookViewController animated:YES completion:nil];
    } else {
        // iOS 4
        [self presentModalViewController:bookViewController animated:YES];
    }
    //[bookViewController setTitle:[bookDic objectForKey:@"name"]];
    //[self.navigationController pushViewController:bookViewController animated:YES];
    //由于这两个方法暂时不知道为什么不能执行 现在使用通知的方式执行它们
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willRotate" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRotate" object:nil];
    
}

//判断本地手册是否存在
- (BOOL)isHasBookLocation:(Book *)book{
    
    if (book ==nil) {
        return NO;
    }
    
    NSString *bookDocPath = [_cacheBookPath stringByAppendingPathComponent:[book dir]];
    
    NSFileManager *fm =[NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:bookDocPath] &&
        [fm fileExistsAtPath:[bookDocPath stringByAppendingPathComponent:@"book.json"]])
    {
        return YES;
    }
    return NO;
}

@end
