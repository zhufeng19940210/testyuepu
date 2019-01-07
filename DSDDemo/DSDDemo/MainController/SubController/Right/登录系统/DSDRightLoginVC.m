//
//  DSDRightLoginVC.m
//  DSDDemo
//
//  Created by HJR on 2018/12/24.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDRightLoginVC.h"

@interface DSDRightLoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation DSDRightLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



#pragma mark - action

- (IBAction)loginButtonAction:(id)sender
{
}

- (IBAction)changePasswordBtnAction:(id)sender
{
}

- (IBAction)registerBtnAction:(id)sender
{
    
}

- (IBAction)forgetPasswordBtnAction:(id)sender
{
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
