//
//  BookCellView.m
//  handbooklite
//
//  Created by bao_wsfk on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookCellView.h"
#import "Config.h"
#import "SSZipArchive.h"
#import "DBUtils.h"
#import "HttpHeader.h"
#import "PushMsg.h"
#import "Util.h"

@implementation BookCellView

@synthesize title =_title;
@synthesize titleLabelBackgroundView =_titleLabelBackgroundView;
@synthesize progressView =_progressView;
@synthesize backgroundView =_backgroundView;
@synthesize networkQueue =_networkQueue;
@synthesize bookTarget =_bookTarget;
@synthesize bookIconView =_bookIconView;
@synthesize deleteBtn =_deleteBtn;
@synthesize downnum =downnum;
@synthesize suspendView =_suspendView;
@synthesize lbdling =_lbdling;

@synthesize pushBtn =_pushBtn;
@synthesize iconNewImgView =_iconNewImgView;
@synthesize isDownloading;


- (void)dealloc{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NOTIFICATION_OF_PUSH_MSG_TO_SHOW
                                                object:nil];
}

- (id)initWithFrame:(CGRect)frame andIndex:(NSUInteger)atIndex
{
  if ((self = [super initWithFrame:frame])) {
    
    
    // Background view
    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 170, 170)];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.1];
    [self.backgroundView setContentMode:UIViewContentModeScaleToFill];
    [self addSubview:self.backgroundView];
    
    //book icon view
    self.bookIconView =[[UIImageView alloc] initWithFrame:CGRectMake(4,4,162,162)];
    self.bookIconView.backgroundColor = [UIColor clearColor];
    [self.bookIconView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:self.bookIconView];
    
    
    // Label
    self.titleLabelBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,179,170,20)];
    //self.titleLabelBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.titleLabelBackgroundView.backgroundColor = [UIColor clearColor];
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0,0,170,20)];
    [self.title setTextAlignment:UITextAlignmentCenter];
    self.title.backgroundColor = [UIColor clearColor];
    self.title.textColor = [UIColor whiteColor];
    [self.title setFont:[UIFont fontWithName:@"Microsoft YaHei" size:11]];
    
    [self.titleLabelBackgroundView addSubview:self.title];
    [self addSubview:self.titleLabelBackgroundView];
    
    //暂停状态
    self.suspendView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suspend.png"]];
    [self.suspendView setFrame:CGRectNull];
    [self.suspendView setHidden:YES];
    [self addSubview:self.suspendView];
    
    //下载中
    self.lbdling =[[UILabel alloc] initWithFrame:CGRectNull];
    [self.lbdling setBackgroundColor:[UIColor clearColor]];
    [self.lbdling setFont:[UIFont fontWithName:@"Microsoft YaHei" size:11]];
    [self.lbdling setText:@"等待中..."];
    [self.lbdling setHidden:YES];
    [self.lbdling setTextColor:[UIColor whiteColor]];
    [self addSubview:self.lbdling];
    
    //推送显示
    UIImage *pushImg =[UIImage imageNamed:@"pushnumber.png"];
    self.pushBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.pushBtn setTag:atIndex];
    [self.pushBtn setFrame:CGRectNull];
    [self.pushBtn setBackgroundImage:pushImg forState:UIControlStateNormal];
    [self.pushBtn.titleLabel setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [self.pushBtn setTitle:@"0" forState:UIControlStateNormal];
    [self.pushBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.pushBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 6, 0)];
    [self.pushBtn setHidden:YES];
    [self.pushBtn setEnabled:NO];
    [self.pushBtn addTarget:self
                     action:@selector(clickPushNumberSelector)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.pushBtn];
    
    //New标签
    self.iconNewImgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new.png"]];
    [self.iconNewImgView setFrame:CGRectNull];
    [self.iconNewImgView setHidden:YES];
    [self addSubview:self.iconNewImgView];
    
    
    //deleteBtn
    UIImage *img =[UIImage imageNamed:@"close_x.png"];
    self.deleteBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setTag:atIndex];
    //[self.deleteBtn setBackgroundColor:[UIColor redColor]];
    [self.deleteBtn addTarget:self action:@selector(clickDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn setFrame:CGRectNull];
    [self.deleteBtn setBackgroundImage:img forState:UIControlStateNormal];
    [self.deleteBtn setHidden:YES];
    [self.deleteBtn setEnabled:NO];
    [self addSubview:self.deleteBtn];
    
    _isHas =NO;//默认不存在
    //[self setBackgroundColor:[UIColor blueColor]];
    
    //注册推送通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNotification:)
                                                 name:NOTIFICATION_OF_PUSH_MSG_TO_SHOW
                                               object:nil];
    
  }
  
  return self;
}

