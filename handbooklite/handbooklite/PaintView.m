//
//  PaintView.m
//  handbooklite
//
//  Created by bao_wsfk on 13-1-10.
//
//

#import "PaintView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_COLOR [UIColor blackColor]
#define DEFAULT_WIDTH 5.0f

@interface PaintView ()

#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2);

@end

@implementation PaintView

@synthesize lineColor,lineWidth,isEdit;

#pragma mark -

-(void)setup
{
    self.lineWidth = DEFAULT_WIDTH;
    self.lineColor = DEFAULT_COLOR;
    isEdit = YES;
}

- (id)initWithFrame:(CGRect)frame andImage:(NSString *)imagePath
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        curImage =[UIImage imageWithContentsOfFile:imagePath];
      baseImagePath = imagePath;
        historyDraws =[[NSMutableArray alloc] init];
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (isEdit) {
        UITouch *touch = [touches anyObject];
        previousPoint1 = [touch previousLocationInView:self];
        previousPoint2 = [touch previousLocationInView:self];
        currentPoint = [touch locationInView:self];
        
        [self touchesMoved:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (isEdit) {
        UITouch *touch  = [touches anyObject];
        
        previousPoint2  = previousPoint1;
        previousPoint1  = [touch previousLocationInView:self];
        currentPoint    = [touch locationInView:self];
        
        // calculate mid point
        CGPoint mid1    = midPoint(previousPoint1, previousPoint2);
        CGPoint mid2    = midPoint(currentPoint, previousPoint1);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(path, NULL, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
        CGRect bounds = CGPathGetBoundingBox(path);
        CGPathRelease(path);
        
        CGRect drawBox = bounds;
        
        //Pad our values so the bounding box respects our line width
        drawBox.origin.x        -= self.lineWidth * 2;
        drawBox.origin.y        -= self.lineWidth * 2;
        drawBox.size.width      += self.lineWidth * 4;
        drawBox.size.height     += self.lineWidth * 4;
        
        UIGraphicsBeginImageContext(drawBox.size);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        curImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self setNeedsDisplayInRect:drawBox];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
  if (isEdit) {
    UIImage* image = nil;
    UIGraphicsBeginImageContext(self.bounds.size);
    
    [self.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSString *path = [NSString stringWithFormat:@"%@/%@.jpg",[PathUtils cachePath],[PathUtils getDayString]];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [imageData writeToFile:path atomically:YES];
    [historyDraws addObject:path];
//    curImage = image;
    image =nil;
    [self setNeedsDisplay];
  }
}

- (void)drawRect:(CGRect)rect
{
    [curImage drawAtPoint:CGPointMake(0, 0)];
    CGPoint mid1 = midPoint(previousPoint1, previousPoint2);
    CGPoint mid2 = midPoint(currentPoint, previousPoint1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:context];
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    
    CGContextStrokePath(context);
    
    [super drawRect:rect];
 
}

- (void)cleanScreen{
    
    curImage =[UIImage imageWithContentsOfFile:baseImagePath];
    previousPoint1 = CGPointMake(0, 0);
    previousPoint2 = CGPointMake(0, 0);
    currentPoint = CGPointMake(0, 0);
  
  for (int i = 0; i< [historyDraws count]; i++) {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[historyDraws objectAtIndex:i] error:nil];
  }
    [historyDraws removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)save{
    
    UIImage* image = nil;
    UIGraphicsBeginImageContext(self.bounds.size);
  
    [self.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
}

- (void)backUp{
    if ([historyDraws count]==1 || [historyDraws count] ==0) {
        curImage = [UIImage imageWithContentsOfFile:baseImagePath];
      [historyDraws removeLastObject];
    } else if([historyDraws  count] >1){
      NSFileManager *fm = [NSFileManager defaultManager];
      [fm removeItemAtPath:[historyDraws lastObject] error:nil];
      [historyDraws removeLastObject];
      curImage =[UIImage imageWithContentsOfFile:[historyDraws lastObject]];
    }
    
    previousPoint1 = CGPointMake(0, 0);
    previousPoint2 = CGPointMake(0, 0);
    currentPoint = CGPointMake(0, 0);

    [self setNeedsDisplay];
}

-(void) endDraw{
    
    for (int i = 0; i< [historyDraws count]; i++) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[historyDraws objectAtIndex:i] error:nil];
    }
    [historyDraws removeAllObjects];
}

- (void)dealloc
{
    historyDraws = nil;
  baseImagePath = nil;
  curImage = nil;
  lineColor = nil;
}

@end
