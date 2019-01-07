//
//  DSDLeftMusicVC.m
//  DSDDemo
//
//  Created by HJR on 2018/12/24.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDLeftMusicVC.h"
#import "DSDLeftMusicCell.h"
#import "DSDLeftMusicModel.h"
#import "DSDLeftMusicFooter.h"
#import "DSDLeftMusicHeader.h"
#import "DSDLeftMusicSectionModel.h"

@interface DSDLeftMusicVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *firstDataArray;
@property (nonatomic, strong) NSMutableArray *secondDataArray;

@end

@implementation DSDLeftMusicVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configDefaultData];
}

- (void)configDefaultData
{
    NSArray *images = @[@"main_cell_all_music",@"main_cell_timer"];
    NSArray *titles = @[@"全部乐曲",@"最近使用"];
    NSMutableArray *firstArray = [NSMutableArray new];
    for (NSInteger i = 0; i < images.count; i++)
    {
        DSDLeftMusicModel *model = [DSDLeftMusicModel new];
        model.imageName = images[i];
        model.title = titles[i];
        [firstArray addObject:model];
    }
    
    self.firstDataArray = [firstArray copy];
}

#pragma mark - UITableViewDataSource | UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return self.firstDataArray.count;
    }
    else
    {
        return self.secondDataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        DSDLeftMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DSDLeftMusicCell"];
        
        DSDLeftMusicModel *model = self.firstDataArray[indexPath.row];
        cell.leftImageView.image = [UIImage imageNamed:model.imageName];
        cell.centetTitleLabel.text = model.title;
        cell.rightTitleLabel.text = model.count;
        
        return cell;
    }
    else
    {
        DSDLeftMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DSDLeftMusicCell"];
        
        DSDLeftMusicModel *model = self.secondDataArray[indexPath.row];
        cell.leftImageView.image = [UIImage imageNamed:model.imageName];
        cell.centetTitleLabel.text = model.title;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0)
    {
        return CGFLOAT_MIN;
    }
    return 55.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 34.0f;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return nil;
    }
    else
    {
        DSDLeftMusicHeader *header = [tableView dequeueReusableCellWithIdentifier:@"DSDLeftMusicHeader"];
        return header;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == 1)
    {
        DSDLeftMusicFooter *footer = [tableView dequeueReusableCellWithIdentifier:@"DSDLeftMusicFooter"];
        return footer;
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
