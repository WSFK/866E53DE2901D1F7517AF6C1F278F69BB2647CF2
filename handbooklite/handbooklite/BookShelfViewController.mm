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

@interface BookShelfViewController ()

@end

@implementation BookShelfViewController

@synthesize networkQueue =_networkQueue;
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

@synthesize paramBookDic =_paramBookDic;

@synthesize verifyHandle;

#define BOOK_CELL_NUMBER 5
#define BOOKS_DIRECTOR @"books"
#define SCREENSHOT_DIRECTOR @"wsyd-screenshots"

#define ALERT_DOWNLOAD_TAG 1001
#define ALERT_3G_TAG 1002
#define ALERT_PUSH_DOWNLOAD 1004




#define STATUS_DIC_KEY          @"status"
#define OPEN_STATUS_DIC_KEY     @"openstatus"
#define PUSH_STATUS_DIC_KEY     @"pushstatus"
#define PUSH_NUMBER_DIC_KEY     @"pushnumber"
#define PUSH_MESSAGE_DIC_KEY    @"pushmessage"


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
    
    
    
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *prompt =[defaults objectForKey:@"prompt"];
    if (![prompt isEqualToString:@"YES"]) {
        
        [self performSelector:@selector(showPromptAlert) withObject:nil afterDelay:0.5];
    }
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
            [statusDic setObject:STATUS_PUSH_NO forKey:PUSH_STATUS_DIC_KEY];
            [statusDic setObject:@"0" forKey:PUSH_NUMBER_DIC_KEY];
            [statusDic setObject:@"" forKey:PUSH_MESSAGE_DIC_KEY];
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

#pragma -mark CostomAlertDelegate
- (void)didComfirm{
    
    //添加帮助手册
    [self openBookByURL:[self saxReader:HELP_DOWNNUM]];
    
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
  //注册推送接受通知
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushMessage:) name:@"push_notification" object:nil];
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
    self.leftMenuImgView =nil;
    
    self.progress =nil;
    
    self.paramBookDic =nil;
    
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    CCLog(@"------------------BookShelfViewController----------memoryWaining");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [self orientationByString:ORIENTATION InterfaceOrientation:interfaceOrientation];
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
        }
        
        if ([STATUS_downloading_exception isEqualToString:[statusDic objectForKey:STATUS_DIC_KEY]]) {
            
            [cell endProgress];
            [cell.lbdling setHidden:YES];
            [cell.suspendView setHidden:YES];
            [cell.iconNewImgView setHidden:YES];
            
            iconImage =[UIImage imageNamed:@"code_error.png"];
            [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
            
        }
        
        
        [cell reloadBookIcon:cell iconImage:iconImage];
        
        cell.title.text =name;
        
        [cell setType:TYPE_CELL_BOOK];
        [cell setDownnum:[book downnum]];
        
        
    }
    
    if (![self.gridView isHasBookCell]) {
        
        [self.gridView setEdit:NO];
    }
    
    [cell showDeleteBtn:self.gridView.edit];
    
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
            
            //更新状态
            [DBUtils updateOpenStatus:OPEN_STATUS_YES downnum:[book  downnum]];
            [[(BookCellView *)cell iconNewImgView] setHidden:YES];
            [self toBookView:book];
            
            return;
        }
        
        if ([STATUS_downloading_waitting isEqualToString:[book status]] ||
            [STATUS_downloading_suspend isEqualToString:[book status]] ||
            [STATUS_downloading_exception isEqualToString:[book status]]) {
            
            if (![DBUtils isHasStatusDownloading]) {
                
                [self startDownload:book atIndex:index];
            }
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
            [self startVerifyHandle];
            
        }
        
        
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
    
    [self queryBookList];
}

