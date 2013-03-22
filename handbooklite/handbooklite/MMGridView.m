//
// Copyright (c) 2010-2011 René Sprotte, Provideal GmbH
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#define K_DEFAULT_NUMBEROFROWS      3
#define K_DEFAULT_NUMBEROFCOLUMNS   2
#define K_DEFAULT_CELLMARGIN        5
#define K_DEFAULT_PAGEINDEX         0



#import "MMGridView.h"
#import "BookCellView.h"

@interface MMGridView()

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic) NSUInteger currentPageIndex;
@property (nonatomic) NSUInteger numberOfPages;
@property (nonatomic) NSUInteger numberOfTatalRows;

- (void)createSubviews;
- (void)cellWasSelected:(MMGridViewCell *)cell;
- (void)cellWasDoubleTapped:(MMGridViewCell *)cell;
- (void)updateCurrentPageIndex;
@end


@implementation MMGridView

@synthesize scrollView;
@synthesize dataSource;
@synthesize delegate;
@synthesize numberOfRows;
@synthesize numberOfColumns;
@synthesize cellMargin;
@synthesize currentPageIndex;
@synthesize numberOfPages;
@synthesize numberOfTatalRows;
@synthesize layoutStyle;
@synthesize isReloadData;
@synthesize bookCellDic;

@synthesize numberOfEmptyCell;//空位的个数


- (void)dealloc
{
    [scrollView release];
    [bookCellDic removeAllObjects],[bookCellDic release];
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) {
        [self createSubviews];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self createSubviews];
    }
    
    return self;
}


- (void)createSubviews
{
    cellMargin = K_DEFAULT_CELLMARGIN;
    numberOfRows = K_DEFAULT_NUMBEROFROWS;
    numberOfColumns = K_DEFAULT_NUMBEROFCOLUMNS;
    currentPageIndex = K_DEFAULT_PAGEINDEX;
    layoutStyle = VerticalLayout;
    edit =NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
    
    scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
    scrollView.delegate = self;
    scrollView.backgroundColor = self.backgroundColor;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.alwaysBounceHorizontal = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    if (layoutStyle == HorizontalLayout) {
        scrollView.pagingEnabled = YES;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = NO;
    } else {
        scrollView.pagingEnabled = NO;
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.alwaysBounceVertical = YES;
    }
    
    bookCellDic =[[NSMutableDictionary alloc] init];
    
    [self addSubview:scrollView];
    [self reloadData];
}

- (void)setEdit:(BOOL)editable{
    
    edit =editable;
}

- (BOOL)edit{
    
    return edit;
}


- (void)drawRect:(CGRect)rect
{
    if (!isReloadData) {
        return;
    }
    
    if (self.dataSource && self.numberOfRows > 0 && self.numberOfColumns > 0) {
        NSInteger noOfCols = self.numberOfColumns;
        NSInteger noOfRows = self.numberOfRows;
        NSUInteger cellsPerPage = self.numberOfColumns * self.numberOfRows;
        
        //BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]);
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        BOOL isLandscape = (orientation ==UIInterfaceOrientationLandscapeLeft ||
                            orientation == UIInterfaceOrientationLandscapeRight);
        if (isLandscape) {
            // In landscape mode switch rows and columns
            noOfCols = self.numberOfRows;
            noOfRows = self.numberOfColumns;
        }
        
        CGRect gridBounds = self.scrollView.bounds;
        
        CGRect cellBounds = CGRectMake(0, 0,192,236);
        
        
        CGSize contentSize;
        
        
        if (layoutStyle == HorizontalLayout) {
            contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width, gridBounds.size.height);
            
        } else {
            contentSize = CGSizeMake(gridBounds.size.width, self.numberOfTatalRows * cellBounds.size.height);
        }
        
        
        [self.scrollView setContentSize:contentSize];
        
        
        for (UIView *v in self.scrollView.subviews) {
            
            [v removeFromSuperview];
            
        }
        [bookCellDic removeAllObjects];
        
        
        for (NSInteger i = 0; i < [self.dataSource numberOfCellsInGridView:self]; i++) {
            
            MMGridViewCell *cell = [self.dataSource gridView:self cellAtIndex:i];
            
            [cell performSelector:@selector(setGridView:) withObject:self];
            [cell performSelector:@selector(setIndex:) withObject:[NSNumber numberWithInt:i]];
            
            NSInteger page = (int)floor((float)i / (float)cellsPerPage);
            NSInteger row  = (int)floor((float)i / (float)noOfCols) - (page * noOfRows);
            
            CGPoint origin;
            
            if (layoutStyle == HorizontalLayout) {
                
                origin = CGPointMake((page * gridBounds.size.width) + ((i % noOfCols) * cellBounds.size.width), 
                                     (row * cellBounds.size.height));
                
            } else {
                
                origin = CGPointMake((i % noOfCols) * cellBounds.size.width,
                                     (ceil( i / noOfCols)) * cellBounds.size.height);
                
            }
            
            CGRect f = CGRectMake(origin.x, origin.y, cellBounds.size.width, cellBounds.size.height);
            
            cell.frame = CGRectMake(f.origin.x+11, f.origin.y + 26, 170, 170);
            
            [self.scrollView addSubview:cell];
            
            [bookCellDic setObject:cell forKey:[NSString stringWithFormat:@"%i",i]];
            
            //一行完成后在下面添加一条背景线
            if (i%noOfRows ==0 && i!=0) {
                
                int y =origin.y+ 236;
                
                UIView *line =[[[UIView alloc] initWithFrame:CGRectMake(0, y, gridBounds.size.width, 1)]
                               autorelease];
                [line setBackgroundColor:[UIColor grayColor]];
                [line setAlpha:0.6];
                [self.scrollView addSubview:line];
                
            }
            
        }
        
        isReloadData =NO;
        
        if (![self isHasBookCell]) {
            
            [self setEdit:NO];
        }
        
    }
    
}

