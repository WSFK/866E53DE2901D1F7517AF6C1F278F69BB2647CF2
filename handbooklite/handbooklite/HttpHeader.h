//
//  HttpHeader.h
//  handbook
//
//  Created by bao_wsfk on 12-11-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HttpHeader : NSObject{
  int tapTimes;
}
@property (nonatomic, assign) int tapTimes;

+ (id)shareInstance;

- (NSString *)httpHeader;

- (void)updateHttpHeader:(NSString *)httpHeader;

@end
