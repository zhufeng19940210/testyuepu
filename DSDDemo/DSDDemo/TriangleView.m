//
//  TriangleView.m
//  DSDDemo
//
//  Created by Leong on 16/2/2016.
//  Copyright © 2016 Leong. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView {
    UIColor * color;
    NSString * type;
}

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int sides = 3;

    double radius = size / 2.0;
    double theta = 2.0 * M_PI / sides;
    
    if([type isEqualToString:@"D"]){
        CGContextMoveToPoint(context, center.x, center.y+radius);
        for (NSUInteger k=1; k<sides; k++) {
            float x = radius * sin(k * theta);
            float y = radius * cos(k * theta);
            CGContextAddLineToPoint(context, center.x-x, center.y+y);
        }
    }
    else{
        CGContextMoveToPoint(context, center.x, center.y-radius);
        for (NSUInteger k=1; k<sides; k++) {
            float x = radius * sin(k * theta);
            float y = radius * cos(k * theta);
            CGContextAddLineToPoint(context, center.x+x, center.y-y);
        }
    }
    
    
    CGContextClosePath(context);
    if(color){
        const CGFloat* components = CGColorGetComponents(color.CGColor);
        
        CGContextSetRGBFillColor(context, components[0],components[1], components[2], 1.0);
    }
    
    
    CGContextFillPath(context);           // Choose for a filled triangle
    // CGContextSetLineWidth(context, 2); // Choose for a unfilled triangle
    // CGContextStrokePath(context);      // Choose for a unfilled triangle
}

-(void)setColor:(UIColor*)_color{
    color = _color;
}

-(void)setType:(NSString *) _type{
    type = _type;
}

-(void)setSize:(BOOL)isPro{
    
    if(isPro){
        size = 9.0;
        center = CGPointMake(4.5, 4.5);
    }
    else{
        size = 12.0;
        center = CGPointMake(6, 6);
    }
    
    
}

@end
