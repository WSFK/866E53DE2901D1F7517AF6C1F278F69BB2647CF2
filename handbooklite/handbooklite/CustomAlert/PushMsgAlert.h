//
//  PushMsgAlert.h
//  handbooklite
//
//  Created by bao_wsfk on 13-3-20.
//
//  用于显示推送信息

#import <UIKit/UIKit.h>

@interface PushMsgAlert : UIAlertView{
    
    
    NSString *pushDownnum;
}
@property (nonatomic, copy) NSString *pushDownnum;

@end
