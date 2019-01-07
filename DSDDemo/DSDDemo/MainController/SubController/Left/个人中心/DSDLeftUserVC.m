//
//  DSDLeftUserVC.m
//  DSDDemo
//
//  Created by HJR on 2018/12/24.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDLeftUserVC.h"
#import "DSDLeftUserModel.h"
#import "DSDLeftUserCell.h"

@interface DSDLeftUserVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DSDLeftUserVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [UIView new];
    [self configDefaultData];
}

- (void)configDefaultData
{
    NSArray *images = @[@"main_setting_mouse",@"main_setting_diamond",@"main_setting_equalizer",@"main_setting_like",@"main_setting_lamp"];
    NSArray *titles = @[@"登录系统",@"购买记录",@"系统设置",@"推荐朋友",@"意见反馈"];
    NSMutableArray *firstArray = [NSMutableArray new];
    for (NSInteger i = 0; i < images.count; i++)
    {
        DSDLeftUserModel *model = [DSDLeftUserModel new];
        model.imageName = images[i];
        model.title = titles[i];
        model.type = i;
        [firstArray addObject:model];
    }
    
    self.dataArray = firstArray;
}

#pragma mark - UITableViewDataSource | UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DSDLeftUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DSDLeftUserCell"];
    
    DSDLeftUserModel *model = self.dataArray[indexPath.row];
    cell.leftImageView.image = [UIImage imageNamed:model.imageName];
    cell.centetTitleLabel.text = model.title;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectCallback)
    {
        self.selectCallback(indexPath.row);
    }
    
    switch (indexPath.row) {
        case 0:// 登录
        {
        }
            break;
            case 1:
        {
        }
            break;
            case 2:
        {
        }
            break;
            case 3:
        {
        }
            break;
            case 4:
        {
        }
            break;
            case 5:
        {
        }
            break;
            case 6:
        {
        }
            break;
            
        default:
            break;
    }
}

@end
