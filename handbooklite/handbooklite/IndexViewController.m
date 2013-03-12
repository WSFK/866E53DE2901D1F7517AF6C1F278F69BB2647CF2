//
//  IndexViewController.m
//  Baker
//
//  ==========================================================================================
//  
//  Copyright (c) 2010-2011, Davide Casali, Marco Colombo, Alessandro Morandi
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, are 
//  permitted provided that the following conditions are met:
//  
//  Redistributions of source code must retain the above copyright notice, this list of 
//  conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of 
//  conditions and the following disclaimer in the documentation and/or other materials 
//  provided with the distribution.
//  Neither the name of the Baker Framework nor the names of its contributors may be used to 
//  endorse or promote products derived from this software without specific prior written 
//  permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  

#import "IndexViewController.h"


@implementation IndexViewController

- (id)initWithBookBundlePath:(NSString *)path cachesBookPath:(NSString *)cachePath fileName:(NSString *)name webViewDelegate:(UIViewController<UIWebViewDelegate> *)delegate {
    
    self = [super init];
    if (self) {
        
        fileName = name;
        bookBundlePath = path;
        cachesBookPath = cachePath;
        webViewDelegate = delegate;
        
        disabled = NO;//滚动条默认不显示
        //初始化宽和高为零
        indexWidth = 0;
        indexHeight = 0;
        
        // ****** INIT PROPERTIES
        properties = [Properties properties];
        
        //设置滚动条中页面的尺寸
        [self setPageSizeForOrientation:[self interfaceOrientation]];
    }
    return self;
}
- (void)dealloc
{
    indexScrollView =nil;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    // Initialization to 1x1px is required to get sizeThatFits to work
    //初始化滚动条中页面的尺寸
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 1024, 1, 1)];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webView.delegate = self;
    
    webView.backgroundColor = [UIColor clearColor];
    [webView setOpaque:NO];
    
    self.view = webView;    
    //遍历webview中的所有子视图
    for (UIView *subView in webView.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            //将页面中的元素添加到横向滚动条中
            indexScrollView = (UIScrollView *)subView;
            break;
        }
    }
    [indexScrollView setAlpha:0.6];
    [indexScrollView setBackgroundColor:[UIColor blackColor]];
    //加载页面内容
    [self loadContent];
}

//设置横向滚动条是否弹出
- (void)setBounceForWebView:(UIWebView *)webView bounces:(BOOL)bounces {
    indexScrollView.bounces = bounces;
}

- (void)setPageSizeForOrientation:(UIInterfaceOrientation)orientation {
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	//设置滚动条左右滑动时候页面的大小
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		pageWidth = screenBounds.size.height;
		pageHeight = screenBounds.size.width;
    } else {
        pageWidth = screenBounds.size.width;
		pageHeight = screenBounds.size.height;
	}
    
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    //判断滚动条是否是隐藏的
    if (sharedApplication.statusBarHidden) {
        pageY = 0;
    } else {
        pageY = -20;//设置滚动条y轴上的坐标值
    }
    
}

- (void)setActualSize {
    actualIndexWidth = MIN(indexWidth, pageWidth);
    actualIndexHeight = MIN(indexHeight, pageHeight);
}

- (BOOL)isIndexViewHidden {
    return [UIApplication sharedApplication].statusBarHidden;
}

- (BOOL)isDisabled {
    return disabled;
}

- (void)setIndexViewHidden:(BOOL)hidden withAnimation:(BOOL)animation {
    CGRect frame;
    if (hidden) {
        //如果是隐藏状态  判断是否可以左侧延伸
        if ([self stickToLeft]) {
            //如果可以左侧延伸  就将页面内容向左侧滑动
            frame = CGRectMake(-actualIndexWidth, pageHeight - actualIndexHeight, actualIndexWidth, actualIndexHeight);
        } else {
            //如果不可以左侧延伸  则滚动条的大小就是页面的大小
            frame = CGRectMake(0, pageHeight + pageY, actualIndexWidth, actualIndexHeight);
        }
    } else {
        if ([self stickToLeft]) {
            frame = CGRectMake(0, pageHeight - actualIndexHeight, actualIndexWidth, actualIndexHeight);
        } else {
            //由于navigationController  -60  +64
            frame = CGRectMake(0, pageHeight + pageY- indexHeight, actualIndexWidth, actualIndexHeight);
        }

    }

    
    if (animation) {
        [UIView beginAnimations:@"slideIndexView" context:nil]; {
            [UIView setAnimationDuration:0.3];//设置滑出的时间
            
            [self setViewFrame:frame];
        }
        [UIView commitAnimations];//提交动画
    } else {
        [self setViewFrame:frame];
    }
}

