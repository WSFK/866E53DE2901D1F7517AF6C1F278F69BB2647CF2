//
//  DownloadAlertView.h
//  handbooklite
//
//  Created by bao_wsfk on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAlertView.h"

@protocol DownloadAlertViewDelegate <NSObject>

@required
- (void)goPhotoView;

@required
- (void)commitWithText:(NSString *)text;

@required
- (void)cancelPhoto;

@end

@interface DownloadAlertView : BaseAlertView{
    
    id<DownloadAlertViewDelegate> __weak delegate;
    
    UITextField *tf_text;
}
@property (nonatomic, weak) id<DownloadAlertViewDelegate> delegate;

@property (nonatomic, strong) UITextField *tf_text;


- (id)initWithImage:(UIImage *)image;

@end
