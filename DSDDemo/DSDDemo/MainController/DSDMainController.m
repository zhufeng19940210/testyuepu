//
//  DSDMainController.m
//  DSDDemo
//
//  Created by HJR on 2018/12/24.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDMainController.h"
#import "DSDLeftUserVC.h"

@interface DSDMainController ()
{
    NSInteger _selectedRightControllerIndex;
}

//-------------- left margin view
@property (weak, nonatomic) IBOutlet UIButton *myMusicButton;
//-------------- left container view
@property (weak, nonatomic) IBOutlet UIView *leftMyMusicView;
@property (weak, nonatomic) IBOutlet UIView *leftSettingView;
//-------------- right container view
@property (weak, nonatomic) IBOutlet UIView *rightMyMusicView;
@property (weak, nonatomic) IBOutlet UIView *rightLoginView;
@property (weak, nonatomic) IBOutlet UIView *rightBuyRecordView;
@property (weak, nonatomic) IBOutlet UIView *rightSettingView;
@property (weak, nonatomic) IBOutlet UIView *rightRecommendView;
@property (weak, nonatomic) IBOutlet UIView *rightFeedbackView;

//-------------- left child controller
@property (weak, nonatomic) DSDLeftUserVC *leftUserVC;

@end

@implementation DSDMainController

+ (DSDMainController *)controller
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DSDMainController *vc = [sb instantiateViewControllerWithIdentifier:@"DSDMainController"];
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self musicCenterBtnAction:nil];
}

#pragma mark - UI
- (void)hideAllLeftContainerView
{
    self.leftMyMusicView.hidden = YES;
    self.leftSettingView.hidden = YES;
}

- (void)hideAllRightContainerView
{
    self.rightMyMusicView.hidden = YES;
    self.rightLoginView.hidden = YES;
    self.rightBuyRecordView.hidden = YES;
    self.rightSettingView.hidden = YES;
    self.rightRecommendView.hidden = YES;
    self.rightFeedbackView.hidden = YES;
}

#pragma mark - action
// 乐曲中心
- (IBAction)musicCenterBtnAction:(UIButton *)sender
{
    [self hideAllLeftContainerView];
    [self hideAllRightContainerView];
    
    self.leftMyMusicView.hidden = NO;
    self.rightMyMusicView.hidden = NO;
    self.myMusicButton.selected = YES;
    self.myMusicButton.backgroundColor = [UIColor colorWithRed:33/255.0 green:169/255.0 blue:155/255.0 alpha:1];
}

// 用户中心
- (IBAction)userCenterBtnAction:(id)sender
{
    [self hideAllLeftContainerView];
    [self hideAllRightContainerView];
    
    self.leftSettingView.hidden = NO;
    self.myMusicButton.selected = NO;
    self.myMusicButton.backgroundColor = [UIColor clearColor];
    [self selectRightChildControllAtIndex:_selectedRightControllerIndex];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"DSDLeftUserVC"] && [segue.destinationViewController isKindOfClass:[DSDLeftUserVC class]])
    {
        self.leftUserVC = (DSDLeftUserVC *)segue.destinationViewController;
        
        __weak typeof(self) weakSelf = self;
        self.leftUserVC.selectCallback = ^(NSInteger index) {
            [weakSelf selectRightChildControllAtIndex:index];
        };
    }
    
}

- (void)selectRightChildControllAtIndex:(NSInteger)index
{
    _selectedRightControllerIndex = index;
    [self hideAllRightContainerView];
    switch (index) {
            case 0:// 登录
        {
            self.rightLoginView.hidden = NO;
        }
            break;
            case 1:// 购买记录
        {
            self.rightBuyRecordView.hidden = NO;
        }
            break;
            case 2:// 系统设置
        {
            self.rightSettingView.hidden = NO;
        }
            break;
            case 3:// 推荐朋友
        {
            self.rightRecommendView.hidden = NO;
        }
            break;
            case 4:// 意见反馈
        {
            self.rightFeedbackView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

@end
