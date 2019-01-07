//
//  DSDPlayPopover.m
//  DSDDemo
//
//  Created by HJR on 2018/12/22.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDPlayPopover.h"

@interface DSDPlayPopover ()
@property (weak, nonatomic) IBOutlet UITextField *mPrepareBeatsTextField;
@end

@implementation DSDPlayPopover

+ (instancetype)playPopover
{
    DSDPlayPopover *aView = [[[NSBundle mainBundle] loadNibNamed:@"DSDPlayPopover" owner:self options:nil] lastObject];
    NSCParameterAssert(aView);
    
    CGFloat w = 224;
    CGFloat h = 300;
    CGFloat y = 64;
    CGRect defaultFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - w, y, w, h);
    aView.frame = defaultFrame;
    return aView;
}

- (UITextField *)prepareBeatsTextField
{
    return _mPrepareBeatsTextField;
}

- (void)show
{
    self.hidden = NO;
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - action

// 半拍线
- (IBAction)halfBeatLineSwithAction:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(playPopover:halfBeatLineSwithAction:)])
    {
        [self.delegate playPopover:self halfBeatLineSwithAction:sender];
    }
}

// 指法
- (IBAction)fingeringSwitchAction:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(playPopover:fingeringSwitchAction:)])
    {
        [self.delegate playPopover:self fingeringSwitchAction:sender];
    }
}

// 显示左手
- (IBAction)showLeftHandSwitchAction:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(playPopover:showLeftHandSwitchAction:)])
    {
        [self.delegate playPopover:self showLeftHandSwitchAction:sender];
    }
}

// 显示右手
- (IBAction)showRightHandSwitchAction:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(playPopover:showRightHandSwitchAction:)])
    {
        [self.delegate playPopover:self showRightHandSwitchAction:sender];
    }
}

// 表情记号
- (IBAction)expressionSwitchAction:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(playPopover:expressionSwitchAction:)])
    {
        [self.delegate playPopover:self expressionSwitchAction:sender];
    }
}

// 预备拍-
- (IBAction)beatsDecreaceBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playPopover:beatsDecreaceBtnAction:)])
    {
        [self.delegate playPopover:self beatsDecreaceBtnAction:sender];
    }
}

// 预备拍+
- (IBAction)beatsIncreaceBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playPopover:beatsIncreaceBtnAction:)])
    {
        [self.delegate playPopover:self beatsIncreaceBtnAction:sender];
    }
}

// 还原乐谱
- (IBAction)resetScoreBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playPopover:resetScoreBtnAction:)])
    {
        [self.delegate playPopover:self resetScoreBtnAction:sender];
    }
}


@end
