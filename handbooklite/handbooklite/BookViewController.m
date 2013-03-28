//
//  BookViewController.m
//  handbook
//
//  Created by bao_wsfk on 12-8-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <sys/xattr.h>
#import "BookViewController.h"

#import "PageTitleLabel.h"
#import "Utils.h"
#import "iConsole.h"


// ALERT LABELS
#define OPEN_BOOK_MESSAGE       @"Do you want to download "
#define OPEN_BOOK_CONFIRM       @"Open book"

#define CLOSE_BOOK_MESSAGE      @"Do you want to close this book?"
#define CLOSE_BOOK_CONFIRM      @"Close book"

#define ZERO_PAGES_TITLE        @"Whoops!"
#define ZERO_PAGES_MESSAGE      @"Sorry, that book had no pages."

#define ERROR_FEEDBACK_TITLE    @"Whoops!"
#define ERROR_FEEDBACK_MESSAGE  @"There was a problem downloading the book."
#define ERROR_FEEDBACK_CONFIRM  @"Retry"

#define EXTRACT_FEEDBACK_TITLE  @"Extracting..."

#define ALERT_FEEDBACK_CANCEL   @"Cancel"

#define INDEX_FILE_NAME         @"index.html"

#define URL_OPEN_MODALLY        @"referrer=Baker"
#define URL_OPEN_EXTERNAL       @"referrer=Safari"


// IOS VERSION >= 5.0 MACRO
#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_5_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_5_0 675.00
#endif
#ifndef __IPHONE_5_0
#define __IPHONE_5_0 50000
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
#define IF_IOS5_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_5_0) { \
__VA_ARGS__ \
}
#else
#define IF_IOS5_OR_GREATER(...)
#endif


// SCREENSHOT
#define MAX_SCREENSHOT_AFTER_CP  10
#define MAX_SCREENSHOT_BEFORE_CP 10


@interface BookViewController ()

@end

@implementation BookViewController

#pragma mark - SYNTHESIS
@synthesize scrollView;
@synthesize currPage;
@synthesize currentPageNumber;



- (id)initWithCachesBookPath:(NSString *)cacheBookPath
              bundleBookPath:(NSString *)bdlBookPath
       defaultScreeshotsPath:(NSString *)defScreeshotsPath
                      target:(BookShelfViewController *)target
                        book:(Book *)book
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    
    
    // ****** INIT PROPERTIES
    properties = [Properties properties];
    currentBook =book;
    
    // ****** DEVICE SCREEN BOUNDS
    screenBounds = [[UIScreen mainScreen] bounds];
    
    bundleBookPath = bdlBookPath;
    cachesBookPath = cacheBookPath;
    defaultScreeshotsPath = defScreeshotsPath;
    [self addSkipBackupAttributeToItemAtPath:defaultScreeshotsPath];
    
    // ****** BOOK ENVIRONMENT
    pages = [[NSMutableArray alloc] init];
    toLoad = [[NSMutableArray alloc] init];
    
    pageDetails = [[NSMutableArray alloc] init];
    attachedScreenshotPortrait  = [[NSMutableDictionary alloc] init];
    attachedScreenshotLandscape = [[NSMutableDictionary alloc] init];
    
    pageNameFromURL = nil;
    anchorFromURL = nil;
    
    tapNumber = 0;
    stackedScrollingAnimations = 0;
    
    currentPageFirstLoading = YES;
    currentPageIsDelayingLoading = YES;
    currentPageHasChanged = NO;
    currentPageIsLocked = NO;
    
    webViewBackground = nil;
    
    [self setPageSize:[self getCurrentInterfaceOrientation]];
    [self hideStatusBar];//隐藏横向滚动条
    
    // ****** SCROLLVIEW INIT初始化页面滚动条
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, pageWidth, pageHeight)];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delaysContentTouches = YES;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.bounces =NO;
    
    [self.view addSubview:scrollView];
    
    
    // ****** INDEX WEBVIEW INIT 初始化横向滚动条
    
    indexViewController = [[IndexViewController alloc] initWithBookBundlePath:bundleBookPath
                                                               cachesBookPath:cachesBookPath
                                                                     fileName:INDEX_FILE_NAME
                                                              webViewDelegate:self];
    [self.view addSubview:indexViewController.view];
    
    // ****** TOP VIEW INIT
    topViewController =[[TopViewController alloc] initWithNibName:@"TopViewController" book:currentBook];
    [topViewController setDelegate:self];
    [self.view addSubview:topViewController.view];
    
    // ****** BOOK INIT 初始化book
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachesBookPath]) {
      CCLog(@"-----------initbookPath in cachesBookPath");
      [self initBook:cachesBookPath];
    } else {
      if ([[NSFileManager defaultManager] fileExistsAtPath:bundleBookPath]) {
        CCLog(@"-----------initbookPath in bundleBookPath");
        [self initBook:bundleBookPath];
      } else {
        // Do something if there are no books available to show
      }
    }
    
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden =YES;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotateToInterfaceOrientation:duration:) name:@"willRotate" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateFromInterfaceOrientation:) name:@"didRotate" object:nil];
  currPage.delegate = self;
	nextPage.delegate = self;
	prevPage.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"willRotate" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRotate" object:nil];
}

- (void)setupWebView:(UIWebView *)webView {
  
  if (webViewBackground == nil)
  {
    webViewBackground = webView.backgroundColor;
  }
  
  webView.backgroundColor = [UIColor clearColor];
  webView.opaque = NO;//设置页面为透明的
  
  webView.delegate = self;
  webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
  webView.mediaPlaybackRequiresUserAction = ![[properties get:@"-baker-media-autoplay", nil] boolValue];
  //设置网页是否适应屏幕的大小
  webView.scalesPageToFit = [[properties get:@"zoomable", nil] boolValue];
  BOOL verticalBounce = [[properties get:@"-baker-vertical-bounce", nil] boolValue];
  
  for (UIView *subview in webView.subviews) {
    if ([subview isKindOfClass:[UIScrollView class]]) {
      //设置滚动条是否是垂直的
      ((UIScrollView *)subview).bounces = verticalBounce;
    }
  }
}

