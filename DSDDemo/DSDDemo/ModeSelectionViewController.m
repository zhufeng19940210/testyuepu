//
//  ModeSelectionViewController.m
//  DSDDemo
//
//  Created by Leong on 25/7/14.
//  Copyright (c) 2014 Leong. All rights reserved.
//

#import "ModeSelectionViewController.h"

#import "ViewController.h"

#import "SSZipArchive.h"

#import <AFNetworking.h>
//#import <YTKNetwork.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#define PREFIX @"http://54.250.119.226/KwanCL/cms/data/"



@interface ModeSelectionViewController ()

@end


@implementation ModeSelectionViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    mode = 1;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/data"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        NSData * data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/data/data/info.json", DOCUMENTS_FOLDER]];
        NSDictionary * json = [data JSONObject] ;
        
        
        
        fileList = json[@"FileInfo"];
        
        [self.tableview reloadData];
    }
    
    halfLine = YES;
    tempo = 60;
    
    self.version.text = @"Demo Version 1.3.0";
    
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
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSLog(@"%@", NSStringFromCGSize(self.view.bounds.size));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)modeSelected:(UISegmentedControl*)sender {

    
    switch (sender.selectedSegmentIndex) {
        case 0:
            mode = 1;
            break;
        case 1:
            mode = 2;
            break;

        default:
            break;
    }
    
    
}

- (IBAction)download:(id)sender
{
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    /* 下载地址 */
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@data.zip", PREFIX]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    
    /* 下载路径 */
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [path stringByAppendingPathComponent:url.lastPathComponent];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSLog(@"下载完成");
        
    }];
    [downloadTask resume];

}


#if 0
- (IBAction)download1111:(id)sender {
    
    //=================HJR test
    
    
    
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
    
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"data/data.zip"];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setCompletionBlock:^()
     {
         
         [SSZipArchive unzipFileAtPath:filePath toDestination:[[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                                                        inDomains:NSUserDomainMask] objectAtIndex:0]
                                                                URLByAppendingPathComponent:@"data"] path]];
         
         [hud hide:YES];
         
         NSData * data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/data/data/info.json", DOCUMENTS_FOLDER]];
         NSDictionary * json = [data JSONObject] ;
         
         
         
         fileList = json[@"FileInfo"];
         
         
         [self.tableview reloadData];
         
     }];
    
    [operation start];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSLog(@"下载完成");
        
    }];
    [downloadTask resume];
    
}

#endif

- (IBAction)halfLineEnable:(UISwitch *)sender {
    
    halfLine = sender.isOn;
}

#pragma mark TextField


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self animateTextView: YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self animateTextView:NO];
}

- (void) animateTextView:(BOOL) up
{
    const int movementDistance = 180; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    NSLog(@"%d",movement);
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.inputView.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [fileList objectAtIndex:indexPath.row][@"fileName"];
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return fileList.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([self.tempoValue.text intValue] < 0){
        return;
    }
    
    NSString* filename = [fileList objectAtIndex:indexPath.row][@"path"];
    
    filename = [filename stringByReplacingOccurrencesOfString:@".csv" withString:@""];
    
    NSLog(@"%@",[fileList objectAtIndex:indexPath.row]);
    
    UIStoryboard * story = [self storyboard];
    
    ViewController * vc = [story instantiateViewControllerWithIdentifier:@"Main"];
    
    [vc setMode:mode andFile:filename andHalfLine:halfLine andTempo:[self.tempoValue.text intValue]];
    vc.fileName = [fileList objectAtIndex:indexPath.row][@"fileName"];;
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

@end
