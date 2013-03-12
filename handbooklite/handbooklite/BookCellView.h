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
    
    NSInteger bookId;
    
    
    ASINetworkQueue *_networkQueue;
    BookShelfViewController *_bookTarget;
}
@property (nonatomic ,strong) UILabel *title;
@property (nonatomic ,strong) UIView *titleLabelBackgroundView;
@property (nonatomic ,strong) UIProgressView *progressView;
@property (nonatomic ,strong) UIImageView *backgroundView;
@property (nonatomic ,strong) UIImageView *bookIconView;
@property (nonatomic ,strong) UIButton *deleteBtn;
@property (nonatomic ,assign) NSInteger bookId;

@property (nonatomic ,strong) ASINetworkQueue *networkQueue;
@property (nonatomic ,strong) BookShelfViewController *bookTarget;

- (id)initWithFrame:(CGRect)frame andIndex:(NSUInteger)atIndex;

- (void)startProgress;

- (void)endProgress;

- (void)cancelEditBtn;

- (void)startDeleteIndex:(int)indextmp andTarget:(BookShelfViewController *)target;

- (IBAction)endDelete:(id)sender;

- (void)downloadBookDic:(NSDictionary *)bookDic target:(BookShelfViewController *)target;

@end