- (void)setPageSize:(NSString *)orientation {
  //屏幕是立着的情况
  pageWidth = screenBounds.size.width;
  pageHeight = screenBounds.size.height;
	if ([orientation isEqualToString:@"landscape"]||
      [orientation isEqualToString:@"landscapeLeft"]||
      [orientation isEqualToString:@"landscapeRight"]) {
    //屏幕是横着的时候
		pageWidth = screenBounds.size.height;
		pageHeight = screenBounds.size.width;
	}
}
- (void)setTappableAreaSize {
  
  int tappableAreaSize = screenBounds.size.width/16;
  if (screenBounds.size.width < 768) {
    tappableAreaSize = screenBounds.size.width/8;
  }
  
  upTapArea    = CGRectMake(tappableAreaSize, 0, pageWidth - (tappableAreaSize * 2), tappableAreaSize);
  downTapArea  = CGRectMake(tappableAreaSize, pageHeight - tappableAreaSize, pageWidth - (tappableAreaSize * 2), tappableAreaSize);
  leftTapArea  = CGRectMake(0, tappableAreaSize, tappableAreaSize, pageHeight - (tappableAreaSize * 2));
  rightTapArea = CGRectMake(pageWidth - tappableAreaSize, tappableAreaSize, tappableAreaSize, pageHeight - (tappableAreaSize * 2));
}
- (void)resetScrollView {
  
  //设置页面锁住状态
  [self lockPage:[NSNumber numberWithBool:YES]];
  //设置页面区域
  [self setTappableAreaSize];
  
  /**
  for (NSMutableDictionary *details in pageDetails) {
    for (NSString *key in details) {
      UIView *value = [details objectForKey:key];
      value.hidden = YES;
    }
  }
  
  [self showPageDetails];
  **/
  
  if ([renderingType isEqualToString:@"screenshots"])
  {
    for (NSNumber *key in attachedScreenshotLandscape) {
      UIView *value = [attachedScreenshotLandscape objectForKey:key];
      [value removeFromSuperview];
    }
    
    for (NSNumber *key in attachedScreenshotPortrait) {
      UIView *value = [attachedScreenshotPortrait objectForKey:key];
      [value removeFromSuperview];
    }
    
    [attachedScreenshotLandscape removeAllObjects];
    [attachedScreenshotPortrait removeAllObjects];
    
    [self initScreenshots];
  }
  
  scrollView.contentSize = CGSizeMake(pageWidth * totalPages, pageHeight);
  
	int scrollViewY = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		scrollViewY = -20;
	}
  [UIView animateWithDuration:0.2
                   animations:^{ scrollView.frame = CGRectMake(0, scrollViewY, pageWidth, pageHeight); }];
	
  if (prevPage && [prevPage.superview isEqual:scrollView]) {
    prevPage.frame = [self frameForPage:currentPageNumber - 1];
    [scrollView bringSubviewToFront:prevPage];
  }
  
  if (nextPage && [nextPage.superview isEqual:scrollView]) {
    nextPage.frame = [self frameForPage:currentPageNumber + 1];
    [scrollView bringSubviewToFront:nextPage];
  }
  
  if (currPage) {
    currPage.frame = [self frameForPage:currentPageNumber];
  }
  
  [scrollView bringSubviewToFront:currPage];
  [scrollView scrollRectToVisible:[self frameForPage:currentPageNumber] animated:NO];
  
  
  [self lockPage:[NSNumber numberWithBool:NO]];
}

- (void)initPageDetails {
  
  for (int i = 0; i < totalPages; i++) {
    
    UIColor *foregroundColor = [Utils colorWithHexString:[properties get:@"-baker-page-numbers-color", nil]];
    id foregroundAlpha = [properties get:@"-baker-page-numbers-alpha", nil];
    
    // ****** Background
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(pageWidth * i, 0, pageWidth, pageHeight)];
    [self setImageFor:backgroundView];
    [scrollView addSubview:backgroundView];
    
    // ****** Spinners
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.backgroundColor = [UIColor clearColor];
    IF_IOS5_OR_GREATER(
                       spinner.color = foregroundColor;
                       spinner.alpha = [(NSNumber *)foregroundAlpha floatValue];
                       );
    
    CGRect frame = spinner.frame;
    frame.origin.x = pageWidth * i + (pageWidth - frame.size.width) / 2;
    frame.origin.y = (pageHeight - frame.size.height) / 2;        
    spinner.frame = frame;
    
    [scrollView addSubview:spinner];
    [spinner startAnimating];
    
    // ****** Numbers
    //        UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(pageWidth * i + (pageWidth - 115) / 2, pageHeight / 2 + 55, 115, 30)];
    //        number.backgroundColor = [UIColor clearColor];
    //        number.font = [UIFont fontWithName:@"Helvetica" size:40.0];
    //        number.textColor = foregroundColor;
    //        number.textAlignment = UITextAlignmentCenter;
    //        number.alpha = [(NSNumber *)foregroundAlpha floatValue];
    //        
    //        number.text = [NSString stringWithFormat:@"%d", i + 1];
    //        if ([[properties get:@"-baker-start-at-page", nil] intValue] < 0) {
    //            number.text = [NSString stringWithFormat:@"%d", totalPages - i];
    //        }
    //        
    //        [scrollView addSubview:number];
    //        [number release];
    //        
    //        // ****** Title
    //        PageTitleLabel *title = [[PageTitleLabel alloc]initWithFile:[pages objectAtIndex: i]];
    //        [title setX:(pageWidth * i + ((pageWidth - title.frame.size.width) / 2)) Y:(pageHeight / 2 + 90)];
    //        [scrollView addSubview:title];
    //        [title release];
    
    // ****** Store instances for later use
    //        NSMutableDictionary *details = [NSMutableDictionary dictionaryWithObjectsAndKeys:spinner, @"spinner", number, @"number", title, @"title", backgroundView, @"background", nil];
//    NSMutableDictionary *details = [NSMutableDictionary dictionaryWithObjectsAndKeys:spinner, @"spinner",backgroundView, @"background", nil];
//    [pageDetails insertObject:details atIndex:i];
  }
}

- (void)showPageDetails {
  
	for (int i = 0; i < totalPages; i++) {
    
    if (pageDetails.count > i && [pageDetails objectAtIndex:i] != nil) {
      
      NSDictionary *details = [NSDictionary dictionaryWithDictionary:[pageDetails objectAtIndex:i]];
      
      for (NSString *key in details) {
        UIView *value = [details objectForKey:key];
        if (value != nil) {
          
          CGRect frame = value.frame;
          if ([key isEqualToString:@"spinner"]) {
            
            frame.origin.x = pageWidth * i + (pageWidth - frame.size.width) / 2;
            frame.origin.y = (pageHeight - frame.size.height) / 2;
            value.frame = frame;
            value.hidden = NO;
            
          } else if ([key isEqualToString:@"number"]) {
            
            frame.origin.x = pageWidth * i + (pageWidth - 115) / 2;
            frame.origin.y = pageHeight / 2 + 55;
            value.frame = frame;
            value.hidden = NO;
            
            
          } else if ([key isEqualToString:@"title"]) {
            
            frame.origin.x = pageWidth * i + (pageWidth - frame.size.width) / 2;
            frame.origin.y = pageHeight / 2 + 90;
            value.frame = frame;
            value.hidden = NO;
            
          } else if ([key isEqualToString:@"background"]) {
            
            [self setImageFor:(UIImageView *)value];
            frame.origin.x = pageWidth * i;
            frame.size.width = pageWidth;
            frame.size.height = pageHeight;
            value.frame = frame;
            value.hidden = NO;
            
          } else {
            
            value.hidden = YES;
          }
        }
      }
    } 
	}
}

- (void)resetPageDetails {
  
  for (NSMutableDictionary *details in pageDetails) {
    for (NSString *key in details) {
      UIView *value = [details objectForKey:key];
      [value removeFromSuperview];
    }
  }
  
  [pageDetails removeAllObjects];
  [pages removeAllObjects];
}

