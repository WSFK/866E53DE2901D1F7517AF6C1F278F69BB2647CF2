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

@implementation BookCellView

@synthesize title =_title;
@synthesize titleLabelBackgroundView =_titleLabelBackgroundView;
@synthesize progressView =_progressView;
@synthesize backgroundView =_backgroundView;
@synthesize networkQueue =_networkQueue;
@synthesize bookTarget =_bookTarget;
@synthesize bookIconView =_bookIconView;
@synthesize deleteBtn =_deleteBtn;
@synthesize bookId;


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
        
        UIImage *img =[UIImage imageNamed:@"close_x.png"];
        self.deleteBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteBtn setTag:atIndex];
        //[self.deleteBtn setBackgroundColor:[UIColor redColor]];
        [self.deleteBtn addTarget:self action:@selector(endDelete:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn setFrame:CGRectNull];
        [self.deleteBtn setBackgroundImage:img forState:UIControlStateNormal];
        [self.deleteBtn setHidden:YES];
        [self.deleteBtn setEnabled:NO];
        [self addSubview:self.deleteBtn];
        
        _isHas =NO;//默认不存在
        //[self setBackgroundColor:[UIColor blueColor]];
        
    }
    
    return self;
}

- (void)startProgress{
    //progress
    self.progressView =[[UIProgressView alloc] initWithFrame:CGRectNull];
    //Layout progressView
    self.progressView.frame =CGRectMake(0, 168,144, 10);
    [self.progressView setProgress:0];
    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setProgressTintColor:[UIColor greenColor]];
    [self.progressView setTrackTintColor:[UIColor whiteColor]];
    [self addSubview:self.progressView];
}

- (void)endProgress{
    [self.progressView removeFromSuperview];
}

//取消编辑
- (void)cancelEditBtn{
    [self.deleteBtn setHidden:YES];
    [self.deleteBtn setEnabled:NO];
    
}

- (void)startDeleteIndex:(int)indextmp andTarget:(BookShelfViewController *)target{
    self.bookTarget =target;
    
    [self.deleteBtn setHidden:!self.deleteBtn.isHidden];
    [self.deleteBtn setEnabled:!self.deleteBtn.isHidden];
}

- (void)endDelete:(id)sender{

    Book *book =[DBUtils queryBookById:bookId];
    if(book ==nil){
        return;
    }
    
    NSString *bookPath =[CACHE_PATH stringByAppendingFormat:@"/books/%@",[book dir]];
    NSString *sccreeshotsPath =_bookTarget.defaultScreeshotsPath;
    sccreeshotsPath =[sccreeshotsPath stringByAppendingFormat:@"/%@",[book downnum]];
    
    NSString *iconPath =[CACHE_PATH stringByAppendingFormat:@"/books/icons/%@",[book getIconName]];
    
    
    if ([DBUtils deleteBookById:bookId]) {
        //删除缓存图片
        NSFileManager *fm =[NSFileManager defaultManager];
        if ([fm fileExistsAtPath:sccreeshotsPath])
        {
            BOOL result =[fm removeItemAtPath:sccreeshotsPath error:nil];
            if (!result) {
                CCLog(@"remove file failed：%@",sccreeshotsPath);
            }
            
        }
        if([fm fileExistsAtPath:bookPath])
        {
            BOOL result =[fm removeItemAtPath:bookPath error:nil];
            if(!result){
                CCLog(@"remove file failed：%@",bookPath);
            }
        }
        
        if ([fm fileExistsAtPath:iconPath]) {
            BOOL result =[fm removeItemAtPath:iconPath error:nil];
            if (!result) {
                CCLog(@"remove file failed：%@",iconPath);
            }
        }
    }
    [_bookTarget updateBooks];
    [_bookTarget.gridView reloadData];
    
}

- (void)initNetworkQueueByProgress:(UIProgressView *)progress{
    if (!_networkQueue) {
        _networkQueue =[[ASINetworkQueue alloc] init];
    }
    [_networkQueue reset];
    [_networkQueue setDownloadProgressDelegate:progress];
    [_networkQueue setShowAccurateProgress:YES];
    [_networkQueue setQueueDidFinishSelector:@selector(didQueueFinished:)];
    [_networkQueue setRequestDidFailSelector:@selector(didDownloadFailed:)];
    [_networkQueue setRequestDidFinishSelector:@selector(didDownloadFinished:)];
    [_networkQueue setMaxConcurrentOperationCount:2];
    [_networkQueue setDelegate:self];
}

