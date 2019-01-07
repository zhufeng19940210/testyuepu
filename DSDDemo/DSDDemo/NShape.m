//
//  NShape.m
//  DSDDemo
//
//  Created by Leong on 2/8/2017.
//  Copyright © 2017 Leong. All rights reserved.
//

#import "NShape.h"

@implementation NShape

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = UIColor.clearColor;
    
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    
    
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    
    // start at top left corner
    [linePath moveToPoint:CGPointMake(rect.size.width,0)];
    
    [linePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    
    [linePath moveToPoint:CGPointMake(0,0)];
    
    [linePath addLineToPoint:CGPointMake(0, rect.size.height)];

    
    // create a layer that uses your defined path
    CAShapeLayer * lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1.0;
    lineLayer.strokeColor = [UIColor blackColor].CGColor;
    
    lineLayer.fillColor = nil;
    lineLayer.path = linePath.CGPath;
    
    [self.layer addSublayer:lineLayer];
    
    linePath = [UIBezierPath bezierPath];
    
    // start at top left corner
    [linePath moveToPoint:CGPointMake(0,2)];
    
    [linePath addLineToPoint:CGPointMake(rect.size.width, 2)];
    
    
    // create a layer that uses your defined path
    lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 4.0;
    lineLayer.strokeColor = [UIColor blackColor].CGColor;
    
    lineLayer.fillColor = nil;
    lineLayer.path = linePath.CGPath;
    
    [self.layer addSublayer:lineLayer];
    
}

@end