- (void)setViewFrame:(CGRect)frame {
    self.view.frame = frame;
    
    // Orientation changes tend to screw the content size detection performed by the scrollView embedded in the webView.
    // Let's show the scrollView who's boss.
    indexScrollView.contentSize = cachedContentSize;
}

- (void)fadeOut {
    [UIView beginAnimations:@"fadeOutIndexView" context:nil]; {
        [UIView setAnimationDuration:0.0];
        //将滚动视图设置为透明的  隐藏起来
        self.view.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)fadeIn {
    [UIView beginAnimations:@"fadeInIndexView" context:nil]; {
        [UIView setAnimationDuration:0.2];
        
        self.view.alpha = 1.0;
    }
    [UIView commitAnimations];
}

- (void)willRotate {
    [self fadeOut];
}

- (void)rotateFromOrientation:(UIInterfaceOrientation)fromInterfaceOrientation toOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    BOOL hidden = [self isIndexViewHidden]; // cache hidden status before setting page size
    
    [self setPageSizeForOrientation:toInterfaceOrientation];
    [self setActualSize];
    [self setIndexViewHidden:hidden withAnimation:NO];
    [self fadeIn];
}
- (void)loadContent{
    //从项目下加载页面内容  true
    [self loadContentFromBundle:NO];
}

- (void)loadContentFromBundle:(BOOL)fromBundle{
    loadedFromBundle = fromBundle;//设置是否是从项目下加载的内容
    
    NSString* path = [self indexPath];//获取项目中book下的文件
    
    [self assignProperties];
    
    //判断页面文件是否在项目目录下存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //如果存在 设置状态为可用 并加载页面
        disabled = NO;
        NSURLRequest *req = [[NSURLRequest alloc]initWithURL:[NSURL fileURLWithPath:path]
                                                 cachePolicy:0 
                                             timeoutInterval:10];
        
		[(UIWebView *)self.view loadRequest:req];
	} else {
        NSLog(@"-----------indexpage no exist：%@",path);
        //不存在 设置状态不可用
        disabled = YES;
    }
}

- (void)assignProperties {
    UIWebView *webView = (UIWebView*) self.view;
    //设置网页中的媒体是否自动播放
    webView.mediaPlaybackRequiresUserAction = ![[properties get:@"-baker-media-autoplay", nil] boolValue];
    
    BOOL bounce = [[properties get:@"-baker-index-bounce", nil] boolValue];//是否从webview中弹出
    [self setBounceForWebView:webView bounces:bounce];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    id width = [properties get:@"-baker-index-width", nil];
    id height = [properties get:@"-baker-index-height", nil];
    
    indexWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.width"] floatValue];
    indexHeight =[[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
//    NSLog(@"----------indexWidth:%d-------indexHeight:%d",indexWidth,indexHeight);
    if (width != [NSNull null]) {
        indexWidth = (int) [width integerValue];
    } else {
        indexWidth = [self sizeFromContentOf:webView].width;
    }
    if (height != [NSNull null]) {
        indexHeight = (int) [height integerValue];
    } else {
        indexHeight = [self sizeFromContentOf:webView].height;
    }

    cachedContentSize = indexScrollView.contentSize;
    [self setActualSize];
    
    // After the first load, point the delegate to the main view controller
    webView.delegate = webViewDelegate;
    
    [self setIndexViewHidden:[self isIndexViewHidden] withAnimation:NO];
}

- (BOOL)stickToLeft {
    //判断是否可以想左滑动  如果滚动条实际的高度大于实际的宽度就可以向左侧滑动
    return (actualIndexHeight > actualIndexWidth);
}

- (CGSize)sizeFromContentOf:(UIView *)view {
    // Setting the frame to 1x1 is required to get meaningful results from sizeThatFits when 
    // the orientation of the is anything but Portrait.
    // See: http://stackoverflow.com/questions/3936041/how-to-determine-the-content-size-of-a-uiwebview/3937599#3937599
    CGRect frame = view.frame;
    frame.size.width = 1;
    frame.size.height = 1;
    view.frame = frame;
    
    return [view sizeThatFits:CGSizeZero];
}

- (NSString *)indexPath {
    //判断是否从项目中加载
    if(loadedFromBundle){
//        CCLog(@"-------index init path：%@",[bookBundlePath stringByAppendingPathComponent:fileName]);
        return [bookBundlePath stringByAppendingPathComponent:fileName];
    } else {
        //否则在caches目录下加载
//        CCLog(@"-------index init path：%@",[cachesBookPath stringByAppendingPathComponent:fileName]);
        return [cachesBookPath stringByAppendingPathComponent:fileName];
    }
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
