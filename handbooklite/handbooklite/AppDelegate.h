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

#define kAppKey             @"1655018151"
#define kAppSecret          @"37f2f7cf376a99489e4158ea805e14ab"
#define kAppRedirectURI     @"http://www.sina.com"

@class BookShelfViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,iConsoleDelegate>{
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
