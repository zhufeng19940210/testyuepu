//
//  ModeSelectionViewController.h
//  DSDDemo
//
//  Created by Leong on 25/7/14.
//  Copyright (c) 2014 Leong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ModeSelectionViewController : UIViewController<UITableViewDelegate, UITextViewDelegate>{
    int mode;
    MBProgressHUD * hud;
    NSArray *fileList;
    int tempo;
    BOOL halfLine;
}

- (IBAction)modeSelected:(UISegmentedControl*)sender;
- (IBAction)download:(id)sender;
- (IBAction)halfLineEnable:(UISwitch *)sender;

@property (weak, nonatomic) IBOutlet UILabel *version;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITextField *tempoValue;
@end
