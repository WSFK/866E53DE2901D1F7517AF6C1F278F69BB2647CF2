//
//  UINavigationController+Rotation_IOS6.h
//  handbooklite
//
//  Created by han on 13-3-15.
//
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Rotation_IOS6)

-(BOOL)shouldAutorotate;

-(NSUInteger)supportedInterfaceOrientations;

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
