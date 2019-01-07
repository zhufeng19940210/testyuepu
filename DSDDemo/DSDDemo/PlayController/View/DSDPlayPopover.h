//
//  DSDPlayPopover.h
//  DSDDemo
//
//  Created by HJR on 2018/12/22.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSDPlayPopover;
@protocol DSDPlayPopoverDelegate

// 半拍线
- (void)playPopover:(DSDPlayPopover *)popover halfBeatLineSwithAction:(UISwitch *)sender;

// 指法
- (void)playPopover:(DSDPlayPopover *)popover fingeringSwitchAction:(UISwitch *)sender;

// 显示左手
- (void)playPopover:(DSDPlayPopover *)popover showLeftHandSwitchAction:(UISwitch *)sender;

// 显示右手
- (void)playPopover:(DSDPlayPopover *)popover showRightHandSwitchAction:(UISwitch *)sender;

// 表情记号
- (void)playPopover:(DSDPlayPopover *)popover expressionSwitchAction:(UISwitch *)sender;

// 预备拍-
- (void)playPopover:(DSDPlayPopover *)popover beatsDecreaceBtnAction:(UIButton *)sender;

// 预备拍+
- (void)playPopover:(DSDPlayPopover *)popover beatsIncreaceBtnAction:(UIButton *)sender;

// 还原乐谱
- (void)playPopover:(DSDPlayPopover *)popover resetScoreBtnAction:(UIButton *)sender;

@end

@interface DSDPlayPopover : UIView

+ (instancetype)playPopover;
- (void)show;
- (void)dismiss;

@property (nonatomic, weak) NSObject<DSDPlayPopoverDelegate> *delegate;
@property (nonatomic, strong, readonly) UITextField *prepareBeatsTextField;

@end