- (void)initBookProperties:(NSString *)path {
  /****************************************************************************************************
   * Initializes the 'properties' object from book.json and inits also some static properties.
   */
  
  NSString *filePath = [path stringByAppendingPathComponent:@"book.json"];
  [properties loadManifest:filePath];
  
  // ****** ORIENTATION
  availableOrientation = [properties get:@"orientation", nil];
  
  // ****** RENDERING
  renderingType = [properties get:@"-baker-rendering", nil];
  
  // ****** SWIPES
  scrollView.scrollEnabled = [[properties get:@"-baker-page-turn-swipe", nil] boolValue];
  
  // ****** BACKGROUND
  scrollView.backgroundColor = [Utils colorWithHexString:[properties get:@"-baker-background", nil]];
  backgroundImageLandscape   = nil;
  backgroundImagePortrait    = nil;
  
  NSString *backgroundPathLandscape = [properties get:@"-baker-background-image-landscape", nil];
  if (backgroundPathLandscape != nil) {
    backgroundPathLandscape  = [path stringByAppendingPathComponent:backgroundPathLandscape];
    backgroundImageLandscape = [UIImage imageWithContentsOfFile:backgroundPathLandscape];        
  }
  
  NSString *backgroundPathPortrait = [properties get:@"-baker-background-image-portrait", nil];
  if (backgroundPathPortrait != nil) {
    backgroundPathPortrait  = [path stringByAppendingPathComponent:backgroundPathPortrait];
    backgroundImagePortrait = [UIImage imageWithContentsOfFile:backgroundPathPortrait];
  }
}
- (void)initBook:(NSString *)path {
  
  // If a previous current page exist remove it before initialization
  if (currPage)
  {
    currPage.delegate = nil;
    
    [currPage removeFromSuperview];
    
    currPage = nil;
  }

  [self initBookProperties:path];
  [self resetPageDetails];
	
  NSEnumerator *pagesEnumerator = [[properties get:@"contents", nil] objectEnumerator];
  id page;
  //便利contents数组，所有页面的名称
  while ((page = [pagesEnumerator nextObject])) {
    NSString *pageFile = nil;
    //有两种类型，一个只是单纯的字符串，另一个可以是数组类型
    if ([page isKindOfClass:[NSString class]]) {
      pageFile = [path stringByAppendingPathComponent:page];
    } else if ([page isKindOfClass:[NSDictionary class]]) {
      pageFile = [path stringByAppendingPathComponent:[page objectForKey:@"url"]];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pageFile]) {
      //如果该页面存在，添加到Pages数组中
      [pages addObject:pageFile];
    } else {
      CCLog(@"页面: %@ 在%@下不存在", page, path);
    }
  }
  
	totalPages = [pages count];
  
	
	if (totalPages > 0) {
		// Check if there is a saved starting page
    //根据书名获取最后一页
    NSDictionary *lastPageDic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]
                                                 objectForKey:[self getBookName]];
    
    //[[NSUserDefaults standardUserDefaults] objectForKey:@"lastPageViewed"];
		NSString *currPageToLoad = [lastPageDic objectForKey:@"lastPageViewed"];
    
    int startingPage = [[properties get:@"-baker-start-at-page", nil] intValue];
    if (startingPage < 0) {
      startingPage = MAX(1, totalPages + startingPage + 1);
    } else if (startingPage == 0) {
      startingPage = 1;
    } else if (startingPage > 0) {
      startingPage = MIN(totalPages, startingPage);
    }
    
    currentPageNumber = startingPage;
    if (currentPageFirstLoading && currPageToLoad != nil) {
      //如果当前页是第一个加载的
			currentPageNumber = [currPageToLoad intValue];
		} else if (pageNameFromURL != nil) {
      pageNameFromURL = nil;
      NSString *fileNameFromURL = [path stringByAppendingPathComponent:pageNameFromURL];
      for (int i = 0; i < totalPages; i++) {
        if ([[pages objectAtIndex:i] isEqualToString:fileNameFromURL]) {
          currentPageNumber = i + 1;
          break;
        }
			}
		}
    
		
    currentPageIsDelayingLoading = NO;
    
    //删除所有
    [toLoad removeAllObjects];
		
    NSString *screenshotFolder = [properties get:@"-baker-page-screenshots", nil];
    if (screenshotFolder != nil) {
      cachedScreenshotsPath = [path stringByAppendingPathComponent:screenshotFolder];
    }
    
    if (screenshotFolder == nil || ![[NSFileManager defaultManager] fileExistsAtPath:cachedScreenshotsPath]) {
      cachedScreenshotsPath = [path stringByAppendingPathComponent:@"baker-screenshots"];
      
      if ([path isEqualToString:cachesBookPath]) {
        cachedScreenshotsPath = defaultScreeshotsPath;
      }
    }
    
    
    [self initPageDetails];
    [self resetScrollView];
    [self addPageLoading:0];
    
    if ([renderingType isEqualToString:@"three-cards"]) {
      if (currentPageNumber != totalPages) {
        [self addPageLoading:+1];
      }
      
      if (currentPageNumber != 1) {
        [self addPageLoading:-1];
      }
    }
    [self handlePageLoading];
    
    [indexViewController loadContentFromBundle:[path isEqualToString:bundleBookPath]];
		
	} else if (![path isEqualToString:bundleBookPath]) {
		
		[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
 		feedbackAlert = [[UIAlertView alloc] initWithTitle:ZERO_PAGES_TITLE
                                               message:ZERO_PAGES_MESSAGE
                                              delegate:self
                                     cancelButtonTitle:ALERT_FEEDBACK_CANCEL
                                     otherButtonTitles:nil];
		[feedbackAlert show];
	}
}
- (void)setImageFor:(UIImageView *)view {
  if (pageWidth > pageHeight && backgroundImageLandscape != NULL) {
    // Landscape
    view.image = backgroundImageLandscape;
  } else if (pageWidth < pageHeight && backgroundImagePortrait != NULL) {
    // Portrait
    view.image = backgroundImagePortrait;
  } else {
    view.image = NULL;
  }
}
- (void)addSkipBackupAttributeToItemAtPath:(NSString *)path {
  const char *filePath = [path fileSystemRepresentation];
  const char *attrName = "com.apple.MobileBackup";
  u_int8_t attrValue = 1;
  
  int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
  if (result == 0) {
    CCLog(@"Successfully added skip backup attribute to item");
  }else {
    CCLog(@"Failure added skip backup attribute to item");
  }
}

