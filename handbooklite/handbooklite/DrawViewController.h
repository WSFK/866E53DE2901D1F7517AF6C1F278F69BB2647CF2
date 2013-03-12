//
//  DrawViewController.h
//  handbooklite
//
//  Created by bao_wsfk on 13-1-10.
//
//

#import <UIKit/UIKit.h>
#import "UIViewController_Extension.h"
#import "PaintView.h"

@interface DrawViewController : UIViewController{
    
    PaintView *paintView;
    
    NSString *curImageFilePath;
    
    
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIButton *editBtn;
}

@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UIButton *editBtn;
@property (nonatomic, copy)NSString *curImageFilePath;

- (IBAction)clickCleanScreen:(id)sender;

- (IBAction)clickSave:(id)sender;

- (IBAction)clickEdit:(id)sender;

- (IBAction)clickBackUp:(id)sender;

- (IBAction)clickCancel:(id)sender;

@end
