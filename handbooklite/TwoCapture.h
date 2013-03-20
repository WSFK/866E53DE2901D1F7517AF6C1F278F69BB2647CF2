//
//  TwoCapture.h
//  handbooklite
//
//  Created by han on 13-3-15.
//
//

#import <Foundation/Foundation.h>

@interface TwoCapture : NSObject{
  //记录是否发了二维码通知；
  BOOL isSendTwoCodeNoti;
}
@property (nonatomic, assign, getter=isSendTwoCodeNoti) BOOL isSendTwoCodeNoti;
+ (TwoCapture *) newInstence;
@end
