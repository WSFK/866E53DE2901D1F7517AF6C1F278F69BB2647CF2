//
//  AppDelegate.h
//  handbooklite
//
//  Created by bao_wsfk on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitAlertView.h"
#import "iConsole.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "SinaWeibo.h"
#import "WXApi.h"

#define kAppKey             @"1655018151"
#define kAppSecret          @"37f2f7cf376a99489e4158ea805e14ab"
#define kAppRedirectURI     @"http://www.sina.com"

#define WEI_XIN_APP_ID          @"wx2742a9a5e76088e2"
#define WEI_XIN_APP_KEY         @"2bd1aaa1672846edeeae34d5473d20b5"

@class BookShelfViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,iConsoleDelegate,WXApiDelegate>{
  NSTimer *timer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BookShelfViewController *bookShelfViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (readonly, nonatomic) WaitAlertView *waitAlert;
@property (readonly, nonatomic) SinaWeibo *sinaweibo;

- (void)showWaitting;
- (void)dismissWaitting;

@end