- (void)setEdit:(BOOL)isEdit{
    
    
    if ([DBUtils isHasStatusDownloading] || isVerify) {
        return;
    }
    
    for (id key in self.gridView.bookCellDic) {
        
        
        BookCellView *cell =(BookCellView *)[self.gridView.bookCellDic objectForKey:key];
        
        if ([cell.type isEqualToString:TYPE_CELL_BOOK]) {
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
    
    [self openBookByURL:[self saxReader:text]];
    
}


//点击拍照按钮
- (void)scanClickSelector:(id)sender{
    
    //如果当前为编辑状态  取消
    [self cancelEdit];
    
    //改成启动对话框
    [self showDownloadAlertView];
    
}

- (void)toScanView{
    
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
        
        [self performSelector:@selector(openBookByURL:) withObject:[self saxReader:result] afterDelay:1.0];
        
    }
    [self dismissModalViewControllerAnimated:NO];
}



#pragma -mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==ALERT_3G_TAG && buttonIndex == 1) {
        [self performSelector:@selector(downloadBook:) withObject:_paramBookDic afterDelay:0.5];
    }
    
    else if(alertView.tag == ALERT_PUSH_DOWNLOAD){
        
        if (buttonIndex == 1) {
            //下载推送过来的手册
        }else{
            paramPushData =nil;
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


//检查网络类型 开始下载
- (void)checkNetWorkToDownload{
    
    //判断当前网络类型
    if ([NetWorkCheck checkIs3G]) {
        
        [self ShowNetWorkWarn];

    }else{
        [self performSelector:@selector(downloadBook:) withObject:_paramBookDic afterDelay:0.5];
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

- (void)setParamBookDic:(NSDictionary *)paramBookDic{
    if (_paramBookDic) {
        _paramBookDic =nil;
    }
    _paramBookDic =paramBookDic;
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

- (void)openOrAddBook:(NSNotification *)noti{
    
    NSString *url =[noti object];
    
    [self openBookByURL:url];
}


- (void)openBookByURL:(NSString *)urlString{
    /**
     url:wsydlite://www.wsyd.com?downloadnum=%@&su=&st=&hash=
     */
    
    NSUInteger p1 =[urlString rangeOfString:@"?downloadnum="].location;
    NSUInteger p2 =[urlString rangeOfString:@"&su="].location;
    NSUInteger p3 =[urlString rangeOfString:@"&st="].location;
    NSUInteger p4 =[urlString rangeOfString:@"hash="].location;
    
    if ([urlString isEqualToString:@""] &&(
        p1 ==2147483647 ||
        p2 ==2147483647 ||
        p3 ==2147483647 ||
        p4 ==2147483647))
    {
        CCLog(@"URL resutlt is null");
        //TODO 添加提示
        [self showMessage:@"该二维码无法进行下载!"];
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
            [self startVerifyHandle];
        }
        return;
    }else{
        
        [self.gridView scrollToCellAtIndex:[self.gridView getIndexByDownnum:[book downnum]]];
    }
    
}

//列表验证下载码
- (void)didBookListVerify:(NSNotification *)noti{
    
    CCLog(@"开始执行列表检查......");
    [self startVerifyHandle];
}


//处理验证下载码结果
- (void)handleCheckInfo:(ASIHTTPRequest *) request{
    
    NSArray *datas = [(NSDictionary *)[[request responseData] objectFromJSONData]
                          objectForKey:@"handbookMsgs"];
    NSString *httpHeader =[(NSDictionary *)[[request responseData] objectFromJSONData] objectForKey:@"httpImage"];
    //更新httpHeader
    [[HttpHeader shareInstance] updateHttpHeader:httpHeader];
    
    
    
    for (NSDictionary *data in datas) {
        
        
        Book *b =[DBUtils queryBookByDownnum:[data objectForKey:@"downnum"]];
        
        if ([@"success" isEqualToString:[data objectForKey:@"status"]]) {
            
            NSDictionary *book =[data objectForKey:@"book"];
            
            [b setName:[book objectForKey:@"name"]];
            [b setDir:[book objectForKey:@"downnum"]];
            [b setIcon:[book objectForKey:@"icon"]];
            [b setZip:[book objectForKey:@"zip"]];
            [b setBookId:[book objectForKey:@"id"]];
            
            //判断是否有正在下载的
            if ([DBUtils isHasStatusDownloading]) {
                [b setStatus:STATUS_downloading_waitting];
            }else{
                [b setStatus:STATUS_downloading];
                
            }
            
        }
        else if([@"not_found" isEqualToString:[data objectForKey:@"status"]]){
            
            [b setStatus:STATUS_already_enter_code_not_found];
            [self showMessage:@"该手册没找到"];
        }
        else if([@"not_share" isEqualToString:[data objectForKey:@"status"]]){
            
            [b setStatus:STATUS_already_enter_code_not_share];
            [self showMessage:@"该手册尚未发布"];
        }
        else if([@"out_date" isEqualToString:[data objectForKey:@"status"]]){
            
            [b setStatus:STATUS_already_enter_code_out_date];
            [self showMessage:@"该手册已过期"];
        }
        
        BOOL result =[DBUtils updateBook:b];
        if (result) {
            
            [self updateBookCell:b atIndex:[self.gridView getIndexByDownnum:b.downnum]];
            
            if ([STATUS_downloading isEqualToString:[b status]]) {
                [self startDownload:b atIndex:[self.gridView getIndexByDownnum:b.downnum]];
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
- (void)startVerifyHandle{
    
    if (!verifyHandle) {
        verifyHandle =[[VerifyHandle alloc] init];
        [verifyHandle setDelegate:self];
    }
    
    if (![verifyHandle isAction]) {
        [verifyHandle startVerify];
    }
    
    isVerify =[verifyHandle isAction];
}

#pragma -mark VerifyHandleDelegate
- (NSMutableArray *)verifyDataSource:(VerifyHandle *)verifyHandle{
    
    return [DBUtils queryAllBookNotVerify];
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



@end
