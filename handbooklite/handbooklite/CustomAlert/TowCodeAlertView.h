//
//  TowCodeAlertView.h
//  Test
//
//  Created by bao_wsfk on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAlertView.h"

@protocol TowCodeAlertDelegate <NSObject>

@required
- (void)closeTowCodeAlert;

@end

@interface TowCodeAlertView : BaseAlertView{
    
    UIImage *contentImage;
    
    id<TowCodeAlertDelegate> delegate;
}
@property (readwrite, retain) UIImage *contentImage;

@property (nonatomic, assign) id<TowCodeAlertDelegate> delegate;

- (id)initWithContentImage:(UIImage *)image;

@end
