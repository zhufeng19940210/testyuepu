//
//  DSDPlayTopBar.h
//  DSDDemo
//
//  Created by HJR on 2018/12/22.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DSDPlayTopBar;
@protocol DSDPlayTopBarDelegate

// 「我的乐曲」按钮点击
- (void)playTopBar:(DSDPlayTopBar *)bar backBtnAction:(UIButton *)sender;
// tempo +
- (void)playTopBar:(DSDPlayTopBar *)bar increaseBtnAction:(UIButton *)sender;
// tempo + 长按事件
- (void)playTopBarIncreaseBtnLongpressedAction:(DSDPlayTopBar *)bar;
// tempo -
- (void)playTopBar:(DSDPlayTopBar *)bar decreaseBtnAction:(UIButton *)sender;
// tempo - 长按事件
- (void)playTopBarDecreaseBtnLongpressedAction:(DSDPlayTopBar *)bar;
// 节拍器开关
- (void)playTopBar:(DSDPlayTopBar *)bar beatsBtnAction:(UIButton *)sender;
// 演奏/练习模式切换
- (void)playTopBar:(DSDPlayTopBar *)bar modeSwitchBtnAction:(UIButton *)sender;
// 小节快速返回
- (void)playTopBar:(DSDPlayTopBar *)bar playBackBtnAction:(UIButton *)sender;
// 暂停/播放
- (void)playTopBar:(DSDPlayTopBar *)bar playPauseBtnAction:(UIButton *)sender;
// 设置
- (void)playTopBar:(DSDPlayTopBar *)bar settingBtnAction:(UIButton *)sender;
// 保存
- (void)playTopBar:(DSDPlayTopBar *)bar saveBtnAction:(UIButton *)sender;


@end

@interface DSDPlayTopBar : UIView

+ (instancetype)playTopBar;
@property (nonatomic, weak) NSObject<DSDPlayTopBarDelegate> *delegate;

//  readonly property
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UITextField *startBarTextField;
@property (nonatomic, strong, readonly) UITextField *endBarTextField;

@end