- (void)updateBookCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index{
    
    NSUInteger nu =[self numberOfEmptyCell];
    
    NSUInteger noOfCols = self.numberOfRows;
    
    CGRect gridBounds = self.scrollView.bounds;
    
    CGRect cellBounds = CGRectMake(0, 0,192,236);
    
    
    CGPoint origin;
    
    
    if (nu >=1) {
        //替换
        MMGridViewCell *oldCell =[bookCellDic objectForKey:[NSString stringWithFormat:@"%i",index]];
        
        [cell performSelector:@selector(setGridView:) withObject:self];
        [cell performSelector:@selector(setIndex:) withObject:[NSNumber numberWithInt:index]];
        
        [cell setFrame:CGRectMake(oldCell.frame.origin.x, oldCell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
        
        [oldCell removeFromSuperview];
        
        CGRect f = CGRectMake(oldCell.frame.origin.x, oldCell.frame.origin.y, cellBounds.size.width, cellBounds.size.height);
        
        cell.frame = CGRectMake(f.origin.x, f.origin.y, 170, 170);
        
        [self.scrollView addSubview:cell];
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.origin.x, (cell.frame.origin.y - 20)) animated:YES];
        
        [bookCellDic setObject:cell forKey:[NSString stringWithFormat:@"%i",index]];
        
        oldCell =nil;
        
        if (nu ==1) {
            
            //新增空位
            CGSize contentSize = CGSizeMake(gridBounds.size.width, ([self currentTotalRows] +1) * cellBounds.size.height);
            
            [self.scrollView setContentSize:contentSize];
            
            int count =[bookCellDic count];
            
            for (int i = count; i <(count+5); i++) {
                
                MMGridViewCell *emptyCell =[self creatEmptyCell:i];
                
                [emptyCell performSelector:@selector(setGridView:) withObject:self];
                [emptyCell performSelector:@selector(setIndex:) withObject:[NSNumber numberWithInt:i]];
                
                
                origin = CGPointMake((i % noOfCols) * cellBounds.size.width,
                                     (ceil( i / noOfCols)) * cellBounds.size.height);
                
                CGRect f = CGRectMake(origin.x, origin.y, cellBounds.size.width, cellBounds.size.height);
                
                emptyCell.frame = CGRectMake(f.origin.x+11, f.origin.y + 26, 170, 170);
                
                [self.scrollView addSubview:emptyCell];
                
                [bookCellDic setObject:emptyCell forKey:[NSString stringWithFormat:@"%i",i]];
                
            }
            
            //画线
            int y =origin.y+ 236;
            
            UIView *line =[[[UIView alloc] initWithFrame:CGRectMake(0, y, gridBounds.size.width, 1)]
                           autorelease];
            [line setBackgroundColor:[UIColor grayColor]];
            [line setAlpha:0.6];
            [self.scrollView addSubview:line];
        }
        
    }
    
}

- (void)scrollToCellAtIndex:(NSUInteger)index{
    
    MMGridViewCell *cell =[bookCellDic objectForKey:[NSString stringWithFormat:@"%i",index]];
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.origin.x, (cell.frame.origin.y - 20)) animated:YES];
}

- (NSUInteger)currentTotalRows{
    
    NSUInteger numberofCells = [self.bookCellDic count];
    if (numberofCells % numberOfRows == 0) {
        return numberofCells / numberOfRows;
    } else {
        return numberofCells / numberOfRows + 1;
    }
}

- (MMGridViewCell *)creatEmptyCell:(NSUInteger)index{
    
    BookCellView *emptyCell = [[BookCellView alloc] initWithFrame:CGRectNull andIndex:index];
    
    [emptyCell setIsClick:YES];
    [emptyCell.title setFont:[UIFont fontWithName:@"Microsoft YaHei" size:12]];
    [emptyCell.title setTextColor:[UIColor whiteColor]];
    [emptyCell.title setTextAlignment:UITextAlignmentCenter];
    
    emptyCell.backgroundView.image = [UIImage imageNamed:@"kw.png"];
    
    [emptyCell.backgroundView setBackgroundColor:[UIColor clearColor]];
    
    [emptyCell.backgroundView setContentMode:UIViewContentModeCenter];
    
    [emptyCell setType:TYPE_CELL_EMPTY];
    
    return emptyCell;
}

