//
//  ContactUsViewController.h
//  handbooklite
//
//  Created by bao_wsfk on 12-9-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController_Extension.h"

@interface ContactUsViewController : UIViewController{
    
    BOOL _isHidden;
    IBOutlet UILabel *_lbTitle;
    IBOutlet UILabel *_lbAddr;
    IBOutlet UILabel *_lbwanzhi;
    IBOutlet UILabel *_lbPhone;
    IBOutlet UILabel *_lbEmail;
    
}
@property (nonatomic, assign) BOOL isHidden;

@property (nonatomic, strong) UILabel *lbTitle;
@property (nonatomic, strong) UILabel *lbAddr;
@property (nonatomic, strong) UILabel *lbwanzhi;
@property (nonatomic, strong) UILabel *lbPhone;
@property (nonatomic, strong) UILabel *lbEmail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (void)setViewHidden:(BOOL)hidden withAnimation:(BOOL)animation;

- (IBAction)clickCancellSelector:(id)sender;

@end
