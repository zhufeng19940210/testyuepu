//
//  DSDPlayManager.m
//  DSDDemo
//
//  Created by HJR on 2018/12/16.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDPlayManager.h"

@interface DSDPlayManager()
{
    NSArray<NSDictionary *> *_rawDisplayArray;
    NSInteger _repeatStartBarIndex;
    NSInteger _repeatEndBarIndex;
}

//@property (nonatomic, strong) NSArray *shadowArray;

@end

@implementation DSDPlayManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

+ (instancetype)manager;
{
    DSDPlayManager *instance = [[DSDPlayManager alloc] init];
    return instance;
}

#pragma mark - public method
- (void)updateShadowArray:(NSArray<NSDictionary *> *)shadowArray
{
    NSArray *array = [NSArray yy_modelArrayWithClass:[DSDShaderModel class] json:shadowArray];
    _shadowArray = array;
}

- (NSArray<DSDShaderModel *> *)getPrepareBeatsArray
{
    if (self.prepareBeats < 1)
    {
        return nil;
    }
    
    NSMutableArray *prepareBeatsArray = [NSMutableArray new];
    for (NSInteger i = 0; i < self.shadowArray.count; i++)
    {
        DSDShaderModel *shader = self.shadowArray[i];
        NSInteger startBar = _repeatStartBarIndex > -1 ?  _repeatStartBarIndex : 0;
        if ([shader.barNo40 integerValue] == startBar)
        {
            [prepareBeatsArray addObject:shader];
        }
    }
    NSCParameterAssert(prepareBeatsArray.count);
    return [prepareBeatsArray copy];
}

#pragma mark - 节拍器
- (BOOL)isStartBarFistBeats
{
    if (self.shaderCurrentIndex == 0)
    {
        return YES;
    }
    
    // 循环练习模式下的开始小节第一拍
    if (self.repeatPractice && (self.currentPlayBarIndex == _repeatStartBarIndex) && [self isFirstBeatsInCurrentBar:self.currentPlayBarIndex])
    {
        return YES;
    }
    
    
    return NO;
}

- (DSDShaderModel *)currentShaderModel:(NSArray<NSDictionary *> *)shadowArray
{
    if (self.shaderCurrentIndex >= shadowArray.count)
    {
        NSCParameterAssert(NO);
        return nil;
    }
    
    NSDictionary *dict = shadowArray[self.shaderCurrentIndex];
    DSDShaderModel *model = [DSDShaderModel yy_modelWithJSON:dict];
    
    if (self.shaderCurrentIndex == (shadowArray.count - 1))
    {
        model.isLastBeatsInCurrentBar = YES;
    }
    else
    {
        NSDictionary *nextDict = shadowArray[self.shaderCurrentIndex + 1];
        DSDShaderModel *nextModel = [DSDShaderModel yy_modelWithJSON:nextDict];
        if ([model.barNo40 isEqualToString:nextModel.barNo40])
        {
            model.isLastBeatsInCurrentBar = NO;
        }
        else
        {
            model.isLastBeatsInCurrentBar = YES;
        }
    }
    
    return model;
}

- (NSInteger)repeatStartBarIndex
{
    return _repeatStartBarIndex;
}

- (NSInteger)repeatEndBarIndex
{
    return _repeatEndBarIndex;
}

- (BOOL)repeatPractice
{
    if (self.repeatStartBarIndex > -1 && self.repeatEndBarIndex > 0)
    {
        return YES;
    }
    
    return NO;
}

- (NSInteger)currentPlayBarIndex
{
    if (self.shadowArray.count <= self.shaderCurrentIndex)
    {
        NSCParameterAssert(NO);
        return 0;
    }
    DSDShaderModel *currentModel = self.shadowArray[self.shaderCurrentIndex];
    return [currentModel.barNo40 integerValue];
}

#pragma mark - 跳页
// 默认从第0小节到最后1节
- (void)setDisplayArray:(NSArray<NSDictionary *> *)displayArray
{
    _displayArray = [NSArray yy_modelArrayWithClass:[DSDDisplayModel class] json:displayArray];
    _rawDisplayArray = displayArray;
    [self updateDisplayArray:0 endBar:_displayArray.count-1];
    _repeatStartBarIndex = 0;
    _repeatEndBarIndex = _displayArray.count - 1;
}

// 指定显示的开始小节和结束小节
- (void)updateDisplayArray:(NSUInteger)startBar endBar:(NSUInteger)endBar
{
    if (startBar >= _displayArray.count || endBar >= _displayArray.count)
    {
        NSAssert(NO, @"❌startBar 或 endBar 越界!");
        return;
    }
    
    _repeatStartBarIndex = startBar;
    _repeatEndBarIndex = endBar;
    
    NSInteger length = 0;
    NSInteger screenLength = [UIScreen mainScreen].bounds.size.width*2;
    NSInteger pageNum = 0;
    for (NSInteger i = startBar; i <= endBar; i++)
    {
        DSDDisplayModel *model = _displayArray[i];
        if (i == startBar)
        {
            model.pageNo = 0;
            length = model.length109;
            pageNum = model.pageNo;
        }
        else
        {
            DSDDisplayModel *nextModel = nil;
            if (i+1 <= endBar)
            {
                nextModel = _displayArray[i+1];
            }
            
            NSInteger tempLength = length + model.length109 + nextModel.length109;
            if (tempLength > screenLength)
            {
                model.pageNo = pageNum+1;
                length = model.length109;
            }
            else
            {
                model.pageNo = pageNum;
                length = length + model.length109;
            }
            pageNum = model.pageNo;
        }
    }
    
}

- (void)resetDisplayArray
{
    [self updateDisplayArray:0 endBar:_displayArray.count-1];
    _repeatStartBarIndex = 0;
    _repeatEndBarIndex = _displayArray.count-1;
}

- (DSDDisplayModel *)displayModelWithBar:(NSUInteger)barNo
{
    for (NSInteger i = 0; i < _displayArray.count; i++)
    {
        DSDDisplayModel *model = _displayArray[i];
        if ([model.barNo40 integerValue] == barNo)
        {
            if (i == _displayArray.count - 1)
            {
                 model.isLastBarInCurrentPage = YES;
            }
            else
            {
                DSDDisplayModel *nexModel = _displayArray[i+1];
                if (nexModel.pageNo == model.pageNo)
                {
                    model.isLastBarInCurrentPage = NO;
                }
                else
                {
                    model.isLastBarInCurrentPage = YES;
                }
            }
            return model;
        }
    }
    
    return nil;
}

#pragma mark - pravite utlity method
// 判断节拍器是否在当前小节第一拍
- (BOOL)isFirstBeatsInCurrentBar:(NSInteger)shaderIndex
{
    NSCParameterAssert(self.shadowArray.count);
    NSCParameterAssert(self.shadowArray.count > shaderIndex);
    
    if (shaderIndex == 0)
    {// 第一拍
        return YES;
    }
    
    if (shaderIndex == self.shadowArray.count - 1)
    {// 最后一拍
        return NO;
    }
    
    DSDShaderModel *currentShader = self.shadowArray[shaderIndex];
    DSDShaderModel *preShader = self.shadowArray[shaderIndex-1];
    if ([currentShader.barNo40 isEqualToString:preShader.barNo40])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
