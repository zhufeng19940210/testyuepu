//
//  DSDPlayManager.h
//  DSDDemo
//
//  Created by HJR on 2018/12/16.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSDShaderModel.h"
#import "DSDDisplayModel.h"

@interface DSDPlayManager : NSObject

+ (instancetype)manager;

////////////////////////////////////////////////////////////
//                          节拍器
////////////////////////////////////////////////////////////

// 节拍器当前位置(相对于shadowArray)
@property (nonatomic, assign) NSInteger shaderCurrentIndex;
// 预备拍当前位置(相对于prepareBeatsArray)
@property (nonatomic, assign) NSInteger prepareShaderIndex;
// 预备拍
@property (nonatomic, assign) NSInteger prepareBeats;
// 记录预备拍播放了几次
@property (nonatomic, assign) NSInteger prepareBeatsPlayCount;

// 如果shadowArray数据源变更了，要调用该方法更新数据
- (void)updateShadowArray:(NSArray<NSDictionary *> *)shadowArray;
// currentShader
- (DSDShaderModel *)currentShaderModel:(NSArray<NSDictionary *> *)shadowArray;
// 获取预备拍
- (NSArray<DSDShaderModel *> *)getPrepareBeatsArray;

//// -------------- readonly
// 是否是开始小节的第一拍
@property (nonatomic, assign, readonly) BOOL isStartBarFistBeats;
// 是否重复练习
@property (nonatomic, assign, readonly) BOOL repeatPractice;
// 重复练习开始小节
@property (nonatomic, assign, readonly) NSInteger repeatStartBarIndex;
// 重复练习结束小节
@property (nonatomic, assign, readonly) NSInteger repeatEndBarIndex;
// 当前播放的小节
@property (nonatomic, assign, readonly) NSInteger currentPlayBarIndex;
// shadowArray
@property (nonatomic, strong, readonly) NSArray<DSDShaderModel*> *shadowArray;



////////////////////////////////////////////////////////////
//                          跳页
////////////////////////////////////////////////////////////
// 默认从第0小节到最后1节
- (void)setDisplayArray:(NSArray<NSDictionary *> *)displayArray;
// 指定显示的开始小节和结束小节
- (void)updateDisplayArray:(NSUInteger)startBar endBar:(NSUInteger)endBar;
// 重置displayArray（即不再指定循环练习的小节）
- (void)resetDisplayArray;
- (DSDDisplayModel *)displayModelWithBar:(NSUInteger)barNo;
@property (nonatomic, strong, readonly) NSArray<DSDDisplayModel *> *displayArray;


@end
