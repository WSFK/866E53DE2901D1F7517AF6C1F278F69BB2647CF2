//
//  SinaweiboShare.m
//  handbook
//
//  Created by bao_wsfk on 12-10-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaweiboShare.h"
#import "AppDelegate.h"
#import "iToast.h"

@implementation SinaweiboShare
static SinaweiboShare *_shareSingleton = nil;

+ (SinaweiboShare *)sharedInstance{
    
    
    @synchronized(self){  
        if(_shareSingleton == nil){
            _shareSingleton = [[SinaweiboShare alloc] init];
        }
    }
    return _shareSingleton;
}

+(id) allocWithZone:(NSZone *)zone{
  @synchronized(self){
    if (_shareSingleton == nil) {
      _shareSingleton = [super allocWithZone:zone];
      return _shareSingleton;
    }
  }
  return nil;
}

- (void)login{
    
    SinaWeibo *sinaweibo = [self sinaweibo];
    [sinaweibo logIn];
}

- (void)logout{
    SinaWeibo *sinaweibo =[self sinaweibo];
    [sinaweibo logOut];
}

- (void)postMessage:(NSString *)message withPic:(UIImage *)pic{
    
    data = [[NSMutableDictionary alloc] init];
    [data setObject:message forKey:@"status"];
    [data setObject:pic forKey:@"pic"];
    
    //登录
    [self login];
    
}

- (void)sendShare{
    
    SinaWeibo *sinaweibo =[self sinaweibo];
    [sinaweibo requestWithURL:@"statuses/upload.json"
                       params:data
                   httpMethod:@"POST"
                     delegate:self];
}

- (SinaWeibo *)sinaweibo
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.sinaweibo setDelegate:self];
    return delegate.sinaweibo;
}

//用户成功登录
//注意需要将登录成功的用户信息缓存下来 以便下次使用
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo{
    
    CCLog(@"---:sinaweiboDidLogin userID =%@",sinaweibo.userID);
    CCLog(@"---:             accesstoken =%@",sinaweibo.accessToken);
    CCLog(@"---:          expirationDate =%@",sinaweibo.expirationDate);//过期时间，用于判断登录是否过期
    [self storeAuthData];
    //分享微博
    [self performSelector:@selector(sendShare) withObject:nil afterDelay:0.5];
}

//缓存用户信息
- (void)storeAuthData{
    CCLog(@"保存用户的信息");
    
    SinaWeibo *sinaweibo = [self sinaweibo];
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//用户退出登录
//注意需要清除已经存在的缓存信息
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo{
    CCLog(@"---:sinaweiboDidLogOut");
    [self removeAuthData];
}

//清除缓存信息
- (void)removeAuthData{
    CCLog(@"删除用户的信息");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

//用户取消登录过程
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo{
    CCLog(@"----:sinaweiboLogInDidCancel");
}

//登录失败
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error{
    CCLog(@"----:sinaweibo loginDidFailWithError %@",error);
}

//缓存的token无效 或者已经过期
//需要清除存在的用户缓存信息
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error{
    CCLog(@"----:sinaweiboAccessToken Invalid or expired %@",error);
    [self removeAuthData];
}




#pragma - mark SinaWeiboRequestDelegate
//请求失败
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    //当一个delegate 需要处理多个请求回调时  可以通过url判断当前的request
    if ([request.url hasSuffix:@"statuses/upload.json"]){//匹配url后缀
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                            message:@"分享失败"
//                                                           delegate:nil 
//                                                  cancelButtonTitle:nil 
//                                                  otherButtonTitles:@"确定", 
//                                  nil];
//        [alertView show];
//        [alertView release];
        
        iToast *toast =[iToast makeToast:@"分享失败，请稍后再试"];
        [toast setToastPosition:kToastPositionBottom];
        [toast setToastDuration:kToastDurationNormal];
        [toast show];
        
        data =nil;
        CCLog(@"Post image status failed with error : %@", error);
    }
}

//请求成功
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result{
    
    if ([request.url hasSuffix:@"statuses/upload.json"]){
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                            message:@"分享成功"
//                                                           delegate:nil 
//                                                  cancelButtonTitle:nil 
//                                                  otherButtonTitles:@"确定", nil];
//        [alertView show];
//        [alertView release];
        
        iToast *toast =[iToast makeToast:@"分享成功"];
        [toast setToastPosition:kToastPositionBottom];
        [toast setToastDuration:kToastDurationNormal];
        [toast show];
        
        data =nil;
        
    }
}



@end
