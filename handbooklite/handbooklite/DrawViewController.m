//
//  DrawViewController.m
//  handbooklite
//
//  Created by bao_wsfk on 13-1-10.
//
//

#import "DrawViewController.h"
#import "Config.h"

@interface DrawViewController ()

@end

@implementation DrawViewController

@synthesize scrollView,editBtn,curImageFilePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *image =[UIImage imageWithContentsOfFile:curImageFilePath];
    
    paintView =[[PaintView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)
                                       andImage:curImageFilePath];
    
    [self.scrollView addSubview:paintView];
    [self.scrollView setContentSize:paintView.bounds.size];
    [self.scrollView setScrollEnabled:NO];
    [self.editBtn setTitle:@"浏览" forState:UIControlStateNormal];
    [self.editBtn setImage:[UIImage imageNamed:@"btn-see.png"] forState:UIControlStateNormal];
    [self.scrollView setContentOffset:self.scrollView.contentOffset animated:YES];
    [self.scrollView setDelaysContentTouches:NO];
}

-(void) dealloc{
  paintView =nil;
  scrollView =nil;
  editBtn =nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self clickCancel:nil];
    CCLog(@"---------------------------DrawViewController---------memoryWarning");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [self orientationByString:ORIENTATION InterfaceOrientation:interfaceOrientation];
}

- (void)clickCleanScreen:(id)sender{
    [paintView cleanScreen];
}

- (void)clickSave:(id)sender{
    [paintView save];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示！"
                                                   message:@"成功保存到相册"
                                                  delegate:self
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

- (void)clickEdit:(id)sender{
    
    [self.scrollView setScrollEnabled:!self.scrollView.scrollEnabled];
    [paintView setIsEdit:!paintView.isEdit];
    if (!paintView.isEdit) {
        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self.editBtn setImage:[UIImage imageNamed:@"btn-edit.png"] forState:UIControlStateNormal];
        [self.scrollView setDelaysContentTouches:YES];
    }else{
        [self.editBtn setTitle:@"浏览" forState:UIControlStateNormal];
        [self.editBtn setImage:[UIImage imageNamed:@"btn-see.png"] forState:UIControlStateNormal];
        [self.scrollView setContentOffset:self.scrollView.contentOffset animated:YES];
        [self.scrollView setDelaysContentTouches:NO];
    }
    
}

- (void)clickBackUp:(id)sender{
    [paintView backUp];
}

- (void)clickCancel:(id)sender{
  [paintView endDraw];
    //删除缓存图片
    NSFileManager *fm =[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:curImageFilePath]) {
        [fm removeItemAtPath:curImageFilePath error:nil];
    }
    [self dismissModalViewControllerAnimated:YES];
}



@end
