//
//  UIView+Roundify.h
//  LoopLayoutDemo
//
//  Created by Gary on 9/12/13.
//  Copyright (c) 2013 Nuthon IT Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Roundify)

-(void)addRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii;
-(CALayer*)maskForRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii;

@end