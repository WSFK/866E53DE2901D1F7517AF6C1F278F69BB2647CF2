//
//  TopViewController.m
//  Test
//
//  Created by bao_wsfk on 12-9-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopViewController.h"

@interface TopViewController ()

@end

@implementation TopViewController

@synthesize titleView =_titleView;
@synthesize lbHome =_lbHome;
@synthesize lbDraw =_lbDraw;
@synthesize lbTwoCode =_lbTwoCode;
@synthesize lbShare =_lbShare;

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil book:(Book *)book{
    
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        currentBook =book;
    }
    return self;
}

- (void)viewDidLoad
{
    [_titleView setFont:DEFAULT_FONT(20)];
    [_titleView setTextAlignment:UITextAlignmentLeft];
    [_titleView setTextColor:[UIColor whiteColor]];
    [_titleView setText:[currentBook name]];
    
    [_lbHome setText:@"首页"];
    [_lbHome setFont:DEFAULT_FONT(DEFAULT_BUTTON_FONT_SIZE)];
    [_lbHome setTextAlignment:UITextAlignmentCenter];
    [_lbHome setTextColor:[UIColor whiteColor]];
    
    [_lbDraw setText:@"绘图"];
    [_lbDraw setFont:DEFAULT_FONT(DEFAULT_BUTTON_FONT_SIZE)];
    [_lbDraw setTextColor:[UIColor whiteColor]];
    [_lbDraw setTextAlignment:UITextAlignmentCenter];
    
    [_lbTwoCode setText:@"二维码"];
    [_lbTwoCode setFont:DEFAULT_FONT(DEFAULT_BUTTON_FONT_SIZE)];
    [_lbTwoCode setTextColor:[UIColor whiteColor]];
    [_lbTwoCode setTextAlignment:UITextAlignmentCenter];
    
    [_lbShare setText:@"分享"];
    [_lbShare setFont:DEFAULT_FONT(DEFAULT_BUTTON_FONT_SIZE)];
    [_lbShare setTextColor:[UIColor whiteColor]];
    [_lbShare setTextAlignment:UITextAlignmentCenter];
    
    _topWidth =1024;
    _topHeight =93;
    _topY = 0;
    _y = - (_topHeight+_topY);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"top.png"]]];
    [self.view setFrame:CGRectMake(0, _y, _topWidth, _topHeight)];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.titleView =nil;
    self.lbHome =nil;
    self.lbDraw =nil;
    self.lbTwoCode =nil;
    self.lbShare =nil;
    currentBook =nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)setTopViewHidden:(BOOL)hidden withAnimation:(BOOL)animation{
    
    if (hidden) {
        _y = - _topHeight-40;
    }
    else {
        _y =_topY;
    }
    
    CGRect frame =CGRectMake(0, _y+20, _topWidth, _topHeight);
    
    if (animation) {
        [UIView beginAnimations:@"slideTopView" context:nil]; {
            [UIView setAnimationDuration:0.3];
            
            [self.view setFrame:frame];
        }
        [UIView commitAnimations];//提交动画
    } else {
        [self.view setFrame:frame];
    }
}

- (void)fadeOut {
    [UIView beginAnimations:@"fadeOutTopView" context:nil]; {
        [UIView setAnimationDuration:0.1];
        self.view.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)fadeIn {
    [UIView beginAnimations:@"fadeInTopView" context:nil]; {
        [UIView setAnimationDuration:0.2];
        
        self.view.alpha = 1.0;
    }
    [UIView commitAnimations];
}

- (void)setPageSizeForOrientation:(UIInterfaceOrientation)orientation{
    
    CGRect screen =[[UIScreen mainScreen] bounds];
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		_topWidth = screen.size.height;
        
    } else {
        _topWidth = screen.size.width;

	}
    
    if ([self isTopViewHidden]) {
        //_topY = 20;
    } else {
        _topY = -20;
    }

}

- (void)willRotate{
    [self fadeOut];
}

- (void)rotateFromOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
                toOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL hidden = [self isTopViewHidden];
    
    [self setPageSizeForOrientation:toInterfaceOrientation];
    [self setTopViewHidden:hidden withAnimation:NO];
    [self fadeIn];
}

- (BOOL)isTopViewHidden {
    return [UIApplication sharedApplication].statusBarHidden;
}

- (void)clickHomeSelector:(id)sender{
    if ([delegate respondsToSelector:@selector(didHome:)]) {
        [delegate performSelector:@selector(didHome:) withObject:nil];
    }
}

- (IBAction)clickDraw:(id)sender{
    if ([delegate respondsToSelector:@selector(didDraw:)]) {
        [delegate performSelector:@selector(didDraw:) withObject:nil];
    }
}

- (void)clickTwoCodeSelector:(id)sender{
    
    if ([delegate respondsToSelector:@selector(didTwoCode:)]) {
        [delegate performSelector:@selector(didTwoCode:) withObject:sender];
    }
}

- (void)clickShareSelector:(id)sender{
  //判断有无网络
  if (![NetWorkCheck checkReachable]) {
    [self showMessage:@"当前不能连接服务器"];
    return;
  }

    if ([delegate respondsToSelector:@selector(didShare:)]) {
        [delegate performSelector:@selector(didShare:) withObject:sender];
    }
}

@end
