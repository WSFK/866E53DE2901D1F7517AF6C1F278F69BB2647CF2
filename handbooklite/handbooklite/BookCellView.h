//
//  BookCellView.h
//  handbooklite
//
//  Created by bao_wsfk on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMGridViewCell.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "BookShelfViewController.h"

@interface BookCellView : MMGridViewCell{
    
    UILabel *_title;
    UIView *_titleLabelBackgroundView;
    UIProgressView *_progressView;
    UIImageView *_backgroundView;
    UIImageView *_bookIconView;
    UIButton *_deleteBtn;
    UIImageView *_suspendView;
    UILabel *_lbdling;
    
    UIButton *_pushBtn;
    
    UIImageView *_iconNewImgView;
    
    NSString *downnum;
    
    BOOL isCancel;
    
    
    ASINetworkQueue *_networkQueue;
    BookShelfViewController *_bookTarget;
}
@property (nonatomic ,strong) UILabel *title;
@property (nonatomic ,strong) UIView *titleLabelBackgroundView;
@property (nonatomic ,strong) UIProgressView *progressView;
@property (nonatomic ,strong) UIImageView *backgroundView;
@property (nonatomic ,strong) UIImageView *bookIconView;
@property (nonatomic ,strong) UIButton *deleteBtn;
@property (nonatomic ,strong) UIImageView *suspendView;
@property (nonatomic ,strong) UILabel *lbdling;

@property (nonatomic ,strong) UIButton *pushBtn;
@property (nonatomic ,strong) UIImageView *iconNewImgView;

@property (nonatomic ,copy)   NSString *downnum;

@property (nonatomic ,strong) ASINetworkQueue *networkQueue;
@property (nonatomic ,strong) BookShelfViewController *bookTarget;

- (id)initWithFrame:(CGRect)frame andIndex:(NSUInteger)atIndex;


//启动下载
- (void)startDownload:(NSString *)iconUrlString
         zipUrlString:(NSString *)zipUrlString
              saveDir:(NSString *)saveDir
             bookName:(NSString *)bookName;

- (void)reloadBookIcon:(BookCellView *)cell iconImage:(UIImage *)iconImage;


//取消下载
- (void)cancelDownload;

- (void)startProgress;

- (void)endProgress;

- (void)showDeleteBtn:(BOOL)isEdit;

- (IBAction)clickDelete:(id)sender;

- (void)downloadBookDic:(NSDictionary *)bookDic target:(BookShelfViewController *)target;

@end
