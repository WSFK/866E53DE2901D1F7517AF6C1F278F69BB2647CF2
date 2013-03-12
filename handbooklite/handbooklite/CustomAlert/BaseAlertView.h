//
//  BaseAlertView.h
//  handbooklite
//
//  Created by bao_wsfk on 12-11-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseAlertView : UIAlertView{
    
    UIImage *backgroundImage;
    
    BOOL isShowIng;
    BOOL isKeyboardShow;
}
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) BOOL isShowIng;
@property (nonatomic, assign) BOOL isKeyboardShow;

- (id)initWithBackgroundImage:(UIImage *)image;

- (void)dismiss;
@end
