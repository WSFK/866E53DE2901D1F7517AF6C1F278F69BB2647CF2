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
#import "HttpHeader.h"
#import "TokenUtil.h"
#import "PublicImport.h"
#import "PushMsg.h"
#import "PushMsgAlert.h"

@interface BookShelfViewController ()

@end

@implementation BookShelfViewController

@synthesize books_path =_books_path;



@synthesize books =_books;
@synthesize cellStatusDic;
@synthesize gridView =_gridView;





@synthesize lbTitle =_lbTitle;
@synthesize lbPhoto =_lbPhoto;
@synthesize lbLxwm =_lbLxwm;
@synthesize lbEdit =_lbEdit;

@synthesize leftMenuImgView;

@synthesize myWindow =_myWindow;
@synthesize bundleBookPath =_bundleBookPath;
@synthesize cacheBookPath = _cacheBookPath;
@synthesize defaultScreeshotsPath =_defaultScreeshotsPath;

@synthesize downloadAlertView =_downloadAlertView;

@synthesize contactUsView =_contactUsView;

@synthesize downloadTempDic =_downloadTempDic;

@synthesize verifyHandle;

@synthesize leadView;

#define BOOK_CELL_NUMBER 5
#define BOOKS_DIRECTOR @"books"
#define SCREENSHOT_DIRECTOR @"wsyd-screenshots"
#define ALERT_3G_TAG 1002
#define ALERT_PUSH_DOWNLOAD 1004




#define STATUS_DIC_KEY          @"status"
#define OPEN_STATUS_DIC_KEY     @"openstatus"


#define CELL_EMPTY_DIC_KEY      @"celltype"
#define CELL_EMPTY_YES          @"yes"
#define CELL_EMPTY_NO           @"no"


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
 
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [self.lbTitle setFont:DEFAULT_FONT(DEFAULT_TITLE_FONT_SIZE)];
    [self.lbTitle setTextAlignment:UITextAlignmentRight];
    [self.lbTitle setTextColor:[UIColor whiteColor]];
    [self.lbTitle setText:@"维思远达"];
    
    [self.lbPhoto setFont:DEFAULT_FONT(DEFAULT_BUTTON_FONT_SIZE)];
    [self.lbPhoto setTextColor:[UIColor whiteColor]];
    [self.lbPhoto setTextAlignment:UITextAlignmentCenter];
    [self.lbPhoto setText:@"拍照"];
    
    [self.lbLxwm setFont:DEFAULT_FONT(DEFAULT_BUTTON_FONT_SIZE)];
    [self.lbLxwm setTextColor:[UIColor whiteColor]];
    [self.lbLxwm setTextAlignment:UITextAlignmentCenter];
    [self.lbLxwm setText:@"联系我们"];
    
    [self.lbEdit setFont:DEFAULT_FONT(DEFAULT_BUTTON_FONT_SIZE)];
    [self.lbEdit setTextColor:[UIColor whiteColor]];
    [self.lbEdit setTextAlignment:UITextAlignmentCenter];
    [self.lbEdit setText:@"编辑"];
    
    
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
    
    
    //注册检查列表通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBookListVerify:)
                                                 name:@"verify_downloadnum_notification"
                                               object:nil];
    
    //注册打开手册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openOrAddBook:)
                                                 name:@"open_or_add_notification"
                                               object:nil];
  
  //注册推送接受通知
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(showPushMessage:)
                                               name:@"push_notification"
                                             object:nil];

  
    //初始化联系我们
    _contactUsView =[[ContactUsViewController alloc]
                     initWithNibName:@"ContactUsViewController"
                     bundle:nil];
    [_contactUsView setViewHidden:YES withAnimation:NO];
    [self.view addSubview:_contactUsView.view];
    
    
    
    
    
    //查询手册列表
    [self queryBookList];
    //初始化书架
    [self setUpMMGridView];
    
    
    if([Util getValueFromPlist:@"LEADVIEW"]){
        [self loadLeadView];
    }
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadLeadView{
    NSArray *images =[[NSArray alloc] initWithObjects:@"1.png",@"2.png",@"3.png", nil];
    
    leadView =[[LeadView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         self.view.frame.size.width+20,
                                                         self.view.frame.size.height)
                               withImageNames:images];
    [leadView setDelegate:self];
    [self.view addSubview:leadView];
}

