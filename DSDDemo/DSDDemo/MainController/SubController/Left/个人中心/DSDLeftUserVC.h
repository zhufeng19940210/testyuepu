//
//  DSDLeftUserVC.h
//  DSDDemo
//
//  Created by HJR on 2018/12/24.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSDLeftUserVC : UIViewController

@property (nonatomic, copy) void(^selectCallback)(NSInteger index);

@end
