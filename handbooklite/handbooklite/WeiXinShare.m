//
//  WeiXinShare.m
//  handbooklite
//
//  Created by bao_wsfk on 13-7-2.
//
//

#import "WeiXinShare.h"
#import "WXApi.h"
#import "iToast.h"

@implementation WeiXinShare

+ (void)sendShareWithImage:(UIImage *)image description:(NSString *)desc url:(NSString *)url{
    if([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        
        WXMediaMessage *mediaMessage =[WXMediaMessage message];
        [mediaMessage setThumbImage:image];
        [mediaMessage setTitle:@"四维册分享"];
        [mediaMessage setDescription:desc];
        
        WXWebpageObject *webObject =[WXWebpageObject object];
        [webObject setWebpageUrl:url];
        mediaMessage.mediaObject =webObject;
        
        SendMessageToWXReq *req =[[SendMessageToWXReq alloc] init];
        req.bText=NO;
        req.message =mediaMessage;
        //req.scene =WXSceneTimeline; //发送到朋友圈
        [WXApi sendReq:req];
    }else{
        iToast *toast =[iToast makeToast:@"安装微信客户端后才可以使用本功能！"];
        [toast setToastPosition:kToastPositionBottom];
        [toast setToastDuration:kToastDurationNormal];
        [toast show];
    }
}

@end
