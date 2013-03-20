//
//  UINavigationController+Rotation_IOS6.m
//  handbooklite
//
//  Created by han on 13-3-15.
//
//

#import "UINavigationController+Rotation_IOS6.h"

@implementation UINavigationController (Rotation_IOS6)

-(BOOL)shouldAutorotate {
  return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations {
  return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