#pragma mark - LOADING
- (BOOL)changePage:(int)page {
  
  BOOL pageChanged = NO;
	
  if (page < 1)
  {
		currentPageNumber = 1;
	}
  else if (page > totalPages)
  {
		currentPageNumber = totalPages;
	} 
  else if (page != currentPageNumber)
  {
    // While we are tapping, we don't want scrolling event to get in the way
    scrollView.scrollEnabled = NO;
    stackedScrollingAnimations++;
    
    lastPageNumber = currentPageNumber;
		currentPageNumber = page;
    
    tapNumber = tapNumber + (lastPageNumber - currentPageNumber);
    
    [self hideStatusBar];
    [scrollView scrollRectToVisible:[self frameForPage:currentPageNumber] animated:YES];
    
    [self gotoPageDelayer];
    
    pageChanged = YES;
	}
	
	return pageChanged;
}
- (void)gotoPageDelayer {
	// This delay is required in order to avoid stuttering when the animation runs.
	// The animation lasts 0.5 seconds: so we start loading after that.
  
	if (currentPageIsDelayingLoading) {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(gotoPage) object:nil];
  }
	
	currentPageIsDelayingLoading = YES;
	[self performSelector:@selector(gotoPage) withObject:nil afterDelay:0.1];
}
- (void)gotoPage {    
  
  //CCLog(@"---------currentPageNumber:%d",currentPageNumber - 1);
  
  NSString *path = [NSString stringWithString:[pages objectAtIndex:currentPageNumber - 1]];
  if ([[NSFileManager defaultManager] fileExistsAtPath:path] && tapNumber != 0) {
    
    if ([renderingType isEqualToString:@"three-cards"])
    {
      // ****** THREE CARD VIEW METHOD
      
      // Dispatch blur event on old current page
      [self webView:currPage dispatchHTMLEvent:@"blur"];
      
      // Calculate move direction and normalize tapNumber
      int direction = 1;
      if (tapNumber < 0) {
        direction = -direction;
        tapNumber = -tapNumber;
      }
      
      if (tapNumber > 2) {
        
        tapNumber = 0;
        // Moved away for more than 2 pages: RELOAD ALL pages
        [toLoad removeAllObjects];
        
        [currPage loadHTMLString:@"" baseURL:nil];
        [nextPage loadHTMLString:@"" baseURL:nil];
        [prevPage loadHTMLString:@"" baseURL:nil];
        
        [currPage removeFromSuperview];
        [nextPage removeFromSuperview];
        [prevPage removeFromSuperview];
        
        [self addPageLoading:0];
        if (currentPageNumber < totalPages)
          [self addPageLoading:+1];
        if (currentPageNumber > 1)
          [self addPageLoading:-1];
        
      } else {
        
        int tmpSlot = 0;
        if (tapNumber == 2) {
          
          // Moved away for 2 pages: RELOAD CURRENT page
          if (direction < 0) {
            // Move LEFT <<<
            [prevPage removeFromSuperview];
            UIWebView *tmpView = prevPage;
            prevPage = nextPage;
            nextPage = tmpView;
          } else {
            // Move RIGHT >>>
            [nextPage removeFromSuperview];
            UIWebView *tmpView = nextPage;
            nextPage = prevPage;
            prevPage = tmpView;
          }
          
          // Adjust pages slot in the stack to reflect the webviews pointer change
          for (int i = 0; i < [toLoad count]; i++) {
            tmpSlot =  -1 * [[[toLoad objectAtIndex:i] valueForKey:@"slot"] intValue];
            [[toLoad objectAtIndex:i] setObject:[NSNumber numberWithInt:tmpSlot] forKey:@"slot"];
          }
          
          [currPage removeFromSuperview];
          [self addPageLoading:0];
          
        } else if (tapNumber == 1) {
          
          if (direction < 0) {
            // ****** Move LEFT <<<
            [prevPage removeFromSuperview];
            [currPage reload];
            UIWebView *tmpView = prevPage;
            prevPage = currPage;
            currPage = nextPage;
            nextPage = tmpView;
            
            
          } else {
            // ****** Move RIGHT >>>
            [nextPage removeFromSuperview];
            [currPage reload];
            UIWebView *tmpView = nextPage;
            nextPage = currPage;
            currPage = prevPage;
            prevPage = tmpView;                        
          }
          
          // Adjust pages slot in the stack to reflect the webviews pointer change
          for (int i = 0; i < [toLoad count]; i++) {
            tmpSlot = [[[toLoad objectAtIndex:i] valueForKey:@"slot"] intValue];
            if (direction < 0) {
              if (tmpSlot == +1) {
                tmpSlot = 0;
              } else if (tmpSlot == 0) {
                tmpSlot = -1;
              } else if (tmpSlot == -1) {
                tmpSlot = +1;
              }
            } else {
              if (tmpSlot == -1) {
                tmpSlot = 0;
              } else if (tmpSlot == 0) {
                tmpSlot = +1;
              } else if (tmpSlot == +1) {
                tmpSlot = -1;
              }
            }
            [[toLoad objectAtIndex:i] setObject:[NSNumber numberWithInt:tmpSlot] forKey:@"slot"];
          }
          
          // Since we are not loading anything we have to reset the delayer flag
          currentPageIsDelayingLoading = NO;
          
          // Dispatch focus event on new current page
          [self webView:currPage dispatchHTMLEvent:@"focus"];
        }
        
        [self getPageHeight];
        
        tapNumber = 0;
        if (direction < 0) {
          
          // REMOVE OTHER NEXT page from toLoad stack
          for (int i = 0; i < [toLoad count]; i++) {
            if ([[[toLoad objectAtIndex:i] valueForKey:@"slot"] intValue] == +1) {
              [toLoad removeObjectAtIndex:i];
            }   
          }
          
          // PRELOAD NEXT page
          if (currentPageNumber < totalPages) {
            [self addPageLoading:+1];
          }
          
        } else {
          
          // REMOVE OTHER PREV page from toLoad stack
          for (int i = 0; i < [toLoad count]; i++) {
            if ([[[toLoad objectAtIndex:i] valueForKey:@"slot"] intValue] == -1) {
              [toLoad removeObjectAtIndex:i];
            }   
          }
          
          // PRELOAD PREV page
          if (currentPageNumber > 1) {
            [self addPageLoading:-1];
          }
        }
      }
      
      [self handlePageLoading];
    }
    else
    {
      tapNumber = 0;
      
      [toLoad removeAllObjects];
      [currPage removeFromSuperview];            
      
      [self initScreenshots];
      
      if (![self checkScreeshotForPage:currentPageNumber andOrientation:[self getCurrentInterfaceOrientation]]) {
        [self lockPage:[NSNumber numberWithBool:YES]];
      }
      
      [self addPageLoading:0];
      [self handlePageLoading];
    }
  }
}
- (void)lockPage:(NSNumber *)lock {
  if ([lock boolValue])
  {//如果当前页面是锁住的
    if (scrollView.scrollEnabled) {
      //滚动条不能滚动
      scrollView.scrollEnabled = NO;
    }
    currentPageIsLocked = YES;//锁住状态
  }
  else
  {
    if (stackedScrollingAnimations == 0) {
      scrollView.scrollEnabled = [[properties get:@"-baker-page-turn-swipe", nil] boolValue]; // YES by default, NO if specified
    }
    currentPageIsLocked = NO;
  }
}
- (void)addPageLoading:(int)slot {    
  
  NSArray *objs = [NSArray arrayWithObjects:[NSNumber numberWithInt:slot], [NSNumber numberWithInt:currentPageNumber + slot], nil];
  NSArray *keys = [NSArray arrayWithObjects:@"slot", @"page", nil];
  
  if (slot == 0) {
    [toLoad insertObject:[NSMutableDictionary dictionaryWithObjects:objs forKeys:keys] atIndex:0];
  } else {
    [toLoad addObject:[NSMutableDictionary dictionaryWithObjects:objs forKeys:keys]];
  }
}
- (void)handlePageLoading {
  if ([toLoad count] != 0) {
    
    int slot = [[[toLoad objectAtIndex:0] valueForKey:@"slot"] intValue];
    int page = [[[toLoad objectAtIndex:0] valueForKey:@"page"] intValue];
    
    [toLoad removeObjectAtIndex:0];
    [self loadSlot:slot withPage:page];
  }
}
- (void)loadSlot:(int)slot withPage:(int)page {
  
  UIWebView *webView = [[UIWebView alloc] init];
  [self setupWebView:webView];
  
  webView.frame = [self frameForPage:page];
  webView.hidden = YES;
	
	// ****** SELECT
  // Since pointers can change at any time we've got to handle them directly on a slot basis.
  // Save the page pointer to a temp view to avoid code redundancy make Baker go apeshit.
	if (slot == 0) {
    
    if (currPage) {
      currPage.delegate = nil;
      if ([currPage isLoading]) {
        [currPage stopLoading];
      }
    }
    currPage = webView;
    currentPageHasChanged = YES;
    
	} else if (slot == +1) {
    
    if (nextPage) {
      nextPage.delegate = nil;
      if ([nextPage isLoading]) {
        [nextPage stopLoading];
      }
    }
    nextPage = webView;
    
  } else if (slot == -1) {
    
    if (prevPage) {
      prevPage.delegate = nil;
      if ([prevPage isLoading]) {
        [prevPage stopLoading];
      }
    }
    prevPage = webView;
  }
  
  
  ((UIScrollView *)[[webView subviews] objectAtIndex:0]).pagingEnabled = [[properties get:@"-baker-vertical-pagination", nil] boolValue];
  
  [scrollView addSubview:webView];
	[self loadWebView:webView withPage:page];
}
- (BOOL)loadWebView:(UIWebView*)webView withPage:(int)page {
	
	NSString *path = [NSString stringWithString:[pages objectAtIndex:page - 1]];
  
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    
    //使用下面方式加载页面在视频页面翻页刷新不能关闭视频
    //        NSURL *baseUrl = [[[NSBundle mainBundle]resourceURL]URLByAppendingPathComponent:@"books/book1"];    
    //        NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    //        NSString *htmlString = [[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    [webView loadHTMLString:@"" baseURL:nil];
    
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    //        [webView loadHTMLString:htmlString baseURL:baseUrl];
    //        [htmlString release];
		return YES;
	}
	return NO;
}

