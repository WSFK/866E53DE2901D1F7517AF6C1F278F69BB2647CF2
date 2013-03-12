//
//  UIViewController_Extension.h
//  handbooklite
//
//  Created by bao_wsfk on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//这里是对UIViewController的扩展

#import <UIKit/UIKit.h>
#import "iToast.h"
#import "AppDelegate.h"

@interface UIViewController (UIViewController_Extension)

//根据字符串 获取屏幕方向
- (BOOL)orientationByString:(NSString *) orientation InterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)showMessage:(NSString *)message;

- (void)showWaitting;
- (void)dismissWaitting;

@end

@implementation UIViewController (UIViewController_Extension)

- (BOOL)orientationByString:(NSString *) orientation InterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    if ([@"landscape" isEqualToString:orientation]) {
        
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
    if ([@"portrait" isEqualToString:orientation]) {
        
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }
    else {
        return YES;
    }
}

- (void)showMessage:(NSString *)message{
    iToast *toast = [iToast makeToast:message];
    [toast setToastPosition:kToastPositionBottom];
    [toast setToastDuration:kToastDurationNormal];
    [toast show];
}

- (void)showWaitting{
    AppDelegate *delegate =(id)[UIApplication sharedApplication].delegate;
    [delegate showWaitting];
}

- (void)dismissWaitting{
    AppDelegate *delegate =(id)[UIApplication sharedApplication].delegate;
    [delegate dismissWaitting];
}

//- (void)viewDidLoad{
//    [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"sm.png"] forBarMetrics:UIBarMetricsDefault];
//}

@end