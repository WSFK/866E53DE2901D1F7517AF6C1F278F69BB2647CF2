//
//  PaintView.h
//  handbooklite
//
//  Created by bao_wsfk on 13-1-10.
//
//

#import <UIKit/UIKit.h>
#import "PathUtils.h"

@interface PaintView : UIView{
    
@private
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
    CGFloat lineWidth;
    UIColor *lineColor;
  NSString *baseImagePath;
    UIImage *curImage;
    NSMutableArray *historyDraws;
    
    BOOL isEdit;
}

@property (nonatomic, strong) UIColor *lineColor;
@property (readwrite) CGFloat lineWidth;
@property (nonatomic, assign) BOOL isEdit;

- (id)initWithFrame:(CGRect)frame andImage:(NSString *)imagePath;

- (void)cleanScreen;

- (void)save;

- (void)backUp;

-(void) endDraw;
@end