- (void)leadViewCancel{
    [UIView animateWithDuration:1.0 animations:^{
        [leadView setFrame:CGRectMake(leadView.frame.origin.x
                                      , 768
                                      , leadView.frame.size.width
                                      , leadView.frame.size.height)];
        [leadView setAlpha:0.0];
    } completion:^(BOOL finished){
        
        [leadView removeFromSuperview];
        leadView =nil;
        
        [Util writeValueToPlist:@"LEADVIEW" value:NO];
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        NSString *prompt =[defaults objectForKey:@"prompt"];
        if (![prompt isEqualToString:@"YES"]) {
            
            [self performSelector:@selector(showPromptAlert) withObject:nil afterDelay:0.5];
        }
    }];
}


//查询手册列表
- (void)queryBookList{
    
    if ([_books count] >0) {
        [_books removeAllObjects];
    }
    _books =[DBUtils queryAllBooks];
    
    NSUInteger numberOfCell =([_books count]%BOOK_CELL_NUMBER)>0?
    [_books count]+(BOOK_CELL_NUMBER-([_books count]%BOOK_CELL_NUMBER)):[_books count]+BOOK_CELL_NUMBER;
    
    if (!cellStatusDic) {
        cellStatusDic =[[NSMutableDictionary alloc] initWithCapacity:numberOfCell];
    }
    [cellStatusDic removeAllObjects];
    
    
    for (int i = 0; i < numberOfCell; i++) {
        
        Book *book = nil;
        
        if ((i+1) <= [_books count]) {
            
            book =[_books objectAtIndex:i];
        }
        
        NSMutableDictionary *statusDic =[[NSMutableDictionary alloc] init];
        
        if (book) {
            
            [statusDic setObject:[book status] forKey:STATUS_DIC_KEY];
            [statusDic setObject:[book openstatus] forKey:OPEN_STATUS_DIC_KEY];
            [statusDic setObject:CELL_EMPTY_NO forKey:CELL_EMPTY_DIC_KEY];
            
        }else{
            
             [statusDic setObject:CELL_EMPTY_YES forKey:CELL_EMPTY_DIC_KEY];
        }       
        
        [cellStatusDic setObject:statusDic forKey:[book downnum]==nil?[NSString stringWithFormat:@"empty%i",i]:[book downnum]];
    }
    
}

//接受推送数据的提示
- (void)showPushMessage:(NSNotification *)notifi{
    
    NSDictionary *pushData =[notifi object];
    
    NSString *downnum =[pushData objectForKey:@"downnum"];
    
    Book *book =[[Book alloc] init];
    [book setDir:downnum];
    
    //判断是否有手册
    if ([DBUtils isExistBookByDownnum:downnum] && [self isHasBookLocation:book]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OF_PUSH_MSG_TO_SHOW object:pushData];
        
    }
    
}

- (PushMsgAlert *)createPushMsgAlert:(NSString *)msg withPushDownnum:(NSString *)pushDownnum{
    
    PushMsgAlert *alert =[[PushMsgAlert alloc] initWithTitle:@"四维册推送"
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:@"取  消"
                                           otherButtonTitles:@"确  定", nil];
    [alert setTag:ALERT_PUSH_DOWNLOAD];
    [alert setPushDownnum:pushDownnum];
    
    //记录日志
    [Util writeToLog:USERUUID type:LOG_TYPE_OPEN_PUSH bookId:pushDownnum];
    
    return alert;
}


- (void)showPushAlert:(NSMutableArray *)pushMsgs{
  
  for (PushMsg *pm in pushMsgs) {
    
    PushMsgAlert *alert =[self createPushMsgAlert:pm.msg withPushDownnum:pm.msg];
    [alert show];
  }
}


- (void)showPromptAlert{
  
    promptAlert =[[CostomAlertView alloc] initWithMessage:@"是否要下载本软件的使用帮助手册?"];
    [promptAlert setDelegate:self];
    [promptAlert show];
}

