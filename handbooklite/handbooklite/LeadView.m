//
//  LeadView.m
//  leadPage
//
//  Created by bao_wsfk on 13-4-17.
//  Copyright (c) 2013年 bao_wsfk. All rights reserved.
//

#import "LeadView.h"

@implementation LeadView

@synthesize scrollView,button,delegate;

- (id)initWithFrame:(CGRect)frame withImageNames:(NSArray *)imgNames
{
    self = [super initWithFrame:frame];
    if (self) {
        
        scrollView =[[UIScrollView alloc] initWithFrame:frame];
        [scrollView setDelegate:self];
        [scrollView setDirectionalLockEnabled:YES];
        [scrollView setBounces:NO];
        [scrollView setAlwaysBounceVertical:NO];
        [scrollView setAlwaysBounceHorizontal:NO];
        [scrollView setPagingEnabled:YES];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:scrollView];
        
        viewWidth =frame.size.width;
        viewHeight =frame.size.height;
        imageNames =imgNames;
        
        pageControl =[[UIPageControl alloc] init];
        [pageControl setBackgroundColor:[UIColor clearColor]];
        [pageControl setFrame:CGRectMake((viewWidth-150)/2, (viewHeight-30)*6/7, 150, 30)];
        [pageControl setNumberOfPages:[imageNames count]];
        [pageControl setCurrentPage:0];
        [pageControl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
        
        //取消按钮
        button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(935, 0, 85, 85)];
        [button setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        [self initLeadView];
    }
    return self;
}

- (void)changePage{
    
    int page =[pageControl currentPage];
    NSLog(@"---page:%i",page);
    [scrollView setContentOffset:CGPointMake(page*viewWidth, 0) animated:YES];
}

- (void)clickCancel{
    if ([delegate respondsToSelector:@selector(leadViewCancel)]) {
        [delegate performSelector:@selector(leadViewCancel)];
    }
}

- (void)initLeadView{
    
    __block float contentViewWidth =viewHeight;
    [imageNames enumerateObjectsUsingBlock:^(__strong id obj,NSUInteger index,BOOL *stop){
        NSString *imageName =obj;
        UIImageView *imageView =[[UIImageView alloc]
                                 initWithImage:[UIImage imageNamed:imageName]];
        [imageView setFrame:CGRectMake(index*viewWidth, 0, viewWidth, viewHeight)];
        [scrollView addSubview:imageView];
        contentViewWidth =index*viewWidth +viewWidth;
    }];
    [scrollView setContentSize:CGSizeMake(contentViewWidth, viewHeight)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGPoint point =[self.scrollView contentOffset];
    int currentPageNo = point.x/viewWidth;
    [pageControl setCurrentPage:currentPageNo];
}


- (void)dealloc{
    imageNames =nil;
    scrollView =nil;
}

@end
