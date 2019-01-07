//
//  DSDLeftUserModel.h
//  DSDDemo
//
//  Created by HJR on 2018/12/24.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSDLeftUserModel : NSObject
// 0-登录;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *title;
@end
