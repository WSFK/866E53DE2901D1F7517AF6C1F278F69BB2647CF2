//
//  DownloadListViewController.m
//  handbooklite
//
//  Created by bao_wsfk on 12-12-11.
//
//

#import "DownloadListViewController.h"
#import "DBUtils.h"
#import "Temp.h"

@interface DownloadListViewController ()

@end

@implementation DownloadListViewController

@synthesize isHidden,delegate;

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
    
    self.view = [[UIView alloc] init];
    [self.view setFrame:CGRectMake(0, 0, 464, 748)];
    
    isHidden =NO;
    
    backgroundImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downloadlist.png"]];
    [backgroundImageView setFrame:self.view.frame];
    [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.view addSubview:backgroundImageView];
    
    listView = [[UITableView alloc] initWithFrame:CGRectMake(100, 20, 344, 666)
                                            style:UITableViewStylePlain];
    [listView setDataSource:self];
    [listView setDelegate:self];
    [listView setSeparatorColor:[UIColor lightGrayColor]];
    [listView setBackgroundColor:[UIColor clearColor]];
    
    //编辑按钮
    UIButton *editBtn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [editBtn setTitle:@"编 辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [editBtn.titleLabel setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [editBtn setFrame:CGRectMake(230, 700, 80, 31)];
    [editBtn addTarget:self action:@selector(clickEditSelector) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];
    
    [self.view addSubview:listView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setViewHidden:(BOOL)hidden withAnimation:(BOOL)animation{
    
    CGRect frame;
    isHidden =hidden;
    if (hidden) {
        frame =CGRectMake(0, 0, -464, 748);
        [listView setEditing:NO animated:YES];
    }
    else {
        frame =CGRectMake(0, 0, 464, 748);
        [self updateBookTemps];
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

- (void)clickEditSelector{
    [listView setEditing:!listView.editing animated:YES];
}

- (void)updateBookTemps{
    
    if (bookTemps) {
        [bookTemps removeAllObjects],bookTemps =nil;
    }
    bookTemps = [DBUtils queryAllTemps];
    [listView reloadData];
}

#pragma -mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [bookTemps count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identify =@"downloadCell";
    DownloadListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[DownloadListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identify];
        [cell setDelegate:self];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Temp *temp =[bookTemps objectAtIndex:indexPath.row];
    
    NSString *name =[temp name]==nil?@"————":[temp name];
    [cell.bookTitleView setText:name];
    [cell.bookDownnumView setText:[temp downnum]];
    [cell.saveDateView setText:[temp stringSaveDate]];
    [cell setTempId:[temp ID]];
    temp =nil;
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadListCell *cell =(DownloadListCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isDownloading]) {
        return NO;
    }
    //编辑状态下载按钮不可用
    [cell.downloadBtn setEnabled:!tableView.editing];
    [cell.downloadBtn setHidden:tableView.editing];
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        //开始删除
        DownloadListCell *cell =(DownloadListCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([DBUtils deleteTempById:cell.tempId]) {
            [bookTemps removeObjectAtIndex:indexPath.row];
            [listView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}


#pragma -mark DownloadListCellDelegate
- (void)didDownloadBookFailedWidthError:(NSString *)error{
    
    //刷新列表
    [self updateBookTemps];
    [self showMessage:error];
}

- (void)didDownloadBookSuccess{
    //刷新列表
    [self updateBookTemps];
    if ([delegate respondsToSelector:@selector(didDownloadFinished)]) {
        [delegate performSelector:@selector(didDownloadFinished)];
    }
}

@end