- (void)downloadBookDic:(NSDictionary *)bookDic target:(BookShelfViewController *)target{
    
    self.bookTarget =target;
    [self startProgress];
    [self setIsClick:NO];
    [self initNetworkQueueByProgress:_progressView];
    //下载icon
    ASIHTTPRequest *request_icon =[ASIHTTPRequest 
                                   requestWithURL:
                                   [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                         BASE_URL,[bookDic objectForKey:@"icon"]]]];
    //ASIHTTPRequest *request_icon =[ASIHTTPRequest 
      //                             requestWithURL:
        //                           [NSURL URLWithString:[bookDic objectForKey:@"icon"]]];
    
    NSString *saveIconPath =[CACHE_PATH stringByAppendingPathComponent:@"books/icons"];
    [self createPath:saveIconPath];
    [request_icon setDownloadDestinationPath:[saveIconPath stringByAppendingPathComponent:
                                              [[bookDic objectForKey:@"icon"]
                                               lastPathComponent]]];
    NSMutableDictionary *request_icon_info =[[NSMutableDictionary alloc]init];
    [request_icon_info setObject:@"download_icon" forKey:@"name"];
    [request_icon_info setObject:bookDic forKey:@"book"];
    [request_icon setUserInfo:request_icon_info];
    [request_icon setTimeOutSeconds:30];
    [request_icon setShouldAttemptPersistentConnection:NO];
    [_networkQueue addOperation:request_icon];
    
    //下载zip
    ASIHTTPRequest *request_zip =[ASIHTTPRequest 
                                  requestWithURL:
                                  [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                        BASE_URL,[bookDic objectForKey:@"zip"]]]];
    //ASIHTTPRequest *request_zip =[ASIHTTPRequest 
      //                            requestWithURL:
        //                          [NSURL URLWithString:[bookDic objectForKey:@"zip"]]];
    
    NSString *saveZipPath =[CACHE_PATH stringByAppendingPathComponent:@"books/zips"];
    [self createPath:saveZipPath];
    [request_zip setDownloadDestinationPath:[saveZipPath stringByAppendingPathComponent:
                                             [[bookDic objectForKey:@"zip"]
                                              lastPathComponent]]];
    
    NSString *fileTmp =[[bookDic objectForKey:@"zip"] lastPathComponent];
    [request_zip setTemporaryFileDownloadPath:[TMP_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileTmp]]];
    [request_zip setAllowResumeForFileDownloads:YES];
    NSMutableDictionary *request_zip_info =[[NSMutableDictionary alloc]init];
    [request_zip_info setObject:@"download_zip" forKey:@"name"];
    [request_zip_info setObject:bookDic forKey:@"book"];
    [request_zip setUserInfo:request_zip_info];
    [request_zip setTimeOutSeconds:60];
    [request_zip setShouldAttemptPersistentConnection:NO];
    [_networkQueue addOperation:request_zip];
    [_networkQueue go];
}

- (void)toUpdateListView{
    [self endProgress];
    [self setIsClick:YES];
    [_bookTarget updateBooks];
    [_bookTarget.gridView reloadData];
}

//队列下载完成
- (void)didQueueFinished:(ASINetworkQueue *)queue{
    CCLog(@"-------queue finished");
    [_networkQueue reset];
    _networkQueue =nil;
    [self performSelector:@selector(toUpdateListView) withObject:nil afterDelay:0.3];
}

//下载失败
- (void)didDownloadFailed:(ASIHTTPRequest *)request{
    NSDictionary *userinfo =[request userInfo];
    
    if ([@"download_icon" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------icon download Failed");
    }
    if ([@"download_zip" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------zip download Failed");
    }
}
//下载成功
- (void)didDownloadFinished:(ASIHTTPRequest *)request{
    NSDictionary *userinfo =[request userInfo];
    
    if ([@"download_icon" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------icon download finished");
        NSDictionary *book =[userinfo objectForKey:@"book"];
        self.bookIconView.backgroundColor = [UIColor colorWithPatternImage:
                                             [UIImage imageWithContentsOfFile:request.downloadDestinationPath]];
        [self.title setText:[book objectForKey:@"name"]];
    }
    if ([@"download_zip" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------zip download finished");
        
        NSDictionary *bookDic =[userinfo objectForKey:@"book"];
        
        Book *book =[[Book alloc] init];
        [book setName:[bookDic objectForKey:@"name"]];
        [book setDownnum:[bookDic objectForKey:@"downnum"]];
        [book setDir:[bookDic objectForKey:@"downnum"]];
        [book setZip:[bookDic objectForKey:@"zip"]];
        [book setIcon:[bookDic objectForKey:@"icon"]];
        [DBUtils insertBook:book];
        
        
        //解压zip 解压后的文件夹名称以下载码命名
        NSString *toBookPath =[CACHE_PATH stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"books/%@",
                                [book dir]]];
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
    }
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
