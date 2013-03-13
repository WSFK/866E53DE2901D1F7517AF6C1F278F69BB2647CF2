//
//  SendMailDelegate.h
//  handbooklite
//
//  Created by han on 13-3-13.
//
//

#import <Foundation/Foundation.h>

@protocol SendMailDelegate <NSObject>

- (void)didSendMailFinished;
- (void)didSendMailFailure;
- (void)didSendMailCancelled;
- (void)didSaveMailFinished;
- (void)notOpenMail;

@end
