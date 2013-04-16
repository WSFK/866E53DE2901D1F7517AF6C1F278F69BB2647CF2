//
//  CProgress.h
//  progressbar
//
//  Created by han on 13-4-16.
//
//

#import <UIKit/UIKit.h>

@interface CProgress : UIView{
  UIImageView *grayView;
}

- (void)setProgress:(float)progress animated:(BOOL)animated NS_AVAILABLE_IOS(5_0);

- (void)setProgress:(float)progress;
@end