#pragma mark - SCROLLVIEW
- (CGRect)frameForPage:(int)page {
	return CGRectMake(pageWidth * (page - 1), 0, pageWidth, pageHeight);
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scroll {
  //    CCLog(@"• Scrollview will begin dragging");
  [self hideStatusBar];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scroll willDecelerate:(BOOL)decelerate {
  //    CCLog(@"• Scrollview did end dragging");
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scroll {
  //    CCLog(@"• Scrollview will begin decelerating");
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll {
  
  int page = (int)(scroll.contentOffset.x / pageWidth) + 1;
  
  if (currentPageNumber != page) {
    
    lastPageNumber = currentPageNumber;
    currentPageNumber = page;
    
    tapNumber = tapNumber + (lastPageNumber - currentPageNumber);
    
		currentPageIsDelayingLoading = YES;
		[self gotoPage];
  }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scroll {
  
  stackedScrollingAnimations--;
  if (stackedScrollingAnimations == 0) {
		scroll.scrollEnabled = [[properties get:@"-baker-page-turn-swipe", nil] boolValue]; // YES by default, NO if specified
	}
}

#pragma mark - WEBVIEW
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  
	// Sent before a web view begins loading content, useful to trigger actions before the WebView.	
  NSURL *url = [request URL];
  if ([webView isEqual:prevPage])
  {
    return YES;
  } 
  else if ([webView isEqual:nextPage])
  {
    return YES;
  } 
  else if (currentPageIsDelayingLoading)
  {		
		currentPageIsDelayingLoading = NO;
    return ![self isIndexView:webView];
	}
  else
  {        
		// ****** Handle URI schemes
		if (url)
    {
			// Existing, checking if index...
      if([[url relativePath] isEqualToString:[indexViewController indexPath]])
      {
        CCLog(@"-----just load web is indexViewController");
        return YES;
      }
      else
      {
        
        // Not index, checking scheme...
        if ([[url scheme] isEqualToString:@"file"])
        {
          // ****** Handle: file://
          
          anchorFromURL  = [url fragment];
          NSString *file = [[url relativePath] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
          
          int page = [pages indexOfObject:file];
          if (page == NSNotFound)
          {
            // ****** Internal link, but not one of the book pages --> load page anyway
            return YES;
          }
          
          page = page + 1;
          //                    
          if (![self changePage:page] && ![webView isEqual:indexViewController.view]) 
          {
            if (anchorFromURL == nil) {
              return YES;
            }
            
            [self handleAnchor:YES];                        
          }
          
          
        }
        
      }
      
      
    }
		
		return NO;
	}
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
  //    CCLog(@"• Page did start load");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// Sent if a web view failed to load content.
  if ([webView isEqual:currPage]) {
    //		CCLog(@"• CurrPage failed to load content with error: %@", error);
	} else if ([webView isEqual:prevPage]) {
    //		CCLog(@"• PrevPage failed to load content with error: %@", error);
	} else if ([webView isEqual:nextPage]) {
    //		CCLog(@"• NextPage failed to load content with error: %@", error);
  }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
  
  if (webView.hidden == YES)
  {
    if ([webView isEqual:currPage]) {
      currentPageHasChanged = NO;
      [self getPageHeight];
    }
    
    [webView removeFromSuperview];
    webView.hidden = NO;
    
    if ([renderingType isEqualToString:@"three-cards"]) {
      [self webView:webView hidden:NO animating:YES];
    } else {
      [self takeScreenshotFromView:webView forPage:currentPageNumber andOrientation:[self getCurrentInterfaceOrientation]];
    }
    
    [self handlePageLoading];
    
  }
  [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
}

- (void)webView:(UIWebView *)webView hidden:(BOOL)status animating:(BOOL)animating {
  webView.opaque = NO;
  if (animating) {
    
    webView.hidden = NO;
    webView.alpha = 0.0;
    
    [scrollView addSubview:webView];
    [UIView animateWithDuration:0.5
                     animations:^{ webView.alpha = 1.0; }
                     completion:^(BOOL finished) { [self webViewDidAppear:webView animating:animating]; }];
	} else {
    
    [scrollView addSubview:webView];
    [self webViewDidAppear:webView animating:animating];
	}
}
- (void)webViewDidAppear:(UIWebView *)webView animating:(BOOL)animating {
  
  if ([webView isEqual:currPage])
  {
    [self webView:webView dispatchHTMLEvent:@"focus"];
    
    // If is the first time i load something in the currPage web view...
    if (currentPageFirstLoading)
    {
      // ... check if there is a saved starting scroll index and set it
      NSDictionary *lastIndexDic = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:[self getBookName]];
      //[[NSUserDefaults standardUserDefaults] objectForKey:@"lastScrollIndex"]
      NSString *currPageScrollIndex = [lastIndexDic objectForKey:@"lastScrollIndex"];
      if (currPageScrollIndex != nil) {
        [self goDownInPage:currPageScrollIndex animating:YES];
      }
      currentPageFirstLoading = NO;
    }
    else
    {
      [self handleAnchor:YES];
    }
  }
}
- (void)webView:(UIWebView *)webView dispatchHTMLEvent:(NSString *)event {
  NSString *jsDispatchEvent = [NSString stringWithFormat:@"var bakerDispatchedEvent = document.createEvent('Events');\
                               bakerDispatchedEvent.initEvent('%@', false, false);\
                               window.dispatchEvent(bakerDispatchedEvent);", event];
  
  [webView stringByEvaluatingJavaScriptFromString:jsDispatchEvent];
}

#pragma mark - SCREENSHOTS
- (void)initScreenshots {
  
  NSMutableSet *completeSet = [NSMutableSet new];
  NSMutableSet *supportSet  = [NSMutableSet new]; 
  
  NSString *interfaceOrientation = nil;
  NSMutableDictionary *attachedScreenshot = nil;
  
  if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
  {
    interfaceOrientation = @"portrait";
    attachedScreenshot = attachedScreenshotPortrait;
  }
  else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
  {
    interfaceOrientation = @"landscape";
    attachedScreenshot = attachedScreenshotLandscape;     
  }
  
  for (NSNumber *num in attachedScreenshot) [completeSet addObject:num];
  
  for (int i = MAX(1, currentPageNumber - MAX_SCREENSHOT_BEFORE_CP); i <= MIN(totalPages, currentPageNumber + MAX_SCREENSHOT_AFTER_CP); i++)
  {
    NSNumber *num = [NSNumber numberWithInt:i];
    [supportSet addObject:num];
    
    if ([self checkScreeshotForPage:i andOrientation:interfaceOrientation] && ![attachedScreenshot objectForKey:num]) {            
      [self placeScreenshotForView:nil andPage:i andOrientation:interfaceOrientation];
      [completeSet addObject:num];
    }
  }
  
  [completeSet minusSet:supportSet];
  
  for (NSNumber *num in completeSet) {
    [[attachedScreenshot objectForKey:num] removeFromSuperview];
    [attachedScreenshot removeObjectForKey:num];
  }
  
}
- (BOOL)checkScreeshotForPage:(int)pageNumber andOrientation:(NSString *)interfaceOrientation {
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:cachedScreenshotsPath]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:cachedScreenshotsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [self addSkipBackupAttributeToItemAtPath:cachedScreenshotsPath];
  }
  
  NSString *screenshotFile = [cachedScreenshotsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"screenshot-%@-%i.jpg", interfaceOrientation, pageNumber]];
  return [[NSFileManager defaultManager] fileExistsAtPath:screenshotFile];
}
- (void)takeScreenshotFromView:(UIWebView *)webView forPage:(int)pageNumber andOrientation:(NSString *)interfaceOrientation {
  
  BOOL shouldRevealWebView = YES;
  BOOL animating = YES;
  
  if (![self checkScreeshotForPage:pageNumber andOrientation:interfaceOrientation])
  {        
    
    NSString *screenshotFile = [cachedScreenshotsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"screenshot-%@-%i.jpg", interfaceOrientation, pageNumber]];
    UIImage *screenshot = nil;
    
    if ([interfaceOrientation isEqualToString:[self getCurrentInterfaceOrientation]] && !currentPageHasChanged) {
      
      UIGraphicsBeginImageContextWithOptions(webView.frame.size, NO, [[UIScreen mainScreen] scale]);
      [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
      screenshot = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      
      if (screenshot) {
        BOOL saved = [UIImageJPEGRepresentation(screenshot, 0.6) writeToFile:screenshotFile options:NSDataWritingAtomic error:nil];
        if (saved) {
          [self placeScreenshotForView:webView andPage:pageNumber andOrientation:interfaceOrientation];
          shouldRevealWebView = NO;
        }
      }
    }
    
    [self performSelector:@selector(lockPage:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1];
  } 
  
  if (!currentPageHasChanged && shouldRevealWebView) {
    [self webView:webView hidden:NO animating:animating];
  }
}
- (void)placeScreenshotForView:(UIWebView *)webView andPage:(int)pageNumber andOrientation:(NSString *)interfaceOrientation {
  
  int i = pageNumber - 1;
  NSNumber *num = [NSNumber numberWithInt:pageNumber];
  
  NSString    *screenshotFile = [cachedScreenshotsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"screenshot-%@-%i.jpg", interfaceOrientation, pageNumber]];
  UIImageView *screenshotView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:screenshotFile]];
  
  NSMutableDictionary *attachedScreenshot = attachedScreenshotPortrait;
  CGSize pageSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height);
  
  if ([interfaceOrientation isEqualToString:@"landscape"]) {
    attachedScreenshot = attachedScreenshotLandscape;
    pageSize = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
  }
  
  screenshotView.frame = CGRectMake(pageSize.width * i, 0, pageSize.width, pageSize.height);
  
  BOOL alreadyPlaced = NO;
  UIImageView *oldScreenshot = [attachedScreenshot objectForKey:num];
  
  if (oldScreenshot) {
    [scrollView addSubview:screenshotView];        
    [attachedScreenshot removeObjectForKey:num];
    [oldScreenshot removeFromSuperview];
    
    alreadyPlaced = YES;
  }
  
  [attachedScreenshot setObject:screenshotView forKey:num];
  
  if (webView == nil)
  {
    screenshotView.alpha = 0.0;
    
    [scrollView addSubview:screenshotView];
    [UIView animateWithDuration:0.5 animations:^{ screenshotView.alpha = 1.0; }];
  }
  else if (webView != nil)
  {
    if (alreadyPlaced)
    {    
      [self webView:webView hidden:NO animating:NO];   
    }
    else if ([interfaceOrientation isEqualToString:[self getCurrentInterfaceOrientation]] && !currentPageHasChanged)
    {
      screenshotView.alpha = 0.0;
      
      [scrollView addSubview:screenshotView];
      [UIView animateWithDuration:0.5
                       animations:^{ screenshotView.alpha = 1.0; }
                       completion:^(BOOL finished) { if (!currentPageHasChanged) { [self webView:webView hidden:NO animating:NO]; }}];
    }
  }
  
}

