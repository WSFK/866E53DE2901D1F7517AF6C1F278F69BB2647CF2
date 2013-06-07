//
//  CProgress.m
//  progressbar
//
//  Created by han on 13-4-16.
//
//

#import "CProgress.h"

@implementation CProgress

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
  [self setBackgroundColor:[UIColor clearColor]];
  grayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
  [grayView setBackgroundColor:[UIColor grayColor]];
  [grayView setAlpha:PROGRESS_ALPHA_DEFAULT];
  [self addSubview:grayView];
    return self;
}

- (void)setProgress:(float)progress animated:(BOOL)animated NS_AVAILABLE_IOS(5_0){
  NSNumber *prg = [NSNumber numberWithFloat:progress];
  [self performSelector:@selector(resetProgress:) withObject:prg afterDelay:.1];
}

- (void)setProgress:(float)progress{
  NSNumber *prg = [NSNumber numberWithFloat:progress];
  [self performSelector:@selector(resetProgress:) withObject:prg afterDelay:.1];
}


-(void) resetProgress:(NSNumber *)prg{
  float progress = [prg floatValue];
  [UIView beginAnimations:@"slideView" context:nil];
  [UIView setAnimationDuration:0.1];
  CGRect rect = self.frame;
  float dheight = rect.size.height * progress;
  [grayView setFrame:CGRectMake(0, dheight, rect.size.width, rect.size.height - dheight)];
  [UIView commitAnimations];//提交动画
  
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end
