//
//  ContactUsViewController.m
//  handbooklite
//
//  Created by bao_wsfk on 12-9-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContactUsViewController.h"
#import "Config.h"

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController

@synthesize isHidden = _isHidden;
@synthesize lbTitle =_lbTitle;
@synthesize lbAddr =_lbAddr;
@synthesize lbEmail =_lbEmail;
@synthesize lbwanzhi =_lbwanzhi;
@synthesize lbPhone =_lbPhone;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [self.lbTitle setFont:[UIFont fontWithName:@"Microsoft YaHei" size:25]];
    [self.lbAddr setFont:[UIFont fontWithName:@"Microsoft YaHei" size:15]];
    [self.lbPhone setFont:[UIFont fontWithName:@"Microsoft YaHei" size:15]];
    [self.lbEmail setFont:[UIFont fontWithName:@"Microsoft YaHei" size:15]];
    [self.lbwanzhi setFont:[UIFont fontWithName:@"Microsoft YaHei" size:15]];
    
    [self setIsHidden:YES];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [self orientationByString:ORIENTATION InterfaceOrientation:interfaceOrientation];
}

- (void)setViewHidden:(BOOL)hidden withAnimation:(BOOL)animation{
    
    CGRect screen =[[UIScreen mainScreen] bounds];
    
    CGRect frame;
    int viewWidth =self.view.frame.size.width;
    if (hidden) {
        frame =CGRectMake(screen.size.height, 
                          0, 
                          self.view.frame.size.width,
                          self.view.frame.size.height);
        [self setIsHidden:YES];
    }else {
        frame =CGRectMake(screen.size.height-viewWidth,
                          0,
                          self.view.frame.size.width, 
                          self.view.frame.size.height);
        [self setIsHidden:NO];
    }
    
    
    if (animation) {
        [UIView beginAnimations:@"slideView" context:nil]; {
            [UIView setAnimationDuration:0.3];
            
            [self.view setFrame:frame];
        }
        [UIView commitAnimations];//提交动画
    } else {
        [self.view setFrame:frame];
    }
    
}

- (void)clickCancellSelector:(id)sender{
    [self setViewHidden:YES withAnimation:YES];
}

@end
