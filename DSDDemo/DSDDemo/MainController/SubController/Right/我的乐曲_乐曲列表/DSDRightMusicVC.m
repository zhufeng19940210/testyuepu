//
//  DSDRightMusicVC.m
//  DSDDemo
//
//  Created by HJR on 2018/12/24.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDRightMusicVC.h"
#import "DSDRightMusicNormalCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SSZipArchive.h"
#import <AFNetworking.h>
#import "ViewController.h"
#import <MJRefresh.h>

@interface DSDRightMusicVC ()<UITableViewDelegate,UITableViewDataSource>
{
    int mode;
    MBProgressHUD * hud;
    NSArray *fileList;
    int tempo;
    BOOL halfLine;
}

/*
 {
 ID = 2515;
 fileName = qq;
 path = "17427895bf75e68be76e.csv";
 }
 */
@property (nonatomic, strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#define PREFIX @"http://54.250.119.226/KwanCL/cms/data/"

@implementation DSDRightMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/data"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        NSData * data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/data/data/info.json", DOCUMENTS_FOLDER]];
        NSDictionary * json = [data JSONObject] ;
        
        
        
        fileList = json[@"FileInfo"];
        self.dataArray = fileList;
        
        [self.tableView reloadData];
    }
    
    halfLine = YES;
    tempo = 60;
    
    
    //==============HJR test  倒序
//    fileList =
//    [[fileList reverseObjectEnumerator] allObjects];
    
    //==============HJR test 把小圆舞曲放到最前面方便调试
    for (NSInteger i = 0; i < fileList.count;i++)
    {
        NSDictionary *dict = fileList[i];
        if ([dict[@"ID"] integerValue] == 2226)
        {
            NSMutableArray *temp = [fileList mutableCopy];
            [temp exchangeObjectAtIndex:0 withObjectAtIndex:i];
            fileList = temp;
            break;
        }
    }
    
    self.dataArray = fileList;
    
    if(fileList.count < 1)
    {
        [self download:nil];
    }
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(download:)];
}

- (IBAction)download:(id)sender
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Downloading";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/data"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    else{
        NSError *error = nil;
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:&error]) {
            NSLog(@"%@", file);
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", dataPath, file] error:&error];
            if (!success || error) {
                NSLog(@"%@", [error description]);
            }
        }
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@data.zip", PREFIX]]];
    
    
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *resultFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"data/data.zip"];
//    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    
    
//    [operation setCompletionBlock:^()
//     {
//
//         [SSZipArchive unzipFileAtPath:filePath toDestination:[[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
//                                                                                                        inDomains:NSUserDomainMask] objectAtIndex:0]
//                                                                URLByAppendingPathComponent:@"data"] path]];
//
//         [hud hide:YES];
//
//         NSData * data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/data/data/info.json", DOCUMENTS_FOLDER]];
//         NSDictionary * json = [data JSONObject] ;
//
//
//
//         fileList = json[@"FileInfo"];
//
//
//         [self.tableview reloadData];
//
//     }];
    
//    [operation start];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:resultFilePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [SSZipArchive unzipFileAtPath:resultFilePath toDestination:[[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                                                       inDomains:NSUserDomainMask] objectAtIndex:0]
                                                               URLByAppendingPathComponent:@"data"] path]];
        
        [hud hide:YES];
        NSData * data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/data/data/info.json", DOCUMENTS_FOLDER]];
        NSDictionary * json = [data JSONObject] ;
        
        fileList = json[@"FileInfo"];
        self.dataArray = fileList;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
    
    [downloadTask resume];
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
    DSDRightMusicNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DSDRightMusicNormalCell"];
    
    NSDictionary *dict = self.dataArray[indexPath.row];
//    {
//        ID = 2515;
//        fileName = qq;
//        path = "17427895bf75e68be76e.csv";
//    }
    cell.mainTitleLabel.text = dict[@"fileName"];
    cell.subTitleLabel.text = nil;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* filename = [fileList objectAtIndex:indexPath.row][@"path"];
    
    filename = [filename stringByReplacingOccurrencesOfString:@".csv" withString:@""];
    
    NSLog(@"%@",[fileList objectAtIndex:indexPath.row]);
    
    ViewController * vc = [ViewController controller];
    
    [vc setMode:mode andFile:filename andHalfLine:YES andTempo:60];
    vc.fileName = [fileList objectAtIndex:indexPath.row][@"fileName"];
    
    [self presentViewController:vc animated:YES completion:nil];
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
