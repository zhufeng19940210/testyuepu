//
//  DSDDisplayModel.h
//  DSDDemo
//
//  Created by HJR on 2018/12/16.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDCSVModel.h"

@interface DSDDisplayModel : DSDCSVModel

//---------------  本地添加的字段
// 当前小节所属页
@property (nonatomic, assign) NSInteger pageNo;
// 是否是当前页的最后一节
@property (nonatomic, assign) BOOL isLastBarInCurrentPage;

@end
