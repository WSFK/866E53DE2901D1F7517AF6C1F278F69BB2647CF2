//
//  WaitAlertView.h
//  handbooklite
//
//  Created by bao_wsfk on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitAlertView : UIAlertView{
    
    BOOL isShowIng;
}

- (id)init;

- (void)dismiss;

@end