- (void)reloadBookIcon:(BookCellView *)cell iconImage:(UIImage *)iconImage{
  
  CGRect cellFrame =CGRectMake(4,4,162,162);
  
  CGRect backFrame =CGRectMake(0, 0, 170, 170);
  
  cell.bookIconView.frame =[self initBookIconViewFrameWithImgW:iconImage.size.width
                                                          imgH:iconImage.size.height
                                                         cellW:cellFrame.size.width
                                                         cellH:cellFrame.size.height
                                                         cellX:cellFrame.origin.x
                                                         cellY:cellFrame.origin.y];
  
  cell.backgroundView.frame =[self initBookBackFrameWithImgW:iconImage.size.width
                                                        imgH:iconImage.size.height
                                                       cellW:cellFrame.size.width
                                                       cellH:cellFrame.size.height
                                               cellBackFrame:backFrame];
  
    cell.deleteBtn.frame = [self initDeleteBtnWithCellX:cell.bookIconView.frame.origin.x
                                                  cellY:cell.bookIconView.frame.origin.y];
  
  
  cell.suspendView.frame =[self initSuspendViewFrameWithImgW:iconImage.size.width
                                                        imgH:iconImage.size.height
                                                       cellW:cellFrame.size.width
                                                       cellH:cellFrame.size.height
                                               cellBackFrame:backFrame];
  
  cell.lbdling.frame =[self initDlingLableFrameWithImgW:iconImage.size.width
                                                   imgH:iconImage.size.height
                                                  cellW:cellFrame.size.width
                                                  cellH:cellFrame.size.height
                                          cellBackFrame:backFrame];
  
    cell.pushBtn.frame =[self initPushBtnWithCellW:cell.bookIconView.frame.size.width
                                             cellH:cell.bookIconView.frame.size.height
                                             cellX:cell.bookIconView.frame.origin.x
                                             cellY:cell.bookIconView.frame.origin.y];
  
  cell.iconNewImgView.frame =[self initNewViewFrameWithImgW:iconImage.size.width
                                                       imgH:iconImage.size.height
                                                      cellW:cellFrame.size.width
                                                      cellH:cellFrame.size.height
                                                      cellX:cellFrame.origin.x
                                                      cellY:cellFrame.origin.y];
  
  [cell.bookIconView setImage:iconImage];
  
  if (self.progressView) {
    
    CGRect frame =cell.bookIconView.frame;
    
    [self.progressView setFrame:CGRectMake(frame.origin.x, 162,frame.size.width, 10)];
  }
  
}

//获取当前手册的iconView  Frame
- (CGRect)initBookIconViewFrameWithImgW:(double)iw imgH:(double)ih cellW:(double)cw cellH:(double)ch cellX:(CGFloat)x cellY:(CGFloat)y{
  
  if (iw >ih) {
    double nifh = ch * ih / iw;
    double difh = ch - nifh;
    return CGRectMake(x , y + difh , cw, ch - difh);
    
  }else{
    
    double nifw = cw * iw / ih;
    double difw = cw - nifw;
    
    return CGRectMake(x + difw / 2 , y , cw- difw, ch);
  }
}

//获取手册背景  Frame
- (CGRect)initBookBackFrameWithImgW:(double)iw imgH:(double)ih cellW:(double)cw cellH:(double)ch cellBackFrame:(CGRect)frame{
  
  if (iw >ih) {
    double nifh = ch * ih / iw;
    double difh = ch - nifh;
    return CGRectMake(frame.origin.x  , frame.origin.y + difh, frame.size.width, frame.size.height - difh);
    
  }else{
    
    double nifw = cw * iw / ih;
    double difw = cw - nifw;
    
    return CGRectMake(frame.origin.x + difw / 2 , frame.origin.y, frame.size.width - difw, frame.size.height);
  }
}

//获取删除按钮位置 Frame
- (CGRect)initDeleteBtnWithCellX:(CGFloat)x cellY:(CGFloat)y{
    
    return CGRectMake(x-21,y-21,42, 42);
}

