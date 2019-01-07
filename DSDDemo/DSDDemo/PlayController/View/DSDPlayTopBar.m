//
//  DSDPlayTopBar.m
//  DSDDemo
//
//  Created by HJR on 2018/12/22.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDPlayTopBar.h"

@interface DSDPlayTopBar ()
@property (weak, nonatomic) IBOutlet UIButton *increaseBtn;
@property (weak, nonatomic) IBOutlet UIButton *decreaseBtn;
@property (weak, nonatomic) IBOutlet UILabel *mTitleLabel;

@property (weak, nonatomic) IBOutlet UITextField *mStartBarTextField;
@property (weak, nonatomic) IBOutlet UITextField *mEndBarTextField;


@property (strong, nonatomic) NSTimer *topBarIncreaceLongPressTimer;
@property (strong, nonatomic) NSTimer *topBarDecreaceLongPressTimer;

@end

@implementation DSDPlayTopBar

+ (instancetype)playTopBar
{
    DSDPlayTopBar *aView = [[[NSBundle mainBundle] loadNibNamed:@"DSDPlayTopBar" owner:self options:nil] lastObject];
    NSCParameterAssert(aView);
    aView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    [aView addLongPressGesture];
    return aView;
}


#pragma mark - getter
- (UILabel *)titleLabel
{
    return _mTitleLabel;
}

- (UITextField *)startBarTextField
{
    return _mStartBarTextField;
}

- (UITextField *)endBarTextField
{
    return _mEndBarTextField;
}

#pragma mark - 长按
- (void)addLongPressGesture
{
    // 长按 +
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] init];
    [longPressGesture addTarget:self action:@selector(topBarIncreaceBtnLonPressed:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self.increaseBtn addGestureRecognizer:longPressGesture];
    
    // 长按 -
    UILongPressGestureRecognizer *longPressGesture1 = [[UILongPressGestureRecognizer alloc] init];
    [longPressGesture1 addTarget:self action:@selector(topBarDecreaceBtnLonPressed:)];
    longPressGesture1.minimumPressDuration = 0.5;
    [self.decreaseBtn addGestureRecognizer:longPressGesture1];
}

#pragma mark - action
- (IBAction)backBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:backBtnAction:)])
    {
        [self.delegate playTopBar:self backBtnAction:sender];
    }
}

- (IBAction)increaseBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:increaseBtnAction:)])
    {
        [self.delegate playTopBar:self increaseBtnAction:sender];
    }
}

- (IBAction)decreaseBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:decreaseBtnAction:)])
    {
        [self.delegate playTopBar:self decreaseBtnAction:sender];
    }
}

- (IBAction)beatsBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:beatsBtnAction:)])
    {
        [self.delegate playTopBar:self beatsBtnAction:sender];
    }
}

- (IBAction)modeSwitchBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:modeSwitchBtnAction:)])
    {
        [self.delegate playTopBar:self modeSwitchBtnAction:sender];
    }
}

- (IBAction)playBackBtnAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:playBackBtnAction:)])
    {
        [self.delegate playTopBar:self playBackBtnAction:sender];
    }
}

- (IBAction)playPauseBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:playPauseBtnAction:)])
    {
        [self.delegate playTopBar:self playPauseBtnAction:sender];
    }
}

- (IBAction)settingBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:settingBtnAction:)])
    {
        [self.delegate playTopBar:self settingBtnAction:sender];
    }
}

- (IBAction)saveBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBar:saveBtnAction:)])
    {
        [self.delegate playTopBar:self saveBtnAction:sender];
    }
}

#pragma mark - long press action
- (void)topBarIncreaceBtnLonPressed:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if (self.topBarIncreaceLongPressTimer)
        {
            [self.topBarIncreaceLongPressTimer invalidate];
            self.topBarIncreaceLongPressTimer = nil;
        }
        
        self.topBarIncreaceLongPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(topBarIncreaceTimerAction:) userInfo:nil repeats:YES];
        
    }
    else
    {
        [self.topBarIncreaceLongPressTimer invalidate];
        self.topBarIncreaceLongPressTimer = nil;
    }
    
}

- (void)topBarDecreaceBtnLonPressed:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if (self.topBarDecreaceLongPressTimer)
        {
            [self.topBarDecreaceLongPressTimer invalidate];
            self.topBarDecreaceLongPressTimer = nil;
        }
        
        self.topBarDecreaceLongPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(topBarDecreaceTimerAction:) userInfo:nil repeats:YES];
        
    }
    else
    {
        [self.topBarDecreaceLongPressTimer invalidate];
        self.topBarDecreaceLongPressTimer = nil;
    }
}

- (void)topBarIncreaceTimerAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBarIncreaseBtnLongpressedAction:)])
    {
        [self.delegate playTopBarIncreaseBtnLongpressedAction:self];
    }
}

- (void)topBarDecreaceTimerAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(playTopBarDecreaseBtnLongpressedAction:)])
    {
        [self.delegate playTopBarDecreaseBtnLongpressedAction:self];
    }
}


@end
