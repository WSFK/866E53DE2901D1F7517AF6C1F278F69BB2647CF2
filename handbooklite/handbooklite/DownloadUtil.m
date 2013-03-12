//
//  DownloadUtil.m
//  handbooklite
//
//  Created by bao_wsfk on 12-10-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DownloadUtil.h"
#import "Config.h"

#import "SSZipArchive.h"
#import "Book.h"
#import "DBUtils.h"
#import "HttpHeader.h"

@implementation DownloadUtil

@synthesize networkQueue;
@synthesize delegate;

- (void)startDownloadBookDic:(NSDictionary *)bookDic progressView:(UIProgressView *)progressView
{
    
    CCLog(@"--------\n-------\n----:bookDic:%@",bookDic);
    if (!networkQueue) {
        networkQueue =[[ASINetworkQueue alloc] init];
    }
    [networkQueue reset];
    [networkQueue setDownloadProgressDelegate:progressView];
    [networkQueue setShowAccurateProgress:YES];
    [networkQueue setQueueDidFinishSelector:@selector(didQueueFinished:)];
    [networkQueue setRequestDidFailSelector:@selector(didDownloadFailed:)];
    [networkQueue setRequestDidFinishSelector:@selector(didDownloadFinished:)];
    [networkQueue setMaxConcurrentOperationCount:2];
    [networkQueue setDelegate:self];
    
    NSString *httpHeader = [[HttpHeader shareInstance] httpHeader];
    //下载icon
    ASIHTTPRequest *request_icon =[ASIHTTPRequest 
                                   requestWithURL:
                                   [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                         httpHeader,[bookDic objectForKey:@"icon"]]]];
    
    NSString *saveIconPath =[CACHE_PATH stringByAppendingPathComponent:@"books/icons"];
    [self createPath:saveIconPath];
    [request_icon setDownloadDestinationPath:[saveIconPath stringByAppendingPathComponent:
                                              [[bookDic objectForKey:@"icon"]
                                               lastPathComponent]]];
    
    NSString *fileTmp_icon =[[bookDic objectForKey:@"icon"] lastPathComponent];
    [request_icon setTemporaryFileDownloadPath:[TMP_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileTmp_icon]]];
    [request_icon setAllowResumeForFileDownloads:YES];
    
    NSMutableDictionary *request_icon_info =[[NSMutableDictionary alloc]init];
    [request_icon_info setObject:@"download_icon" forKey:@"name"];
    [request_icon_info setObject:bookDic forKey:@"book"];
    [request_icon setUserInfo:request_icon_info];
    [request_icon setTimeOutSeconds:30];
    [request_icon setShouldAttemptPersistentConnection:YES];
    [networkQueue addOperation:request_icon];
    
    //下载zip
    ASIHTTPRequest *request_zip =[ASIHTTPRequest 
                                  requestWithURL:
                                  [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                        httpHeader,[bookDic objectForKey:@"zip"]]]];
    
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
    [request_zip setShouldAttemptPersistentConnection:YES];
    [networkQueue addOperation:request_zip];
    [networkQueue go];
}

//队列下载完成
- (void)didQueueFinished:(ASINetworkQueue *)queue{
    [networkQueue reset];
    networkQueue =nil;
    if ([delegate respondsToSelector:@selector(didQueueFinished)]) {
        [delegate performSelector:@selector(didQueueFinished)];
    }
}

//下载失败
- (void)didDownloadFailed:(ASIHTTPRequest *)request{
    NSDictionary *userinfo =[request userInfo];
    
    if ([@"download_icon" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------icon download Failed");
    }
    if ([@"download_zip" isEqualToString:[userinfo objectForKey:@"name"]]) {
        CCLog(@"-------zip download Failed:%@",[request error]);
        if ([delegate respondsToSelector:@selector(didFailed)]) {
            [delegate performSelector:@selector(didFailed)];
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
        
        NSDictionary *bookDic =[userinfo objectForKey:@"book"];
        
        Book *book = [[Book alloc] init];
        [book setName:[bookDic objectForKey:@"name"]];
        [book setDownnum:[bookDic objectForKey:@"downnum"]];
        [book setDir:[bookDic objectForKey:@"downnum"]];
        [book setIcon:[bookDic objectForKey:@"icon"]];
        [book setZip:[bookDic objectForKey:@"zip"]];
        [book setBookId:[bookDic objectForKey:@"id"]];
        
        //解压zip 解压后的文件夹名称以下载码命名
        NSString *toBookPath =[CACHE_PATH stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"books/%@",[book downnum]]];
        
        BOOL isOk =[SSZipArchive unzipFileAtPath:request.downloadDestinationPath
                                   toDestination:toBookPath
                                       overwrite:YES
                                        password:nil
                                           error:nil];
        if (!isOk) {
            CCLog(@"-------%@解压失败",request.downloadDestinationPath);
        }else{
            
            [DBUtils insertBook:book];
        }
        
        //删除zip
        NSFileManager *fm =[NSFileManager defaultManager];
        if ([fm fileExistsAtPath:request.downloadDestinationPath]) {
            [fm removeItemAtPath:request.downloadDestinationPath error:nil];
        }
        
        if ([delegate respondsToSelector:@selector(didFinished)]) {
            [delegate performSelector:@selector(didFinished)];
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