#pragma mark - GESTURES
- (void)userDidTap:(UITouch *)touch {
	/****************************************************************************************************
   * This function handles all the possible user navigation taps:
   * up, down, left, right and double-tap.
   */
  
  CGPoint tapPoint = [touch locationInView:self.view];
  // Swipe or scroll the page.
  if (!currentPageIsLocked)
  {
    if (CGRectContainsPoint(upTapArea, tapPoint))
    {
      [self goUpInPage:@"1004" animating:YES];	
    }
    else if (CGRectContainsPoint(downTapArea, tapPoint))
    {
      [self goDownInPage:@"1004" animating:YES];	
    }
    else if (CGRectContainsPoint(leftTapArea, tapPoint) || CGRectContainsPoint(rightTapArea, tapPoint))
    {
      int page = 0;
      //            if (CGRectContainsPoint(leftTapArea, tapPoint)) 
      //            {
      //                page = currentPageNumber - 1;
      //            }
      //            else if (CGRectContainsPoint(rightTapArea, tapPoint))
      //            {
      //                page = currentPageNumber + 1;
      //            }
      if ((touch.tapCount%2) == 0)
      {
        [self toggleStatusBar];
      }
      
      if ([[properties get:@"-baker-page-turn-tap", nil] boolValue]) [self changePage:page];
      
    }
    else if ((touch.tapCount%2) == 0)
    {
      [self toggleStatusBar];
    }
  }
}
- (void)userDidScroll:(UITouch *)touch {
  //滑动时候隐藏上下View
	[self hideStatusBar];
  currPage.backgroundColor = webViewBackground;
  currPage.opaque = YES;
  self.navigationController.navigationBarHidden =YES;
}


