//
//  DownloadListCell.m
//  handbooklite
//
//  Created by bao_wsfk on 12-12-11.
//
//

#import "DownloadListCell.h"
#import "HttpHeader.h"
#import "Config.h"
#import "SSZipArchive.h"
#import "Book.h"
#import "DBUtils.h"
#import "NetWorkCheck.h"

#define ALERT_3G_TAG 10001

@implementation DownloadListCell

@synthesize bookTitleView,bookDownnumView,saveDateView,downloadBtn,delegate,tempId,isDownloading;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        bookTitleView = [[UILabel alloc] initWithFrame:CGRectMake(5, 20, 135, 29)];
        [bookTitleView setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
        [bookTitleView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:bookTitleView];
        
        bookDownnumView =[[UILabel alloc] initWithFrame:CGRectMake(145, 7, 100, 25)];
        [bookDownnumView setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
        [bookDownnumView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:bookDownnumView];
        
        saveDateView =[[UILabel alloc] initWithFrame:CGRectMake(145, 32, 100, 25)];
        [saveDateView setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
        [saveDateView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:saveDateView];
        
        downloadBtn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [downloadBtn setFrame:CGRectMake(278, 20, 60, 31)];
        [downloadBtn setTitle:@"下 载" forState:UIControlStateNormal];
        [downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [downloadBtn.titleLabel setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
        [downloadBtn addTarget:self action:@selector(clickDownload)
              forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:downloadBtn];
        
        progress =[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [progress setFrame:CGRectMake(260, 55, 80, 10)];
        [progress setProgress:0.0f];
        [progress setProgressViewStyle:UIProgressViewStyleDefault];
        [progress setProgressTintColor:[UIColor greenColor]];
        [progress setTrackTintColor:[UIColor whiteColor]];
        [self.contentView addSubview:progress];
        [progress setHidden:YES];
        
        isDownloading =NO;
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)clickDownload{
    
    isStopDownload =NO;
    
    //点击暂停
    if (isDownloading) {
        isStopDownload =YES;
        [self stopDownload];
        return;
    }
    
    //检查是否为3g
    if ([NetWorkCheck checkIs3G]) {
        [self ShowNetWorkWarn];

    }else{
        //隐藏下载按钮
        [downloadBtn setTitle:@"暂 停" forState:UIControlStateNormal];
        [progress setHidden:NO];
        isDownloading =YES;
        [self requestDataFromServer];
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

- (void)requestDataFromServer{
    NSString *downnum =[bookDownnumView text]==nil?@"":[bookDownnumView text];
    
    //发送请求
    myRequest = [[MyHttpRequest alloc] init];
    [myRequest setDelegate:self];
    [myRequest sendPostValue:downnum key:@"downloadnum" forUrl:DOWNLOAD_URL];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == ALERT_3G_TAG && buttonIndex == 1) {
        [self requestDataFromServer];
    }
}


#pragma -mark MyHttpRequestDelegate
- (void)didRequestFailedWidthError:(NSString *)error{
    //下载失败
    if ([delegate respondsToSelector:@selector(didDownloadBookFailedWidthError:)]) {
        [delegate performSelector:@selector(didDownloadBookFailedWidthError:) withObject:error];
    }
    [downloadBtn setEnabled:YES];
    [downloadBtn setTitle:@"下 载" forState:UIControlStateNormal];
    [progress setHidden:YES];
    isDownloading =NO;
    
}

- (void)didRequestFinishedWidthResponseData:(NSDictionary *)responseData{
    
    NSString *httpHeader =[responseData objectForKey:@"httpImage"];
    NSDictionary *data =[responseData objectForKey:@"handbookMsg"];;
                           
    //更新httpHeader
    [[HttpHeader shareInstance] updateHttpHeader:httpHeader];
    
    NSDictionary *bookDic =[data objectForKey:@"book"];
    paramBook =[[Book alloc] init];
    [paramBook setName:[bookDic objectForKey:@"name"]];
    [paramBook setDownnum:[bookDic objectForKey:@"downnum"]];
    [paramBook setDir:[bookDic objectForKey:@"downnum"]];
    [paramBook setZip:[bookDic objectForKey:@"zip"]];
    [paramBook setIcon:[bookDic objectForKey:@"icon"]];
    [paramBook setBookId:[bookDic objectForKey:@"id"]];
    
    bookDic =nil;
    data =nil;
    
    [self startDownload];
    
}

- (void)startDownload{
    
    if (!networkQueue) {
        networkQueue =[[ASINetworkQueue alloc] init];
    }
    [networkQueue reset];
    [networkQueue setDownloadProgressDelegate:progress];
    [networkQueue setShowAccurateProgress:YES];
    [networkQueue setQueueDidFinishSelector:@selector(didQueueFinished:)];
    [networkQueue setRequestDidFailSelector:@selector(didDownloadFailed:)];
    [networkQueue setRequestDidFinishSelector:@selector(didDownloadFinished:)];
    [networkQueue setMaxConcurrentOperationCount:2];
    [networkQueue setDelegate:self];
    
    NSString *httpHeader = [[HttpHeader shareInstance] httpHeader];
    
    NSString *iconUrl = [NSString stringWithFormat:@"%@%@",httpHeader,[paramBook icon]];
    NSString *zipUrl = [NSString stringWithFormat:@"%@%@",httpHeader,[paramBook zip]];
    //下载icon
    ASIHTTPRequest *request_icon =[ASIHTTPRequest
                                   requestWithURL:
                                   [NSURL URLWithString:iconUrl]];
    
    NSString *saveIconPath =[CACHE_PATH stringByAppendingPathComponent:@"books/icons"];
    [self createPath:saveIconPath];
    [request_icon setDownloadDestinationPath:[saveIconPath stringByAppendingPathComponent:[iconUrl lastPathComponent]]];
    
    NSString *fileTmp_icon =[iconUrl lastPathComponent];
    [request_icon setTemporaryFileDownloadPath:[TMP_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileTmp_icon]]];
    [request_icon setAllowResumeForFileDownloads:YES];
    
    NSMutableDictionary *request_icon_info =[[NSMutableDictionary alloc]init];
    [request_icon_info setObject:@"download_icon" forKey:@"name"];
    [request_icon setUserInfo:request_icon_info];
    [request_icon setTimeOutSeconds:30];
    [request_icon setShouldAttemptPersistentConnection:YES];
    [networkQueue addOperation:request_icon];
    
    //下载zip
    ASIHTTPRequest *request_zip =[ASIHTTPRequest
                                  requestWithURL:
                                  [NSURL URLWithString:zipUrl]];
    
    NSString *saveZipPath =[CACHE_PATH stringByAppendingPathComponent:@"books/zips"];
    [self createPath:saveZipPath];
    [request_zip setDownloadDestinationPath:[saveZipPath stringByAppendingPathComponent:[zipUrl lastPathComponent]]];
    NSString *fileTmp =[zipUrl lastPathComponent];
    [request_zip setTemporaryFileDownloadPath:[TMP_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileTmp]]];
    [request_zip setAllowResumeForFileDownloads:YES];
    NSMutableDictionary *request_zip_info =[[NSMutableDictionary alloc]init];
    [request_zip_info setObject:@"download_zip" forKey:@"name"];
    [request_zip setUserInfo:request_zip_info];
    [request_zip setTimeOutSeconds:60];
    [request_zip setShouldAttemptPersistentConnection:YES];
    [networkQueue addOperation:request_zip];
    [networkQueue go];
}


//队列下载完成
- (void)didQueueFinished:(ASINetworkQueue *)queue{
    [networkQueue reset];
    networkQueue =nil;
    
    [downloadBtn setEnabled:YES];
    [downloadBtn setTitle:@"下 载" forState:UIControlStateNormal];
    [progress setHidden:YES];
    isDownloading =NO;
    
}

//下载失败
- (void)didDownloadFailed:(ASIHTTPRequest *)request{
    NSDictionary *userinfo =[request userInfo];
    
    if ([@"download_icon" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------icon download Failed");
    }
    if ([@"download_zip" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------zip download Failed:%@",[request error]);
        
        //下载失败
        if ([delegate respondsToSelector:@selector(didDownloadBookFailedWidthError:)]) {
            if (!isStopDownload) {
                [delegate performSelector:@selector(didDownloadBookFailedWidthError:) withObject:@"下载失败！"];
            }
            
        }
    }
}
//下载成功
- (void)didDownloadFinished:(ASIHTTPRequest *)request{
    NSDictionary *userinfo =[request userInfo];
    
    if ([@"download_icon" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------icon download finished");
    }
    if ([@"download_zip" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------zip download finished");
        
        
        //解压zip 解压后的文件夹名称以下载码命名
        NSString *toBookPath =[CACHE_PATH stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"books/%@",[paramBook downnum]]];
        
        BOOL isOk =[SSZipArchive unzipFileAtPath:request.downloadDestinationPath
                                   toDestination:toBookPath
                                       overwrite:YES
                                        password:nil
                                           error:nil];
        
        
        //删除zip
        NSFileManager *fm =[NSFileManager defaultManager];
        if ([fm fileExistsAtPath:request.downloadDestinationPath]) {
            [fm removeItemAtPath:request.downloadDestinationPath error:nil];
        }
        
        if (!isOk) {
            CCLog(@"-------%@解压失败",request.downloadDestinationPath);
        }else{
            
            //判断book表中是否存在
            if (![DBUtils isExistBookByDownnum:[paramBook downnum]]) {
                [DBUtils insertBook:paramBook];
            }
            //删除temp表中数据
            [DBUtils deleteTempById:tempId];
            
            if ([delegate respondsToSelector:@selector(didDownloadBookSuccess)]) {
                [delegate performSelector:@selector(didDownloadBookSuccess)];
            }
        }
        
        
    }
}

- (void)stopDownload{
    if (networkQueue) {
        [networkQueue cancelAllOperations];
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
