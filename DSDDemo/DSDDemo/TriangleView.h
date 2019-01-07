//
//  TriangleView.h
//  DSDDemo
//
//  Created by Leong on 16/2/2016.
//  Copyright © 2016 Leong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TriangleView : UIView{
    
    double size;
    CGPoint center;
    
}

-(void)setColor:(UIColor*)_color;
-(void)setType:(NSString *) _type;
-(void)setSize:(BOOL)isPro;

@end