#pragma mark - PAGE SCROLLING
- (void)getPageHeight {
	for (UIView *subview in currPage.subviews) {
		if ([subview isKindOfClass:[UIScrollView class]]) {
			CGSize size = ((UIScrollView *)subview).contentSize;
			currentPageHeight = size.height;
		}
	}
}
- (void)goUpInPage:(NSString *)offset animating:(BOOL)animating {
	
	NSString *currPageOffset = [currPage stringByEvaluatingJavaScriptFromString:@"window.scrollY;"];
	
	int currentPageOffset = [currPageOffset intValue];
	if (currentPageOffset > 0) {
		
		int targetOffset = currentPageOffset-[offset intValue];
		if (targetOffset < 0)
			targetOffset = 0;
		
		offset = [NSString stringWithFormat:@"%d", targetOffset];
		[self scrollPage:currPage to:offset animating:animating];
	}
}
- (void)goDownInPage:(NSString *)offset animating:(BOOL)animating {
	
	NSString *currPageOffset = [currPage stringByEvaluatingJavaScriptFromString:@"window.scrollY;"];
	
	int currentPageMaxScroll = currentPageHeight - pageHeight;
	int currentPageOffset = [currPageOffset intValue];
	
	if (currentPageOffset < currentPageMaxScroll) {
		
		int targetOffset = currentPageOffset+[offset intValue];
		if (targetOffset > currentPageMaxScroll)
			targetOffset = currentPageMaxScroll;
		
		
		offset = [NSString stringWithFormat:@"%d", targetOffset];
		[self scrollPage:currPage to:offset animating:animating];
	}
  
}
- (void)scrollPage:(UIWebView *)webView to:(NSString *)offset animating:(BOOL)animating {
  [self hideStatusBar];
	
	NSString *jsCommand = [NSString stringWithFormat:@"window.scrollTo(0,%@);", offset];
	if (animating) {
    [UIView animateWithDuration:0.35 animations:^{ [webView stringByEvaluatingJavaScriptFromString:jsCommand]; }];
	} else {
		[webView stringByEvaluatingJavaScriptFromString:jsCommand];
	}
}
- (void)handleAnchor:(BOOL)animating {
	if (anchorFromURL != nil) {
		NSString *jsAnchorHandler = [NSString stringWithFormat:@"(function() {\
                                 var target = '%@';\
                                 var elem = document.getElementById(target);\
                                 if (!elem) elem = document.getElementsByName(target)[0];\
                                 return elem.offsetTop;\
                                 })();", anchorFromURL];
		
		NSString *offset = [currPage stringByEvaluatingJavaScriptFromString:jsAnchorHandler];
		
		if (![offset isEqualToString:@""]) {
			[self goDownInPage:offset animating:animating];
    }
		anchorFromURL = nil;
	}
}

#pragma mark - STATUS BAR
- (void)toggleStatusBar {
  // if modal view is up, don't toggle.
  if (!self.modalViewController) {
    
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    BOOL hidden = sharedApplication.statusBarHidden;
    [sharedApplication setStatusBarHidden:!hidden withAnimation:UIStatusBarAnimationSlide];
    if(![indexViewController isDisabled]) {
      [indexViewController setIndexViewHidden:!hidden withAnimation:YES];
    }
    [topViewController setTopViewHidden:!hidden withAnimation:YES];
  }
  
}
- (void)hideStatusBar {
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
  if(![indexViewController isDisabled]) {
    [indexViewController setIndexViewHidden:YES withAnimation:YES];
  }
  
  [topViewController setTopViewHidden:YES withAnimation:YES];
  
}

#pragma mark - ORIENTATION
- (NSString *)getCurrentInterfaceOrientation {
  if ([availableOrientation isEqualToString:@"portrait"] || [availableOrientation isEqualToString:@"landscape"]||
      [availableOrientation isEqualToString:@"landscapeLeft"]||
      [availableOrientation isEqualToString:@"landscapeRight"])
  {
    return availableOrientation;
  } 
  else {
		// WARNING!!! Seems like checking [[UIDevice currentDevice] orientation] against "UIInterfaceOrientationPortrait" is broken (return FALSE with the device in portrait orientation)
		// Safe solution: always check if the device is in landscape orientation, if FALSE then it's in portrait.
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      return @"landscape";
    } else {
      return @"portrait";
    }
	}
}