//获取暂停图标位置 Frame
- (CGRect)initSuspendViewFrameWithImgW:(double)iw imgH:(double)ih cellW:(double)cw cellH:(double)ch cellBackFrame:(CGRect)frame{
  
  if (iw >ih) {
    double nifh = ch * ih / iw;
    double difh = ch - nifh;
    return CGRectMake((frame.size.width/2-8)  , (frame.origin.y + difh)-20, 8, 10);
    
  }else{
    
    return CGRectMake((frame.size.width/2-8) , frame.origin.y-10, 8, 10);
  }
}

//获取下载中lable Frame
- (CGRect)initDlingLableFrameWithImgW:(double)iw imgH:(double)ih cellW:(double)cw cellH:(double)ch cellBackFrame:(CGRect)frame{
  
    if (iw >ih) {
        double nifh = ch * ih / iw;
        double difh = ch - nifh;
        return CGRectMake((frame.size.width/2-25)  , (frame.origin.y + difh)-15, 50, 15);
        
    }else{
        
        return CGRectMake((frame.size.width/2-25) , frame.origin.y-15, 50, 15);
    }
}

//获取推送数字按钮位置 Frame
- (CGRect)initPushBtnWithCellW:(double)cw cellH:(double)ch cellX:(CGFloat)x cellY:(CGFloat)y{
    
    return CGRectMake(x+cw-14,y -14,30, 31);
}

//获取当前手册的newView  Frame
- (CGRect)initNewViewFrameWithImgW:(double)iw imgH:(double)ih cellW:(double)cw cellH:(double)ch cellX:(CGFloat)x cellY:(CGFloat)y{
  
  if (iw >ih) {
    double nifh = ch * ih / iw;
    double difh = ch - nifh;
    return CGRectMake(cw-43 , (ch - difh)-5, 45, 45);
    
  }else{
    
    double nifw = cw * iw / ih;
    double difw = cw - nifw;
    
    return CGRectMake((cw- difw)-25 , ch-40 , 45, 45);
  }
}


- (void)startDownload:(NSString *)iconUrlString zipUrlString:(NSString *)zipUrlString saveDir:(NSString *)saveDir bookName:(NSString *)bookName{
  
  [self startProgress];
  isCancel =NO;
  [self.lbdling setHidden:NO];
  [self.lbdling setText:@"下载中..."];
  [self.suspendView setHidden:YES];
  [self initNetworkQueueByProgress];
    
    isDownloading =YES;
  
  NSString *httpHeader = [[HttpHeader shareInstance] httpHeader];
  
  
  iconUrlString =[self parseUrl:iconUrlString withHttpHeader:httpHeader];
  //下载icon
  ASIHTTPRequest *request_icon =[ASIHTTPRequest
                                 requestWithURL:
                                 [NSURL URLWithString:iconUrlString]];
  
  
  NSString *saveIconPath =[CACHE_PATH stringByAppendingPathComponent:@"books/icons"];
  [self createPath:saveIconPath];
  [request_icon setDownloadDestinationPath:[saveIconPath stringByAppendingPathComponent:[iconUrlString lastPathComponent]]];
  
  
  NSString *fileTmp_icon =[iconUrlString lastPathComponent];
  [request_icon setTemporaryFileDownloadPath:[TMP_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileTmp_icon]]];
  [request_icon setAllowResumeForFileDownloads:YES];
  
  NSMutableDictionary *request_icon_info =[[NSMutableDictionary alloc]init];
  [request_icon_info setObject:@"download_icon" forKey:@"name"];
  [request_icon_info setObject:saveDir forKey:@"saveDir"];
  [request_icon_info setObject:bookName forKey:@"bookName"];
  [request_icon setUserInfo:request_icon_info];
  [request_icon setTimeOutSeconds:30];
  [request_icon setShouldAttemptPersistentConnection:NO];
  [_networkQueue addOperation:request_icon];
  
    zipUrlString =[self parseUrl:zipUrlString withHttpHeader:httpHeader];
    
  //下载zip
  ASIHTTPRequest *request_zip =[ASIHTTPRequest
                                requestWithURL:
                                [NSURL URLWithString:zipUrlString]];
  
  NSString *saveZipPath =[CACHE_PATH stringByAppendingPathComponent:@"books/zips"];
  [self createPath:saveZipPath];
  [request_zip setDownloadDestinationPath:[saveZipPath stringByAppendingPathComponent:[zipUrlString lastPathComponent]]];
  
  NSString *fileTmp =[zipUrlString lastPathComponent];
  [request_zip setTemporaryFileDownloadPath:[TMP_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileTmp]]];
  [request_zip setAllowResumeForFileDownloads:YES];
  
  NSMutableDictionary *request_zip_info =[[NSMutableDictionary alloc]init];
  [request_zip_info setObject:@"download_zip" forKey:@"name"];
  [request_zip_info setObject:saveDir forKey:@"saveDir"];
  [request_zip_info setObject:bookName forKey:@"bookName"];
  [request_zip setUserInfo:request_zip_info];
  [request_zip setTimeOutSeconds:60];
  [request_zip setShouldAttemptPersistentConnection:NO];
  [_networkQueue addOperation:request_zip];
  [_networkQueue go];
  
}