#pragma -mark CostomAlertDelegate
- (void)didComfirm{
    
    //添加帮助手册
    [self openBookByURL:[self saxReader:HELP_DOWNNUM codeType:CODE_TYPE_INPUT]];
    
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

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
  CCLog(@"===> BookShelf unload!");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    self.leftMenuImgView =nil;
    
    self.progress =nil;
    
    self.downloadTempDic =nil;
    
    
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

//列表显示的个数  包括空位
#pragma - MMGridViewDataSource

- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView
{
    return ([_books count]%BOOK_CELL_NUMBER)>0?
    [_books count]+(BOOK_CELL_NUMBER-([_books count]%BOOK_CELL_NUMBER)):[_books count]+BOOK_CELL_NUMBER;
}

//初始化书架上面的手册
#pragma - MMGridViewDataSource
- (MMGridViewCell *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index
{

    BookCellView *cell = [[BookCellView alloc] initWithFrame:CGRectNull andIndex:index];
    
    [cell setIsClick:YES];
    [cell.title setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [cell.title setTextColor:[UIColor whiteColor]];
    [cell.title setTextAlignment:UITextAlignmentCenter];
    
    Book *book =nil;
    
    if ((index + 1) <= [_books count]){
        
        book =[_books objectAtIndex:index];
    }
    
    
    NSMutableDictionary *statusDic =[cellStatusDic objectForKey:[book downnum] ==nil
                                     ?[NSString stringWithFormat:@"empty%i",index]
                                                               :[book downnum]];
    
    if ([CELL_EMPTY_YES isEqualToString:[statusDic objectForKey:CELL_EMPTY_DIC_KEY]]) {
        
        //cell.title.text = [NSString stringWithFormat:@"点击获取"];
        
        cell.backgroundView.image = [UIImage imageNamed:@"kw.png"];
        
        [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
        
        [cell.backgroundView setContentMode:UIViewContentModeCenter];
        
        [cell setType:TYPE_CELL_EMPTY];
        
        return cell;
    }
    
    cell =[self createBookCell:book withStatusDic:statusDic atIndex:index];
    
    
    return cell;
}


//创建手册
- (BookCellView *)createBookCell:(Book *)book withStatusDic:(NSMutableDictionary *)statusDic atIndex:(NSUInteger)index{
    
    
    BookCellView *cell = [[BookCellView alloc] initWithFrame:CGRectNull andIndex:index];
    
    [cell setIsClick:YES];
    [cell.title setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [cell.title setTextColor:[UIColor whiteColor]];
    [cell.title setTextAlignment:UITextAlignmentCenter];
    
    if ([CELL_EMPTY_NO isEqualToString:[statusDic objectForKey:CELL_EMPTY_DIC_KEY]]) {
        
        NSString *iconPath =[self.books_path stringByAppendingFormat:@"/icons/%@",[book getIconName]];
        
        NSString *name =@"";
        
        UIImage *iconImage;
        NSFileManager *fm =[NSFileManager defaultManager];
        
        if ([fm fileExistsAtPath:iconPath]) {
            
            iconImage =[UIImage imageWithContentsOfFile:iconPath];
            name =[book name];
            [cell setIsHas:YES];
            
            
            if ([OPEN_STATUS_NO isEqualToString:[statusDic objectForKey:OPEN_STATUS_DIC_KEY]]) {
                
                [cell.iconNewImgView setHidden:NO];
            }
            
            if ([OPEN_STATUS_YES isEqualToString:[statusDic objectForKey:OPEN_STATUS_DIC_KEY]]) {
                
                [cell.iconNewImgView setHidden:YES];
            }
            
            
            
        }else if([STATUS_already_enter_code_not_found isEqualToString:[statusDic objectForKey:STATUS_DIC_KEY]]){
            
            iconImage =[UIImage imageNamed:@"code_error.png"];
            [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
            name =@"手册未找到";
            
        }else if([STATUS_already_enter_code_not_share isEqualToString:[statusDic objectForKey:STATUS_DIC_KEY]]){
            
            iconImage =[UIImage imageNamed:@"code_error.png"];
            [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
            name =@"手册尚未分享";
            
        }else if([STATUS_already_enter_code_out_date isEqualToString:[statusDic objectForKey:STATUS_DIC_KEY]]){
            
            iconImage =[UIImage imageNamed:@"code_error.png"];
            [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
            name =@"手册已过期";
            
        }else{
            
            iconImage =[UIImage imageNamed:@"default_icon.png"];
            //iconImage =[UIImage imageNamed:@"landscape_bg.png"];
            [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
            name =@"Waitting";
        }
        
        if ([STATUS_downloading_exception isEqualToString:[statusDic objectForKey:STATUS_DIC_KEY]]) {
            
            [cell endProgress];
            [cell.lbdling setHidden:YES];
            [cell.suspendView setHidden:YES];
            [cell.iconNewImgView setHidden:YES];
            
            iconImage =[UIImage imageNamed:@"code_error.png"];
            [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
            
        }
        
        if ([STATUS_downloading_suspend isEqualToString:[statusDic objectForKey:STATUS_DIC_KEY]]) {
        
           [cell.suspendView setHidden:NO];
           [cell.lbdling setHidden:YES];
        }
        
        if ([STATUS_downloading_waitting isEqualToString:[statusDic objectForKey:STATUS_DIC_KEY]]) {
            
            [cell.suspendView setHidden:YES];
            [cell.lbdling setHidden:NO];
            [cell.lbdling setText:@"等待中..."];
        }
      
        [cell reloadBookIcon:cell iconImage:iconImage];
        
        cell.title.text =name;
        
        [cell setType:TYPE_CELL_BOOK];
        [cell setDownnum:[book downnum]];
        
        
    }
    
    
    [cell showDeleteBtn:self.gridView.edit];
  NSUInteger pushCount =[DBUtils queryCountOfPushMsgByDownnum:[book downnum]];
  [cell showPushNumber:pushCount];
    return cell;
}



// ----------------------------------------------------------------------------------

#pragma - MMGridViewDelegate

- (void)gridView:(MMGridView *)gridView didSelectCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index
{
    
    [self queryBookList];
    
    //编辑状态 或 不可点击 不做操作
    if ([_gridView edit]) {
        return;
    }
    
    if ((index +1) > [self.books count]) {
        [self toScanView];
    }else{
        Book *book =[self.books objectAtIndex:index];
        
        if ([STATUS_already_download isEqualToString:[book status]] && [self isHasBookLocation:book]) {
            
            if ([OPEN_STATUS_NO isEqualToString:[book status]]) {
                
                //记录日志
                [Util writeToLog:USERUUID type:LOG_TYPE_NEW_CLICK bookId:[book downnum]];
            }
            //更新状态
            [DBUtils updateOpenStatus:OPEN_STATUS_YES downnum:[book  downnum]];
            [[(BookCellView *)cell iconNewImgView] setHidden:YES];
            [self toBookView:book];
            
            return;
        }
        
        if ([STATUS_downloading_waitting isEqualToString:[book status]] ||
            [STATUS_downloading_suspend isEqualToString:[book status]] ||
            [STATUS_downloading_exception isEqualToString:[book status]]) {
            
            if (![NetWorkCheck checkReachable]) {
                return;
            }
            
            [[(BookCellView *)cell suspendView] setHidden:YES];
            [[(BookCellView *)cell lbdling] setHidden:NO];
            [[(BookCellView *)cell lbdling] setText:@"等待中..."];
            [self addDownloadTempArray:book index:index];
            
            return;
        }
        
        if ([STATUS_downloading isEqualToString:[book status]]) {
            
            [(BookCellView *)cell cancelDownload];
            [DBUtils updateBookStatus:STATUS_downloading_suspend downnum:[book downnum]];
            
            return;
        }
        
        if ([STATUS_already_enter_code isEqualToString:[book status]] ||
            [STATUS_already_enter_code_not_found isEqualToString:[book status]] ||
            [STATUS_already_enter_code_not_share isEqualToString:[book status]] ||
            [STATUS_already_enter_code_out_date isEqualToString:[book status]] ||
            [STATUS_already_enter_code_suspend isEqualToString:[book status]])
        {
            
            if (![NetWorkCheck checkReachable]) {
                return;
            }
            [self startVerifyHandleWithDownnum:book.downnum verifyType:VERIFY_TYPE_SIMPLE];
            
        }
        
        
    }
    
    
}

//所有下载方法    统一调用这个方法
- (void)startDownloadAction{
  
  if (self.downloadTempDic) {
    
    Book *book =[self.downloadTempDic objectForKey:@"book"];
    NSNumber *num =[self.downloadTempDic objectForKey:@"index"];
    NSUInteger index =[num intValue];
    
    [self startDownload:book atIndex:index];
    
  }
}


- (void)startDownload:(Book *)book atIndex:(NSUInteger)index{
    
    [DBUtils updateBookStatus:STATUS_downloading downnum:[book downnum]];
    
    BookCellView *cell =(BookCellView *)[self.gridView.bookCellDic objectForKey:[NSString stringWithFormat:@"%i",index]];
    
    [cell startDownload:[book icon] zipUrlString:[book zip] saveDir:[book dir] bookName:[book name]];
}

#pragma - MMGridViewDelegate  下载完成
- (void)gridView:(MMGridView *)gridView finishedCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index error:(NSString *)error{
    
    NSString *downnum =[(BookCellView *)cell downnum];
    
    if ([@"null" isEqualToString:error]) {
        //更新数据库状态
        [DBUtils updateBookStatus:STATUS_already_download downnum:downnum];
        
    }
    
    if ([@"failed" isEqualToString:error]) {
        
        //更新数据库状态
        [DBUtils updateBookStatus:STATUS_downloading_exception downnum:downnum];
    }
    
    //从下载队列中移除
    [operationArray removeAllObjects];
    
    if ([@"cancel" isEqualToString:error]) {
        
        return;
    }
    
    [self addOperationArray];
    
    [self queryBookList];
}

#pragma -mark MMGridViewDelegate  点击推送数字
- (void)gridView:(MMGridView *)gridView didPushNumberShowCell:(MMGridViewCell *)cell{
  
  BookCellView *bookCell =(BookCellView *)cell;
  
  NSMutableArray *pushMsgs =[DBUtils queryPushMsgByDownnum:bookCell.downnum];
  
  [self showPushAlert:pushMsgs];
  
  //清空记录
  [DBUtils deletePushMsgByDownnum:bookCell.downnum];
  
  NSUInteger pushCount =[DBUtils queryCountOfPushMsgByDownnum:bookCell.downnum];
  [bookCell showPushNumber:pushCount];
  
}

- (void)setEdit:(BOOL)isEdit{
    
    
    if (isVerify) {
        return;
    }
    
    for (id key in self.gridView.bookCellDic) {
        
        
        BookCellView *cell =(BookCellView *)[self.gridView.bookCellDic objectForKey:key];
        
        if ([cell.type isEqualToString:TYPE_CELL_BOOK]) {
            
            //取消所有下载中的手册
            if ([cell isDownloading] && isEdit) {
                
                [DBUtils updateBookStatus:STATUS_downloading_suspend downnum:[cell downnum]];
                [cell cancelDownload];
            }
            
            [cell showDeleteBtn:isEdit];
            
            self.gridView.edit =isEdit;
        }
        
    }
}




- (void)gridView:(MMGridView *)gridView deleteCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index{
    
    [self deleteBook:index];
    
    //刷新列表
    [self queryBookList];
    [self.gridView reloadData];
}





//删除手册方法
- (void)deleteBook:(NSUInteger)index{
    
    Book *book =[_books objectAtIndex:index];
    
    NSString *bookPath =[CACHE_PATH stringByAppendingFormat:@"/books/%@",[book dir]];
    
    NSString *sccreeshotsPath =[self.defaultScreeshotsPath stringByAppendingFormat:@"/%@",[book downnum]];
    
    NSString *iconPath =[CACHE_PATH stringByAppendingFormat:@"/books/icons/%@",[book getIconName]];
    
    if ([DBUtils deleteBookByDownnum:[book downnum]]) {
        
        
        
        NSFileManager *fm =[NSFileManager defaultManager];
        if ([fm fileExistsAtPath:sccreeshotsPath])
        {
            //删除缓存图片
            BOOL result =[fm removeItemAtPath:sccreeshotsPath error:nil];
            if (!result) {
                CCLog(@"remove file failed：%@",sccreeshotsPath);
            }
            
        }
        if([fm fileExistsAtPath:bookPath])
        {
            //删除本地手册文件
            BOOL result =[fm removeItemAtPath:bookPath error:nil];
            if(!result){
                CCLog(@"remove file failed：%@",bookPath);
            }
        }
        
        if ([fm fileExistsAtPath:iconPath]) {
            //删除手册图标
            BOOL result =[fm removeItemAtPath:iconPath error:nil];
            if (!result) {
                CCLog(@"remove file failed：%@",iconPath);
            }
        }
        
        
    }
    
}


//初始化MMGridView
- (void)setUpMMGridView{
    
    self.gridView.cellMargin = 20;//手册之间的填充20像素
    
    self.gridView.numberOfRows = BOOK_CELL_NUMBER;//书架一行显示5本手册
    
    self.gridView.numberOfColumns = 3;
    
    //self.gridView.layoutStyle = HorizontalLayout; //水平布局
    
    self.gridView.layoutStyle = VerticalLayout;     //垂直布局
    
    
    [self.gridView setBackgroundColor:[UIColor clearColor]];
}


//显示拍照 或者 录码 对话框
- (void)showDownloadAlertView{
    
    _downloadAlertView =[[DownloadAlertView alloc] initWithImage:[UIImage imageNamed:@"alert.png"]];
    [_downloadAlertView setDelegate:self];
    
    [_downloadAlertView show];
}

#pragma -mark DownloadAlertViewDelegate
- (void)cancelPhoto{
}

#pragma -mark DownloadAlertViewDelegate
- (void)goPhotoView{
   [self toScanView];
}

#pragma -mark DownloadAlertViewDelegate
- (void)commitWithText:(NSString *)text{
    
    [self openBookByURL:[self saxReader:text codeType:CODE_TYPE_INPUT]];
    
}


//点击拍照按钮
- (void)scanClickSelector:(id)sender{
    
    //如果当前为编辑状态  取消
    [self cancelEdit];
    
    //改成启动对话框
    [self showDownloadAlertView];
    
}

- (void)toScanView{
  
  //显示二维码
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTwoCodeResult:) name:@"TWOCODEWITHRRESULT" object:nil];
  TwoCapture *tc = [TwoCapture newInstence];
  tc.isSendTwoCodeNoti = NO;
  
  UIViewController *cap = [[NSClassFromString(@"CaptureViewController") alloc] initWithNibName:@"CaptureViewController" bundle:nil];
  [self presentModalViewController:cap animated:YES];
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
    [self performSelector:@selector(openBookByURL:) withObject:[self saxReader:result codeType:CODE_TYPE_PHOTO] afterDelay:1.0];
  }
  
}

#pragma -mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  if (alertView.tag==ALERT_3G_TAG && buttonIndex == 1) {
    [self performSelector:@selector(startDownloadAction) withObject:nil afterDelay:0.5];
  }
  
  else if(alertView.tag == ALERT_PUSH_DOWNLOAD){
    
    if (buttonIndex == 1) {
      //下载推送过来的手册
      
      PushMsgAlert *alert =(PushMsgAlert *)alertView;
      
      NSString *pushDownnum =[alert pushDownnum];
      
      [self openBookByURL:[self saxReader:pushDownnum codeType:CODE_TYPE_PUSH]];
    }
  }
  
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

- (void)setDownloadTemp:(Book *)book index:(NSNumber *)index{
  
  if (!self.downloadTempDic) {
    self.downloadTempDic =[[NSMutableDictionary alloc] initWithCapacity:2];
  }
  
  [self.downloadTempDic setObject:book forKey:@"book"];
  [self.downloadTempDic setObject:index forKey:@"index"];
}

//检查网络类型 开始下载                     Book | index
- (void)checkNetWorkToDownload:(NSMutableDictionary *)bookDic{
    
    Book *book =[bookDic objectForKey:@"book"];
    
    NSNumber *num =[bookDic objectForKey:@"index"];
    
    [self setDownloadTemp:book index:num];
    
    //判断当前网络类型
    if ([NetWorkCheck checkIs3G]) {
        [self ShowNetWorkWarn];
        
    }else{
        
        [self startDownloadAction];
    }
    
    
}


//联系我们
- (void)toContactUsViewSelector:(id)sender{
    [_contactUsView setViewHidden:![_contactUsView isHidden] withAnimation:YES];
}

//编辑
- (void)clickEditSelector:(id)sender{
    
    [self setEdit:!self.gridView.edit];
}
//取消编辑状态
- (void)cancelEdit{
    
    [self setEdit:NO];
}

//更新手册
- (void)updateBookCell:(Book *)book atIndex:(NSUInteger)index{
    
    [self queryBookList];
    
    NSMutableDictionary *statusDic =[self.cellStatusDic objectForKey:[book downnum]];
    
    BookCellView *cell =[self createBookCell:book withStatusDic:statusDic atIndex:index];
    
    [self.gridView updateBookCell:cell atIndex:index];
}

//添加新书
- (void)addBookCell:(Book *)book{
    
    [self queryBookList];
    
    NSUInteger index =[self.gridView getFirstEmptyCellIndex];
    
    NSMutableDictionary *statusDic =[cellStatusDic objectForKey:[book downnum]];
    
    BookCellView *cell =[self createBookCell:book withStatusDic:statusDic atIndex:index];
    
    [self.gridView updateBookCell:cell atIndex:index];
}


//重构二维码内容
- (NSString *)saxReader:(NSString *)str codeType:(NSString *)codeType{
    /**
     例子：http://ms.thoughtfactory.com.cn/client/interface_qxz?downloadnum=TFFLHELP&su=123&st=20130305122323&hash=5
     
     v2.0.2：https://itunes.apple.com/us/app/si-wei-ce-yue-du/id573415099?mt=8&downnum=1002&name=冷山学具
     
     重构后：wsydlite://www.wsyd.com?downloadnum=TFFLHELP&su=123&st=20130305122323&hash=5
     */
    
    
    if (!str || str.length==0) {
        return @"";
    }
    
    if ([codeType isEqualToString:CODE_TYPE_INPUT]) {
        return [NSString stringWithFormat:@"wsydlite://www.wsyd.com?downloadnum=%@&su=0&st=0&hash=0",str];
    }
    
    if ([codeType isEqualToString:CODE_TYPE_PUSH]) {
        
        NSString *param =[NSString stringWithFormat:@"downloadnum=%@&su=push&st=%@",str,[Util getDayString]];
        
        return [NSString stringWithFormat:@"wsydlite://www.wsyd.com?%@&hash=%i",param,[param hash]];
    }
    
    if ([codeType isEqualToString:CODE_TYPE_PHOTO]) {

        if ([str rangeOfString:@"?"].location !=NSNotFound && [str rangeOfString:@"?"].location >0) {
            

            return [str stringByReplacingOccurrencesOfString:
                    [str substringToIndex:[str rangeOfString:@"?"].location]
                                                  withString:@"wsydlite://www.wsyd.com"];
        }
        
        return @"null";
        
    }
    
    return @"";
}

- (void)openOrAddBook:(NSNotification *)noti{
    
    NSString *url =[noti object];
    
    [self openBookByURL:url];
}


- (void)openBookByURL:(NSString *)urlString{
    /**
     url:wsydlite://www.wsyd.com?downloadnum=%@&su=&st=&hash=
     
     wsydlite://www.wsyd.com?mt=8&downnum=1002&name=冷山学具
     */
    
    if ([urlString isEqualToString:@""]) {
        return;
    }
    
    if ([urlString isEqualToString:@"null"]) {
        
        [self showMessage:@"该二维码不能下载手册"];
        return;
    }
    
    NSString *temp =[[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] query];
    
    NSArray *temps =[temp componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *kvsDic = [[NSMutableDictionary alloc] init];
    if ([temps count] > 0) {
        
        for (NSString *kv in temps) {
            
            NSArray *kvs =[kv componentsSeparatedByString:@"="];
            if ([kvs count] > 1) {
                
                [kvsDic setObject:[kvs objectAtIndex:1] forKey:[kvs objectAtIndex:0]];
            }
        }
    }
    
    NSString *downnum =[kvsDic objectForKey:@"downloadnum"] ==nil?
    [kvsDic objectForKey:@"downnum"] ==nil?@"":[kvsDic objectForKey:@"downnum"]:
    [kvsDic objectForKey:@"downloadnum"];
    
    NSString *su =[kvsDic objectForKey:@"su"] ==nil?@"0":[kvsDic objectForKey:@"su"];
    
    NSString *st =[kvsDic objectForKey:@"st"] ==nil?@"0":[kvsDic objectForKey:@"st"];
    
    NSString *hash =[kvsDic objectForKey:@"hash"] ==nil?@"0":[kvsDic objectForKey:@"hash"];
    
    
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
        [bk setSu:su];
        [bk setSt:st];
        [bk setHash:hash];
        [bk setStatus:STATUS_already_enter_code];
        [bk setOpenstatus:OPEN_STATUS_NO];
        BOOL result =[DBUtils insertBook:bk];
        if (result) {
            //添加手册
            [self addBookCell:bk];
            
        }
        
        if ([NetWorkCheck checkReachable] && result) {
            //有网络  发送验证下载码
            [self startVerifyHandleWithDownnum:bk.downnum verifyType:VERIFY_TYPE_SIMPLE];
        }
        return;
    }else{
        
        [self showMessage:@"该手册已经添加过了!"];
        [self.gridView scrollToCellAtIndex:[self.gridView getIndexByDownnum:[book downnum]]];
    }
    
}

//列表验证下载码
- (void)didBookListVerify:(NSNotification *)noti{
    
    CCLog(@"开始执行列表检查......");
    [self startVerifyHandleWithDownnum:nil verifyType:VERIFY_TYPE_MORE];
}


//处理验证下载码结果
- (void)handleCheckInfo:(ASIHTTPRequest *) request{
    
    NSDictionary *responseData = [(NSDictionary *)[[request responseData] objectFromJSONData]
                                  objectForKey:@"bookInfoResponse"];
    
    NSString *httpHeader =[responseData objectForKey:@"httpImage"];
    //更新httpHeader
    [[HttpHeader shareInstance] updateHttpHeader:httpHeader];
    
    NSArray *datas =[responseData objectForKey:@"list"];
    
    for (NSDictionary *data in datas) {
        
        
        Book *b =[DBUtils queryBookByDownnum:[data objectForKey:@"downnum"]];
        
        
        if (b == nil) {
            continue;
        }
        
        
        
        if ([@"success" isEqualToString:[data objectForKey:@"status"]] ||
            [@"success_temp_share" isEqualToString:[data objectForKey:@"status"]]) {
            
            NSDictionary *book =[data objectForKey:@"book"];
            
            [b setName:[book objectForKey:@"name"]];
            [b setDir:[book objectForKey:@"downnum"]];
            [b setIcon:[book objectForKey:@"icon"]];
            [b setZip:[book objectForKey:@"zip"]];
            [b setBookId:[book objectForKey:@"id"]];
            
            [b setStatus:STATUS_downloading_waitting];
            
        }
        else if([@"failed_not_found" isEqualToString:[data objectForKey:@"status"]]){
            
            [b setStatus:STATUS_already_enter_code_not_found];
        }
        else if([@"failed_not_share" isEqualToString:[data objectForKey:@"status"]]){
            
            [b setStatus:STATUS_already_enter_code_not_share];
        }
        else if([@"failed_out_date" isEqualToString:[data objectForKey:@"status"]]){
            
            [b setStatus:STATUS_already_enter_code_out_date];
        }
        
        BOOL result =[DBUtils updateBook:b];
        
        CCLog(@"---更新数据");
        
        if (result) {
            
            [self updateBookCell:b atIndex:[self.gridView getIndexByDownnum:b.downnum]];
            
            if([STATUS_downloading_waitting isEqualToString:b.status]){
                
                [self addDownloadTempArray:b index:[self.gridView getIndexByDownnum:b.downnum]];
            }
        }
        
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

//启动验证机制
- (void)startVerifyHandleWithDownnum:(NSString *)downum verifyType:(NSString *)verifyType{
    
    if (!verifyHandle) {
        verifyHandle =[[VerifyHandle alloc] init];
        [verifyHandle setDelegate:self];
    }
    
    if (![verifyHandle isAction]) {
        [verifyHandle startVerifyWithDownnum:downum verifyType:verifyType];
    }
    
    isVerify =[verifyHandle isAction];
}

#pragma -mark VerifyHandleDelegate
- (NSMutableArray *)verifyDataSource:(VerifyHandle *)verifyHandle downnum:(NSString *)downnum verifyType:(NSString *)verifyType{
    
    if ([verifyType isEqualToString:VERIFY_TYPE_MORE]) {
        
        return [DBUtils queryAllBookNotVerify];
    }
    
    if ([verifyType isEqualToString:VERIFY_TYPE_SIMPLE]) {
        
        NSMutableArray *books =[[NSMutableArray alloc] init];
        Book *book =[DBUtils queryBookByDownnum:downnum];
        [books addObject:book];
        return books;
    }
    return nil;
    
}
#pragma -mark VerifyHandleDelegate
- (void)verifyFinished:(VerifyHandle *)verifyHandle request:(ASIHTTPRequest *)request{
    
    [self handleCheckInfo:request];
    
    isVerify = NO;
    
}
#pragma -mark VerifyHandleDelegate
- (void)verifyFailed:(VerifyHandle *)verifyHandle request:(ASIHTTPRequest *)request{
    
    CCLog(@"验证请求失败:%@",request.error);
    isVerify =NO;
}

- (void)addDownloadTempArray:(Book *)book index:(NSUInteger)index{
    
    NSMutableDictionary *bookDic =[[NSMutableDictionary alloc] init];
    [bookDic setObject:book forKey:@"book"];
    [bookDic setObject:[NSNumber numberWithInt:index] forKey:@"index"];
    
    if (!downloadTempArray) {
        
        downloadTempArray =[[NSMutableArray alloc] init];
    }
    
    for(NSDictionary *temDic in downloadTempArray){
        
        Book *book2 =[temDic objectForKey:@"book"];
        
        if ([book2.downnum isEqualToString:book.downnum]) {
            
            if (![DBUtils isHasStatusDownloading]) {
                
                [self addOperationArray];
            }
            return;
        }
    }
    
    [downloadTempArray addObject:bookDic];
    
    [self addOperationArray];
}

- (void)addOperationArray{
    
    if (!operationArray) {
        operationArray =[[NSMutableArray alloc] init];
    }
    
    if ([operationArray count] !=0) {
        
        return;
    }
    
    
    if (downloadTempArray && [downloadTempArray count] >0) {
        
        NSDictionary *dic =[downloadTempArray objectAtIndex:0];
        
        [operationArray addObject:dic];
        
        [downloadTempArray removeObjectAtIndex:0];
    }
    
    if (operationArray && [operationArray count] >0) {
        
        NSDictionary *dic =[operationArray objectAtIndex:0];
        
        [self checkNetWorkToDownload:[dic mutableCopy]];
    }
}


@end
