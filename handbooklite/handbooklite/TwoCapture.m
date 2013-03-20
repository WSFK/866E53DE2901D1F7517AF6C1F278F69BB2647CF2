//
//  TwoCapture.m
//  handbooklite
//
//  Created by han on 13-3-15.
//
//

#import "TwoCapture.h"

@implementation TwoCapture
static TwoCapture *instence = nil;

@synthesize isSendTwoCodeNoti;


+ (TwoCapture *) newInstence{
  @synchronized(self){
    if (instence == nil) {
      instence = [[TwoCapture alloc] init];
    }
  }
  return instence;
}

+(id) allocWithZone:(NSZone *)zone{
  @synchronized(self){
    if (instence == nil) {
      instence = [super allocWithZone:zone];
      return instence;
    }
  }
  return nil;
}

-(id) copyWithZone:(NSZone *)zone{
  return self;
}

@end

