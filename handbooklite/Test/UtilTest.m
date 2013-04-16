//
//  UtilTest.m
//  handbooklite
//
//  Created by han on 13-4-16.
//
//

#import "UtilTest.h"

@implementation UtilTest

-(void) testOne{
  NSString *pdfUrlStr = @"http//www.raywenderlich.com/4295/multithreading-and-grand-central-dispatch-on-ios-for-beginners-tutorial";
  NSURL *pdfUrl = [NSURL URLWithString:pdfUrlStr];
//  NSString *result = @"";
  [self checkUrl:pdfUrl url:&pdfUrlStr];
  NSLog(@"%@",pdfUrlStr);
  
}

-(void) checkUrl:(NSURL *) param url:(NSString **) url{
  
  if ([param host] == nil) {
    *url = [NSString stringWithFormat:@"http://%@",param];
  }else{
    *url = [param relativeString];
  }
  
}

@end