- (NSString *)parseUrl:(NSString *) url withHttpHeader:(NSString *)httpHeader{
    if ([Util isUrl:url]) {
        return url;
    }else{
        return [NSString stringWithFormat:@"%@%@",httpHeader,url];
    }
}



- (void)startProgress{
  //progress
  CGRect iconFrame =self.bookIconView.frame;
  self.progressView =[[UIProgressView alloc] initWithFrame:CGRectMake(iconFrame.origin.x, 162,iconFrame.size.width, 10)];
  //Layout progressView
  [self.progressView setProgress:0];
  [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
  [self.progressView setProgressTintColor:[UIColor greenColor]];
  [self.progressView setTrackTintColor:[UIColor whiteColor]];
  [self addSubview:self.progressView];
}

- (void)endProgress{
  
  if (self.progressView) {
    [self.progressView removeFromSuperview];
    self.progressView =nil;
  }
}


- (void)showDeleteBtn:(BOOL)isEdit{
  
  [self.deleteBtn setHidden:!isEdit];
  [self.deleteBtn setEnabled:isEdit];
}

- (void)clickDelete:(id)sender{
  
  SEL deleteSelector = @selector(cellWasDelete:);
  //点击删除按钮
  if ([gridView respondsToSelector:deleteSelector]) {
    [gridView performSelector:deleteSelector withObject:self];
  }
  
}

//点击推送数字
- (void)clickPushNumberSelector{
  
  SEL pushNumberSelector = @selector(cellWasClickPushNumberShow:);
  
  if ([gridView respondsToSelector:pushNumberSelector]) {
    
    [gridView performSelector:pushNumberSelector withObject:self];
  }
}

- (void)initNetworkQueueByProgress{
  if (!_networkQueue) {
    _networkQueue =[[ASINetworkQueue alloc] init];
  }
  [_networkQueue reset];
  [_networkQueue setDownloadProgressDelegate:self.progressView];
  [_networkQueue setShowAccurateProgress:YES];
  [_networkQueue setQueueDidFinishSelector:@selector(didQueueFinished:)];
  [_networkQueue setRequestDidFailSelector:@selector(didDownloadFailed:)];
  [_networkQueue setRequestDidFinishSelector:@selector(didDownloadFinished:)];
  [_networkQueue setShouldCancelAllRequestsOnFailure:YES];
  [_networkQueue setMaxConcurrentOperationCount:2];
  [_networkQueue setDelegate:self];
}


//队列下载完成
- (void)didQueueFinished:(ASINetworkQueue *)queue{
  
  [_networkQueue reset];
  _networkQueue =nil;
}

//下载失败
- (void)didDownloadFailed:(ASIHTTPRequest *)request{
    
    CCLog(@"download  failed:%@",request.error);
    
    NSDictionary *userinfo =[request userInfo];
    
    if ([@"download_zip" isEqualToString:[userinfo objectForKey:@"name"]]) {
        
        isDownloading =NO;
        
        SEL downloadFinishedSelector = @selector(cellWasDownloadFinished:error:);
        
        NSString *error =@"";
        if (!isCancel) {
            
            error =@"failed";
            //更新图标
            [self reloadBookIcon:self iconImage:[UIImage imageNamed:@"code_error.png"]];
            
            [self endProgress];
            [self.lbdling setHidden:YES];
            [self.suspendView setHidden:YES];
            [self.iconNewImgView setHidden:YES];
            [self.backgroundView setBackgroundColor:[UIColor clearColor]];
        }else{
            
            error =@"cancel";
            
            [self endProgress];
            [self.lbdling setHidden:YES];
            [self.suspendView setHidden:NO];
            [self.iconNewImgView setHidden:NO];
        }
        if ([gridView respondsToSelector:downloadFinishedSelector]) {
            [gridView performSelector:downloadFinishedSelector withObject:self withObject:error];
        }
    }
    
}
//下载成功
- (void)didDownloadFinished:(ASIHTTPRequest *)request{
  NSDictionary *userinfo =[request userInfo];
  
  if ([@"download_icon" isEqualToString:[userinfo objectForKey:@"name"]]) {
    
    
    if (request.responseStatusCode ==200) {
      
      NSString *iconSavePath =[CACHE_PATH stringByAppendingPathComponent:@"books/icons"];
      
      iconSavePath = [iconSavePath stringByAppendingPathComponent:[request.downloadDestinationPath lastPathComponent]];
      NSFileManager *fm =[NSFileManager defaultManager];
      
      [fm copyItemAtPath:request.downloadDestinationPath toPath:iconSavePath error:nil];
      
      [self reloadBookIcon:self iconImage:[UIImage imageWithContentsOfFile:request.downloadDestinationPath]];
        
        self.backgroundView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.1];
      
      [self.iconNewImgView setHidden:NO];
      
      NSString *bookName =[userinfo objectForKey:@"bookName"];
      
      [self.title setText:bookName];
      
    }
    
    
  }
  if ([@"download_zip" isEqualToString:[userinfo objectForKey:@"name"]]) {
    
    NSString *saveDir =[userinfo objectForKey:@"saveDir"];
    
    //解压zip 解压后的文件夹名称以下载码命名
    NSString *toBookPath =[CACHE_PATH stringByAppendingPathComponent:
                           [NSString stringWithFormat:@"books/%@",saveDir]];
    
    BOOL isOk =[SSZipArchive unzipFileAtPath:request.downloadDestinationPath
                               toDestination:toBookPath
                                   overwrite:YES
                                    password:nil
                                       error:nil];
    if (!isOk) {
      CCLog(@"-------%@解压失败",request.downloadDestinationPath);
    }
    
    //删除zip
    NSFileManager *fm =[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:request.downloadDestinationPath]) {
      [fm removeItemAtPath:request.downloadDestinationPath error:nil];
    }
    
    //下载完成
    SEL downloadFinishedSelector = @selector(cellWasDownloadFinished:error:);
    if ([gridView respondsToSelector:downloadFinishedSelector]) {
      [gridView performSelector:downloadFinishedSelector withObject:self withObject:@"null"];
    }
    
    [self finishedView];
      
      isDownloading =NO;
    
  }
}

