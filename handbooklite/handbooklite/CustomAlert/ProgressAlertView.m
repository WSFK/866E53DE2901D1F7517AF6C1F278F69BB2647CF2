//
//  ProgressAlertView.m
//  Test
//
//  Created by bao_wsfk on 12-10-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ProgressAlertView.h"

@implementation ProgressAlertView

@synthesize progressView;

- (id)init{
  self =[super initWithBackgroundImage:[UIImage imageNamed:@"alert.png"]];
//    if (self ==[super initWithBackgroundImage:[UIImage imageNamed:@"alert.png"]])
//    {
  
        progressView =[[UIProgressView alloc] initWithFrame:CGRectNull];
        
        [progressView setProgress:0.0f];
        [progressView setProgressViewStyle:UIProgressViewStyleDefault];
        [progressView setProgressTintColor:[UIColor greenColor]];
        [progressView setTrackTintColor:[UIColor whiteColor]];
//    }
    return self;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if (isShowIng) {
        return;
    }
    
    [progressView setFrame:CGRectMake(106, 
                                      self.frame.size.height/3, 
                                      300, 
                                      20)];
    [self addSubview:progressView];

    UIActivityIndicatorView *progressInd =[[UIActivityIndicatorView alloc]
                                           initWithFrame:CGRectMake(
                                                                    240,
                                                                    self.frame.size.height/2, 
                                                                    32.0f, 
                                                                    32.0f)];
    [progressInd startAnimating];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self addSubview:progressInd];
    
    isShowIng =YES;
    
}


- (UIProgressView *)showPrg{
    [super show];
    return progressView;
}


@end
