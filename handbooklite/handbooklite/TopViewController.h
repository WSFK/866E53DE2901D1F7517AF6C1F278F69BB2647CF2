//
//  TopViewController.h
//  Test
//
//  Created by bao_wsfk on 12-9-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@protocol TopViewDelegate <NSObject>

@required
- (void)didHome:(id)sender;
- (void)didDraw:(id)sender;
- (void)didTwoCode:(id)sender;
- (void)didShare:(id)sender;

@end

@interface TopViewController : UIViewController{
    
    int _topWidth;
    int _topHeight;
    int _y;
    int _topY;
    
    IBOutlet UILabel *_titleView;
    IBOutlet UILabel *_lbHome;//首页
    IBOutlet UILabel *_lbDraw;//绘图
    IBOutlet UILabel *_lbTwoCode;//二维码
    IBOutlet UILabel *_lbShare;//分享
    
    id<TopViewDelegate> __weak delegate;
    
    Book *currentBook;
    
}
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UILabel *lbHome;
@property (nonatomic, strong) UILabel *lbDraw;
@property (nonatomic, strong) UILabel *lbTwoCode;
@property (nonatomic, strong) UILabel *lbShare;


@property (nonatomic, weak) id<TopViewDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil book:(Book *)book;

- (void)setTopViewHidden:(BOOL)hidden withAnimation:(BOOL)animation;
- (void)fadeOut;
- (void)fadeIn;
- (void)willRotate;
- (void)rotateFromOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
                toOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

- (void)setPageSizeForOrientation:(UIInterfaceOrientation)orientation;

- (IBAction)clickHomeSelector:(id)sender;
- (IBAction)clickDraw:(id)sender;

- (IBAction)clickTwoCodeSelector:(id)sender;
- (IBAction)clickShareSelector:(id)sender;

@end