- (BOOL)shouldAutorotate
{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Overriden to allow any orientation.
  CCLog(@"----------availableOrientation:%@",availableOrientation);
	if ([availableOrientation isEqualToString:@"portrait"]) {
		return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
	} else if ([availableOrientation isEqualToString:@"landscape"]) {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
	} else if([availableOrientation isEqualToString:@"landscapeLeft"]){
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
	} else if([availableOrientation isEqualToString:@"landscapeRight"]){
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
  } else{
    return YES;
  }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  // Notify the index view
  CCLog(@"----------Notify the index view  out");
  [indexViewController willRotate];
  [indexViewController willRotate];
  
  // Since the UIWebView doesn't handle orientationchange events correctly we have to do handle them ourselves 
  // 1. Set the correct value for window.orientation property
  NSString *jsOrientationGetter =@"";
  switch (toInterfaceOrientation) {
    case UIDeviceOrientationPortrait:
      jsOrientationGetter = @"window.__defineGetter__('orientation', function() { return 0; });";
      break;
    case UIDeviceOrientationLandscapeLeft:
      jsOrientationGetter = @"window.__defineGetter__('orientation', function() { return 90; });";
      break;
    case UIDeviceOrientationLandscapeRight:
      jsOrientationGetter = @"window.__defineGetter__('orientation', function() { return -90; });";
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      jsOrientationGetter = @"window.__defineGetter__('orientation', function() { return 180; });";
      break;
    default:
      break;
  }
  
  // 2. Create and dispatch a orientationchange event    
  NSString *jsOrientationChange = @"if (typeof bakerOrientationChangeEvent === 'undefined') {\
  var bakerOrientationChangeEvent = document.createEvent('Events');\
  bakerOrientationChangeEvent.initEvent('orientationchange', false, false);\
  }; window.dispatchEvent(bakerOrientationChangeEvent)";
  
  // 3. Merge the scripts and load them on the current UIWebView
  NSString *jsCommand = [jsOrientationGetter stringByAppendingString:jsOrientationChange];
  //stringByAppendingString 生成的是autorelease对象，所以jsOrientationGetter应该也必须是autorelease否则会内存泄露
  [currPage stringByEvaluatingJavaScriptFromString:jsCommand];
  
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [indexViewController rotateFromOrientation:fromInterfaceOrientation toOrientation:self.interfaceOrientation];
  [topViewController rotateFromOrientation:fromInterfaceOrientation toOrientation:self.interfaceOrientation];
  
  CCLog(@"---------currentOrientation:%@",[self getCurrentInterfaceOrientation]);
  [self setPageSize:[self getCurrentInterfaceOrientation]];
  [self getPageHeight];
	[self resetScrollView];
}

#pragma mark - MEMORY
- (void)didReceiveMemoryWarning {
  [iConsole warn:@"===didReceiveMemoryWarning===="];
  //  [self viewDidUnload];
  //  [self didHome:nil];
  
  CCLog(@"---------------------------BookViewController---------memoryWarning");
  [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {

  [iConsole log:@"===> bookview didunload"];

  [currPage loadHTMLString:@"about:blank" baseURL:nil];
  [nextPage loadHTMLString:@"about:blank" baseURL:nil];
  [prevPage loadHTMLString:@"about:blank" baseURL:nil];
  
  [currPage stopLoading];
  [nextPage stopLoading];
  [prevPage stopLoading];
  
  currPage.delegate = nil;
	nextPage.delegate = nil;
	prevPage.delegate = nil;
  
  [currPage removeFromSuperview];
  [nextPage removeFromSuperview];
  [prevPage removeFromSuperview];
  
  currPage = nil;
  nextPage = nil;
  prevPage = nil;
  scrollView = nil;
  
  scrollView = nil;
  [scrollView removeFromSuperview];
  
  indexViewController = nil;
  topViewController = nil;
  
  [indexViewController removeFromParentViewController];
  [topViewController removeFromParentViewController];
  
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
  [super viewDidUnload];
}

- (NSString *)getBookName{
  
  NSString *name = nil;
  if ([[NSFileManager defaultManager] fileExistsAtPath:cachesBookPath]) {
    name = [cachesBookPath lastPathComponent];
  } else {
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundleBookPath]) {
      name = [bundleBookPath lastPathComponent];
    } else {
      // Do something if there are no books available to show
    }
  }
  
  return name;
}

#pragma mark - INDEX VIEW
- (BOOL)isIndexView:(UIWebView *)webView {
  if (webView == indexViewController.view) {
    return YES;
  } else {
    return NO;
  }
}

// ***********************top 操作区
- (void)didHome:(id)sender{
  
  [self viewDidUnload];
  [self dismissModalViewControllerAnimated:YES];
}

-(void) didDraw:(id)sender{
  [self toggleStatusBar];
  UIImage* image = nil;
  UIScrollView *_scrollView = nil;
  
  for (UIView *_aView in [self.currPage subviews]){
    //禁用uiwebview滚动
    if ([[_aView class] isSubclassOfClass: [UIScrollView class]]){
      _scrollView = (UIScrollView *)_aView;
    }
  }
  
  UIGraphicsBeginImageContext(_scrollView.contentSize);
  {
    CGPoint savedContentOffset = _scrollView.contentOffset;
    CGRect savedFrame = _scrollView.frame;
    
    _scrollView.contentOffset = CGPointZero;
    _scrollView.frame = CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height);
    
    [_scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    _scrollView.contentOffset = savedContentOffset;
    _scrollView.frame = savedFrame;
  }
  UIGraphicsEndImageContext();
  
  NSData *data= UIImageJPEGRepresentation(image, 0.8);
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSString *filePath = [NSString stringWithFormat:@"%@/%@%@",CACHE_PATH,[Utils getDateString],@".jpg"];
  
  if (![fileManager fileExistsAtPath:filePath]){
    [data writeToFile:filePath atomically:NO];
  }
  
  DrawViewController *drawView =[[DrawViewController alloc] initWithNibName:@"DrawViewController" bundle:nil];
  [drawView setCurImageFilePath:filePath];
  [self presentModalViewController:drawView animated:YES];
  
}

//点击显示二维码
- (void)didTwoCode:(id)sender{
  //显示二维码
  towCodeAlert =[[TowCodeAlertView alloc] initWithContentImage:[Util getShareTwoCode:currentBook.downnum]];
  [towCodeAlert setDelegate:self];
  [towCodeAlert show];
}

#pragma -mark TowCodeAlertDelegate
- (void)closeTowCodeAlert{
  towCodeAlert =nil;
}

//点击分享
- (void)didShare:(id)sender{
  //book 的pdf操作
  NSMutableString *pdfDownUrl = [[NSMutableString alloc] initWithString:BASE_URL];
  
  NSString *pdfRequest = [NSString stringWithFormat:@"%@bookid='%@'",PDFREQUEST,currentBook.downnum];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:pdfRequest] cachePolicy:0 timeoutInterval:10];
  [request setHTTPMethod:@"GET"];
  
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
  
  NSDictionary *json = [data objectFromJSONData];
  
  if (json != nil) {
    [pdfDownUrl appendString:[json objectForKey:@"pdfUrl"]];
  }

  actionSheet =[ShareActionSheet actionSheetForTarget:self
                                                              sendImage:[Util getShareTwoCode:currentBook.downnum]
                                                                sendPdf:pdfDownUrl
                                                            sendPdfName:currentBook.name
                bookShareUrl:[Util getShareTwoCodeUrlString:currentBook.downnum]];
  
  [actionSheet setMailDelegate:self];
  [actionSheet showInView:self.view];
}

#pragma mark -SendMailDelegate
- (void)didSendMailFailure{
  CCLog(@"send mail failure");
  [self showMessage:@"邮件发送失败"];
}

- (void)didSendMailFinished{
  CCLog(@"send mail finished");
  [self showMessage:@"分享邮件发送成功"];
}

- (void)didSendMailCancelled{
  CCLog(@"send mail cancelled");
}

- (void)didSaveMailFinished{
  CCLog(@"send mail save Finished");
  [self showMessage:@"邮件保存成功"];
}

- (void)notOpenMail{
  CCLog(@"not open mail");
  [self showMessage:@"添加本地Email账户后才可以发送邮件"];
}

@end
