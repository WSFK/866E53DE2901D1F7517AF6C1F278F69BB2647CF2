//
//  DownloadListViewController.h
//  handbooklite
//
//  Created by bao_wsfk on 12-12-11.
//
//

#import <UIKit/UIKit.h>
#import "DownloadListCell.h"
#import "UIViewController_Extension.h"

@protocol DownloadListViewDelegate <NSObject>

- (void)didDownloadFinished;

@end

@interface DownloadListViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate,DownloadListCellDelegate>{
    
    UIImageView *backgroundImageView;
    
    UITableView *listView;
    
    NSMutableArray *bookTemps;

    BOOL isHidden;
    
    id<DownloadListViewDelegate> __weak delegate;
    
}
@property (nonatomic, assign)BOOL isHidden;
@property (nonatomic, assign)BOOL isDownloading;

@property (nonatomic, weak)id<DownloadListViewDelegate> delegate;

- (void)setViewHidden:(BOOL)hidden withAnimation:(BOOL)animation;

@end