- (NSUInteger)numberOfEmptyCell{
    
    NSUInteger count =0;
    
    for (int i=0; i<[bookCellDic count]; i++) {
        
        MMGridViewCell *cell =[bookCellDic objectForKey:[NSString stringWithFormat:@"%i",i]];
        if ([cell.type isEqualToString:TYPE_CELL_EMPTY]) {
            count ++;
        }
    }
    return count;
}

- (NSUInteger)getFirstEmptyCellIndex{
    
    for (int i=0; i<[bookCellDic count]; i++) {
        
        MMGridViewCell *cell =[bookCellDic objectForKey:[NSString stringWithFormat:@"%i",i]];
        if ([cell.type isEqualToString:TYPE_CELL_EMPTY]) {
            return cell.index;
        }
    }
    return ([bookCellDic count]-1);
}

- (NSUInteger)getIndexByDownnum:(NSString *)downnum{
    
    for (id key in bookCellDic) {
        
        BookCellView *cell =(BookCellView *)[bookCellDic objectForKey:key];
        if ([cell.downnum isEqualToString:downnum]) {
            
            NSUInteger index =[cell index];
            return index;
        }
    }
    return [self getFirstEmptyCellIndex];
}

- (BOOL)isHasBookCell{
    
    for (id key in bookCellDic) {
        
        BookCellView *cell =(BookCellView *)[bookCellDic objectForKey:key];
        
        if ([[cell type] isEqualToString:TYPE_CELL_BOOK]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setDataSource:(id<MMGridViewDataSource>)aDataSource
{
    dataSource = aDataSource;
    [self reloadData];
}


- (void)setNumberOfColumns:(NSUInteger)value
{
    numberOfColumns = value;
    [self reloadData];
}


- (void)setNumberOfRows:(NSUInteger)value
{
    numberOfRows = value;
    [self reloadData];
}


- (void)setCellMargin:(NSUInteger)value
{
    cellMargin = value;
    [self reloadData];
}


- (NSUInteger)numberOfPages
{
    if (layoutStyle == HorizontalLayout) {
        NSUInteger numberOfCells = [self.dataSource numberOfCellsInGridView:self];
        NSUInteger cellsPerPage = self.numberOfColumns * self.numberOfRows;
        return (uint)(ceil((float)numberOfCells / (float)cellsPerPage));
    } else {
        return 1;
    }
}


- (NSUInteger)numberOfTatalRows
{
    if (layoutStyle == VerticalLayout) {
        NSUInteger numberofCells = [self.dataSource numberOfCellsInGridView:self];
        if (numberofCells % numberOfRows == 0) {
            return numberofCells / numberOfRows;
        } else {
            return numberofCells / numberOfRows + 1;
        }
    } else {
        return self.numberOfRows;
    }
}


- (void)reloadData
{
    isReloadData =YES;
    [self setNeedsDisplay];
}


- (void)cellWasSelected:(MMGridViewCell *)cell
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (delegate && [delegate respondsToSelector:@selector(gridView:didSelectCell:atIndex:)]) {
        [delegate gridView:self didSelectCell:cell atIndex:cell.index];
    }
}


- (void)cellWasDoubleTapped:(MMGridViewCell *)cell
{
    if (delegate && [delegate respondsToSelector:@selector(gridView:didDoubleTapCell:atIndex:)]) {
        [delegate gridView:self didDoubleTapCell:cell atIndex:cell.index];
    }
}

- (void)cellWasDelete:(MMGridViewCell *)cell{
    
    if (delegate && [delegate respondsToSelector:@selector(gridView:deleteCell:atIndex:)]) {
        [delegate gridView:self deleteCell:cell atIndex:cell.index];
    }
}

- (void)cellWasDownloadFinished:(MMGridViewCell *)cell error:(NSString *)error{
    
    if (delegate && [delegate respondsToSelector:@selector(gridView:finishedCell:atIndex:error:)]) {
        
        [delegate gridView:self finishedCell:cell atIndex:cell.index error:error];
    }
}

- (void)cellWasClickPushNumberShow:(MMGridViewCell *)cell{
    
    if (delegate && [delegate respondsToSelector:@selector(gridView:didPushNumberShowCell:)]) {
        
        [delegate gridView:self didPushNumberShowCell:cell];
    }
}

- (void)updateCurrentPageIndex
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSUInteger cpi = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentPageIndex = cpi;
    
    if (delegate && [delegate respondsToSelector:@selector(gridView:changedPageToIndex:)]) {
        [self.delegate gridView:self changedPageToIndex:self.currentPageIndex];
    }
}

// ----------------------------------------------------------------------------------

#pragma - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
}

@end
