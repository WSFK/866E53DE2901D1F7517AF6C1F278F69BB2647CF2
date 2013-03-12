//
//  IndexViewController.h
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
//   这个是双击页面弹出来的横向滚动条的控制类

#import <UIKit/UIKit.h>
#import "Properties.h"


@interface IndexViewController : UIViewController <UIWebViewDelegate> {
    
    NSString *bookBundlePath;//book项目下的路径
    NSString *cachesBookPath;//book caches下的路径
    NSString *fileName;
    UIScrollView *indexScrollView;//横向的滚动条
    UIViewController <UIWebViewDelegate> *webViewDelegate;
    
    int pageY;//页面纵向滚动的位置
    int pageWidth;//页面的宽度
	int pageHeight;//页面的高度
    int indexWidth;//横向的滚动条的宽度
    int indexHeight;//横向的滚动条的高度
    int actualIndexWidth;//横向的滚动条的实际宽度
    int actualIndexHeight;//横向的滚动条的实际高度
    BOOL disabled;//滚动条是否可用
    BOOL loadedFromBundle;//是否是从项目中加载的
    
    CGSize cachedContentSize;//滚动条内容的实际尺寸
    
    Properties *properties;
}
//初始化横向滚动条的方法     book项目下的路径           //document下的book路径   文件的名字  web页面
- (id)initWithBookBundlePath:(NSString *)path cachesBookPath:(NSString *)cachePath fileName:(NSString *)name webViewDelegate:(UIViewController *)delegate;

- (void)loadContent;
- (void)loadContentFromBundle:(BOOL)fromBundle;
//设置是否从webview中弹出
- (void)setBounceForWebView:(UIWebView *)webView bounces:(BOOL)bounces;
- (void)setPageSizeForOrientation:(UIInterfaceOrientation)orientation;
//判断滚动条是否是是隐藏的
- (BOOL)isIndexViewHidden;
//判断滚动条是否可用
- (BOOL)isDisabled;
//设置滚动条隐藏的状态
- (void)setIndexViewHidden:(BOOL)hidden withAnimation:(BOOL)animation;

- (void)willRotate;
//在滚动条显示或隐藏之前设置页面的大小
- (void)rotateFromOrientation:(UIInterfaceOrientation)fromInterfaceOrientation toOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
//设置滚动条隐藏
- (void)fadeOut;
//设置滚动条显示
- (void)fadeIn;
- (void)assignProperties;
//判断是否可以向左侧延伸
- (BOOL)stickToLeft;
//得到页面合适的大小
- (CGSize)sizeFromContentOf:(UIView *)view;
//设置滚动条实际的尺寸
- (void)setActualSize;
//设置滚动条的尺寸
- (void)setViewFrame:(CGRect)frame;
//获取滚动条页面文件的路径
- (NSString *)indexPath;

@end
