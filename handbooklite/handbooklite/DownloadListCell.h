//
//  DownloadListCell.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-11.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "MyHttpRequest.h"
#import "Book.h"

@protocol DownloadListCellDelegate <NSObject>

- (void)didDownloadBookSuccess;

- (void)didDownloadBookFailedWidthError:(NSString *)error;

@end

@interface DownloadListCell : UITableViewCell<MyHttpRequestDelegate,UIAlertViewDelegate>{
    
    UILabel *bookTitleView;
    UILabel *bookDownnumView;
    UILabel *saveDateView;
    
    UIButton *downloadBtn;
    UIProgressView *progress;
    
    id<DownloadListCellDelegate> __weak delegate;
    
    NSInteger tempId;
    
    BOOL isDownloading;
    BOOL isStopDownload;
    
    ASINetworkQueue *networkQueue;
    MyHttpRequest *myRequest;
    
    Book *paramBook;//全局变量
    
}
@property (nonatomic, strong)UILabel *bookTitleView;
@property (nonatomic, strong)UILabel *bookDownnumView;
@property (nonatomic, strong)UILabel *saveDateView;

@property (nonatomic, strong)UIButton *downloadBtn;
@property (nonatomic, weak)id<DownloadListCellDelegate> delegate;

@property (nonatomic, assign)NSInteger tempId;

@property (nonatomic, assign)BOOL isDownloading;

@end
