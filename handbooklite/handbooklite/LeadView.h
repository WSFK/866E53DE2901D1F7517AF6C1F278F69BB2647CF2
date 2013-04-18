//
//  LeadView.h
//  leadPage
//
//  Created by bao_wsfk on 13-4-17.
//  Copyright (c) 2013年 bao_wsfk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeadViewDelegate <NSObject>
- (void)leadViewCancel;
@end

@interface LeadView : UIView<UIScrollViewDelegate>{
    
    @private
    float viewWidth;
    float viewHeight;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSArray *imageNames;
    
    UIButton *button;
}
@property (nonatomic,strong,readonly) UIScrollView *scrollView;
@property (nonatomic,strong,readonly) UIButton *button;
@property (nonatomic,assign) id<LeadViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withImageNames:(NSArray *)imgNames;
@end
