//
//  BookViewController.h
//  handbook
//
//  Created by bao_wsfk on 12-8-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexViewController.h"
#import "Properties.h"
#import "TopViewController.h"
#import "Book.h"
#import "DrawViewController.h"
#import "TowCodeAlertView.h"

#import "PublicImport.h"
#import "ShareActionSheet.h"

@protocol BookViewDelegate <NSObject>
@required
- (void)didbookViewControllerToHome;//点击Home操作
@end

@interface BookViewController : UIViewController<SendMailDelegate,TopViewDelegate,UIWebViewDelegate, UIScrollViewDelegate,TowCodeAlertDelegate>
{
  CGRect screenBounds;//机器屏幕
	
	NSString *cachesBookPath;//book 在document下的路径
  NSString *bundleBookPath;  //book 在项目下的路径
  NSString *defaultScreeshotsPath;//默认页面背景图片的路径
  NSString *cachedScreenshotsPath;//机器的Libaray/Caches/下的背景图片的路径
  
  NSString *availableOrientation;//屏幕的横竖方向
  NSString *renderingType;
	
	NSMutableArray *pages;
  NSMutableArray *toLoad;
  
  NSMutableArray *pageDetails;//页面详细描述
  NSMutableDictionary *attachedScreenshotPortrait;
  NSMutableDictionary *attachedScreenshotLandscape;
  
  UIImage *backgroundImageLandscape;
  UIImage *backgroundImagePortrait;
  
	NSString *pageNameFromURL;
	NSString *anchorFromURL;
	
  int tapNumber;
  int stackedScrollingAnimations;
  
	BOOL currentPageFirstLoading;
	BOOL currentPageIsDelayingLoading;
  BOOL currentPageHasChanged;
  BOOL currentPageIsLocked;//当前状态是锁住的
  
  UIScrollView *scrollView;
	UIWebView *prevPage;
	UIWebView *currPage;
	UIWebView *nextPage;
	
  UIColor *webViewBackground;//web页面的背景颜色
  
	CGRect upTapArea;//页面上部区域的大小
	CGRect downTapArea;//页面下部区域的大小
	CGRect leftTapArea;//页面左部区域的大小
	CGRect rightTapArea;//页面右部区域的大小
  
	int totalPages;
  int lastPageNumber;
	int currentPageNumber;
	
  int pageWidth;
	int pageHeight;
  int currentPageHeight;
	
	UIAlertView *feedbackAlert;
  
  IndexViewController *indexViewController;
  TopViewController *topViewController;
  Book *currentBook;
  Properties *properties;
  TowCodeAlertView *towCodeAlert;
  
  ShareActionSheet *actionSheet;
    
    NSString *currentPageName;
}

#pragma mark - PROPERTIES
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIWebView *currPage;
@property int currentPageNumber;
@property (nonatomic, assign) id<BookViewDelegate> delegate;


#pragma mark - INIT

//添加的方法
- (id)initWithCachesBookPath:(NSString *)cacheBookPath
              bundleBookPath:(NSString*)bdlBookPath
       defaultScreeshotsPath:(NSString *)defScreeshotsPath
                      target:(BookShelfViewController *)target
                        book:(Book *)book;

//加载网页
- (void)setupWebView:(UIWebView *)webView;
//根据屏幕的方向，设置网页的宽和高
- (void)setPageSize:(NSString *)orientation;
//设置页面区域的大小
- (void)setTappableAreaSize;
- (void)resetScrollView;
- (void)initPageDetails;
- (void)showPageDetails;
- (void)resetPageDetails;
- (void)initBookProperties:(NSString *)path;
- (void)initBook:(NSString *)path;
- (void)setImageFor:(UIImageView *)view;
- (void)addSkipBackupAttributeToItemAtPath:(NSString *)path;

#pragma mark - LOADING
- (BOOL)changePage:(int)page;
- (void)gotoPageDelayer;
- (void)gotoPage;
- (void)lockPage:(NSNumber *)lock;
- (void)addPageLoading:(int)slot;
- (void)handlePageLoading;
- (void)loadSlot:(int)slot withPage:(int)page;
- (BOOL)loadWebView:(UIWebView *)webview withPage:(int)page;

#pragma mark - SCROLLVIEW
- (CGRect)frameForPage:(int)page;
//- (void)resetScrollView;

#pragma mark - WEBVIEW
- (void)webView:(UIWebView *)webView hidden:(BOOL)status animating:(BOOL)animating;
- (void)webViewDidAppear:(UIWebView *)webView animating:(BOOL)animating;
- (void)webView:(UIWebView *)webView dispatchHTMLEvent:(NSString *)event;

#pragma mark - SCREENSHOTS
- (void)initScreenshots;
- (BOOL)checkScreeshotForPage:(int)pageNumber andOrientation:(NSString *)interfaceOrientation;
- (void)takeScreenshotFromView:(UIWebView *)webView forPage:(int)pageNumber andOrientation:(NSString *)interfaceOrientation;
- (void)placeScreenshotForView:(UIWebView *)webView andPage:(int)pageNumber andOrientation:(NSString *)interfaceOrientation;

#pragma mark - GESTURES
- (void)userDidTap:(UITouch *)touch;
- (void)userDidScroll:(UITouch *)touch;

#pragma mark - PAGE SCROLLING
- (void)getPageHeight;
- (void)goUpInPage:(NSString *)offset animating:(BOOL)animating;
- (void)goDownInPage:(NSString *)offset animating:(BOOL)animating;
- (void)scrollPage:(UIWebView *)webView to:(NSString *)offset animating:(BOOL)animating;
- (void)handleAnchor:(BOOL)animating;

#pragma mark - STATUS BAR
- (void)toggleStatusBar;
- (void)hideStatusBar;

#pragma mark - ORIENTATION
- (NSString *)getCurrentInterfaceOrientation;

#pragma mark - INDEX VIEW
- (BOOL)isIndexView:(UIWebView *)webView;

//获取书的名称
- (NSString *)getBookName;
@end