- (void)finishedView{
  
  [self endProgress];
  [self.lbdling setHidden:YES];
  [self.suspendView setHidden:YES];
}

- (void)cancelDownload{
  
  isCancel =YES;
  
  if (_networkQueue) {
    [self.networkQueue cancelAllOperations];
  }
  
  [self endProgress];
  [self.suspendView setHidden:NO];
  [self.lbdling setHidden:YES];
}


//接收推送的通知
- (void)receivePushNotification:(NSNotification *)notif{
  
  NSDictionary *pushData =[notif object];
  NSString *msg =[pushData objectForKey:@"message"];
  NSString *download_code =[pushData objectForKey:@"downnum"];
  
  if ([download_code isEqualToString:self.downnum]) {
    
    PushMsg *pm =[[PushMsg alloc] init];
    
    [pm setDownnum:download_code];
    [pm setMsg:msg];
    
    [DBUtils insertPushMsg:pm];
    
    
    //显示数字
    NSUInteger pushNumber =[DBUtils queryCountOfPushMsgByDownnum:download_code];
    
    [self showPushNumber:pushNumber];
  }
}

- (void)showPushNumber:(NSUInteger)number{
    
    
    if (![self isHasBookLocation:downnum]) {
        
        return;
    }
    
    BOOL isShow =NO;
    
    if (number >0) {
        
        [self.pushBtn setTitle:[NSString stringWithFormat:@"%i",number] forState:UIControlStateNormal];
        isShow =YES;
        
    }else{
        isShow =NO;
        
    }
    
    [self.pushBtn setHidden:!isShow];
    [self.pushBtn setEnabled:isShow];
    
}

//判断本地手册是否存在
- (BOOL)isHasBookLocation:(NSString *)downnumber{
    
    
    NSString *cacheBookPath =[CACHE_PATH stringByAppendingPathComponent:@"books"];
    
    NSString *bookDocPath = [cacheBookPath stringByAppendingPathComponent:downnumber];
    
    NSFileManager *fm =[NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:bookDocPath] &&
        [fm fileExistsAtPath:[bookDocPath stringByAppendingPathComponent:@"book.json"]])
    {
        return YES;
    }
    return NO;
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

@end
