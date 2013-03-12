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

@class BookShelfViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate,iConsoleDelegate>{
  NSTimer *timer;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BookShelfViewController *bookShelfViewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (readonly, nonatomic) WaitAlertView *waitAlert;

- (void)showWaitting;
- (void)dismissWaitting;

@end
