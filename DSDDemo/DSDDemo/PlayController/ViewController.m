//
//  ViewController.m
//  DSDDemo
//
//  Created by Leong on 18/1/13.
//  Copyright (c) 2013 Leong. All rights reserved.
//

#import "ViewController.h"

#include <sys/types.h>

#include <sys/sysctl.h>

#import <QuartzCore/QuartzCore.h>

#import "CSVParser.h"

#import "UIView+Roundify.h"

#import "DottedLine.h"

#import "Tempo.h"

#import "TriangleView.h"

#import "NShape.h"
#import "DSDPlayMacro.h"

#import "DSDShaderModel.h"
#import "DSDPlayManager.h"
#import "WZBCountDownButton.h"
#import "DSDDisplayModel.h"
#import "DSDPlayTopBar.h"
#import "DSDPlayPopover.h"

#define EDGE self.view.frame.size.width*0.7

static NSInteger const DSDhalfBeatLineTag = 10000000;
static NSInteger const DSDRightHandViewsTag = 1000100;
static NSInteger const DSDLeftHandViewsTag = 1000200;
static NSInteger const DSDFingeringViewsTag = 1000800;
static NSInteger const DSDExpressionViewsTag = 2000000;

@interface ViewController ()
<UIScrollViewDelegate,
DSDPlayTopBarDelegate,
DSDPlayPopoverDelegate,
UITextFieldDelegate
>

{
    int startPage;
    
    CGFloat ratio;
    
    NSMutableArray * displayArray;
    NSArray<DSDDisplayModel *> *_displayArray;
    NSDictionary *_expressionDictionary;
}

// 当前的播放模式: NO-演奏模式; YES-练习模式;（默认为NO）
@property (nonatomic, assign) BOOL isPracticeType;

// 当前乐谱是否正在演奏(在演奏模式下点击过▶️按钮)
@property (nonatomic, assign) BOOL isPlaying;

// ----- topbar
@property (weak, nonatomic) IBOutlet UIButton *topBarIncreaceBtn;
@property (weak, nonatomic) IBOutlet UIButton *topBarDecreaceBtn;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) DSDPlayTopBar *playTopBarView;


// ----- timer
@property (strong, nonatomic) NSTimer *topBarIncreaceLongPressTimer;
@property (strong, nonatomic) NSTimer *topBarDecreaceLongPressTimer;
@property (strong, nonatomic) NSTimer *beatsTimer;
@property (strong, nonatomic) NSTimer *prepareBeatsTimer;// 预备拍定时器

// ----- setting DSDPlayPopover
@property (weak, nonatomic) IBOutlet UIView *settingPopoverView;
@property (strong, nonatomic)  DSDPlayPopover *settingPopover;


// ----- play manager
@property (strong, nonatomic) DSDPlayManager *playManager;

#pragma mark - debug
@property (weak, nonatomic) IBOutlet UILabel *debugLenghtLabel;
@property (weak, nonatomic) IBOutlet UILabel *debugTimeLabel;

@end

@implementation ViewController

+ (instancetype)controller
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DSDPlayController"];
    return vc;
}

#pragma mark - config data
- (void)setMode:(int)_mode andFile:(NSString*)_name andHalfLine:(BOOL)enabled andTempo:(int)_t
{
    mode = _mode;
    fileName = _name;
    halfLine = enabled;
    minimunTempo = _t;
}

#pragma mark - view life cycle
- (void)dealloc
{
    [self.beatsTimer invalidate];
    self.beatsTimer = nil;
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playManager = [DSDPlayManager manager];
    [self configTopBar];
    
    ratio = [UIScreen mainScreen].scale; // HJR 2018-12-04
    ratio = ratio * self.scrollView.bounds.size.height/768;
    colorArray = [[NSMutableArray alloc] initWithObjects:[UIColor blackColor],
                  [UIColor colorWithRed:255.0/255.0 green:217/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:255.0/255.0 green:13/255.0 blue:13/255.0 alpha:1.0],
                  [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:45/255.0 green:45/255.0 blue:255/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:95/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:143/255.0 green:57/255.0 blue:215/255.0 alpha:1.0],
                  
                  [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0],
                  [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0],
                  [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0],
                  
                  [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0],
                  [UIColor colorWithRed:154/255.0 green:132/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:255/255.0 green:51/255.0 blue:51/255.0 alpha:1.0],
                  [UIColor colorWithRed:165/255.0 green:76/255.0 blue:5/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:89/255.0 blue:162/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:176/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:169/255.0 green:102/255.0 blue:224/255.0 alpha:1.0],
                  
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  nil];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/data/data/%@.csv", fileName]];
    
    NSArray * arrayOfDictionaries = [CSVParser parseCSVIntoArrayOfDictionariesFromFile:file
                                                          withSeparatedCharacterString:@","
                                                                  quoteCharacterString:@"\""];
    //Channel 42
    displayArray = [[NSMutableArray alloc] init];
    
    //Channel 41
    self.shadowArray = [[NSMutableArray alloc] init];
    
    tempoArray = [[NSMutableArray alloc] init];
    
    upBtnControls = [[NSMutableArray alloc] init];
    
    downBtnControls = [[NSMutableArray alloc] init];
    
    tempLabelControls = [[NSMutableArray alloc] init];
    
    groupControls = [[NSMutableArray alloc] init];
    
    circlesArray = [[NSMutableArray alloc] init];
    
    UIView * circle = [[UIView alloc] initWithFrame:CGRectMake(100,100,12,12)];
    circle.alpha = 1;
    circle.layer.cornerRadius = 6;
    circle.backgroundColor = [UIColor redColor];
    circle.hidden = YES;
    [self.view addSubview:circle];
    
    [circlesArray addObject:circle];
    circle = [[UIView alloc] initWithFrame:CGRectMake(100,100,12,12)];
    circle.alpha = 1;
    circle.layer.cornerRadius = 6;
    circle.backgroundColor = [UIColor blueColor];
    circle.hidden = YES;
    [self.view addSubview:circle];
    
    [circlesArray addObject:circle];
    circle = [[UIView alloc] initWithFrame:CGRectMake(100,100,12,12)];
    circle.alpha = 1;
    circle.layer.cornerRadius = 6;
    circle.backgroundColor = [UIColor greenColor];
    circle.hidden = YES;
    [self.view addSubview:circle];
    
    [circlesArray addObject:circle];
    circle = [[UIView alloc] initWithFrame:CGRectMake(100,100,12,12)];
    circle.alpha = 1;
    circle.layer.cornerRadius = 6;
    circle.backgroundColor = [UIColor blueColor];
    circle.hidden = YES;
    [self.view addSubview:circle];
    [circlesArray addObject:circle];
    
    NSUserDefaults *storeData=[NSUserDefaults standardUserDefaults];
    
    if([storeData valueForKey:fileName] != nil){
        self.shadowArray = [storeData valueForKey:fileName];
        [self.playManager updateShadowArray:self.shadowArray];
    }
    
    for (NSDictionary * dict in arrayOfDictionaries) {
        
        [self drawData:dict];
        
        if([[NSUserDefaults standardUserDefaults] valueForKey:fileName] == nil){
            if([[dict objectForKey:@"channel"] isEqualToString:@"41"]){
                [self.shadowArray addObject:dict];
            }
        }
        
        
        if([[dict objectForKey:@"channel"] isEqualToString:@"42"]){
            [displayArray addObject:dict];
            totalLength += [[dict objectForKey:@"length(109)"] intValue];
        }
    }
    [self.playManager updateShadowArray:self.shadowArray];
    
    if (!halfLine)
    {
        [self hideHalfBeatLine];
    }
    
    NSCParameterAssert(ratio > 0);
    self.scrollView.contentSize = CGSizeMake((totalLength + 80)/ratio , SHEET_HEIGHT);
    
    /*Sorting Channel 42 & 41 Array if the data is not start by Zero*/
    NSArray * sortedArray;
    sortedArray = [displayArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * a, NSDictionary * b) {
        int first = [a[@"Bar No(40)"] intValue];
        int second = [b[@"Bar No(40)"] intValue];
        
        if (first > second) {
            return (NSComparisonResult)NSOrderedDescending;
        } else
            return (NSComparisonResult)NSOrderedAscending;
    }];
    
    displayArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    NSCParameterAssert(self.playManager);
    [self.playManager setDisplayArray:displayArray];
    
    sortedArray = [self.shadowArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * a, NSDictionary * b) {
        int first = [a[@"Bar No(40)"] intValue];
        int second = [b[@"Bar No(40)"] intValue];
        
        if (first > second) {
            return (NSComparisonResult)NSOrderedDescending;
        } else
            return (NSComparisonResult)NSOrderedAscending;
    }];
    
    self.shadowArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    [self.playManager updateShadowArray:self.shadowArray];
    /*End of Sorting*/
    
    index = 0;
    
    timerFactor = 1;
    
    timer = [[NSTimer alloc]init];
    
    startPage = [displayArray[0][@"Bar No(40)"] intValue];
    
    page = 1;
    
    totalLength = 0;
    
    shaderIndex = 1;
    
    [self initGlobalFactor];
    
    /*Assume the number of channel 42 is equal to the total number of pages*/
    maxPage = ([displayArray[0][@"Bar No(40)"] intValue] == 0)?displayArray.count:displayArray.count+1;

    /*Arragne Shaders*/
    CGFloat x = [[[self.shadowArray objectAtIndex:index] objectForKey:@"ipad_col(107)"] intValue]/ratio;
    CGFloat y = [[[self.shadowArray objectAtIndex:index] objectForKey:@"ipad_rows"] intValue]/ratio;
    CGFloat h = [[[self.shadowArray objectAtIndex:index] objectForKey:@"height(110)"] intValue]/ratio;
    CGFloat w = [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/ratio;
    
    self.finalshader.frame = CGRectMake(x, y, w, h);
    
    circleIndex = 0;
    [self rearrangeTempoControls];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

 //   self.finalshader.frame = CGRectMake(self.rightShader.frame.origin.x - [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/ratio, 182/(ratio/2) + 12/(ratio/2), [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/ratio, 12/(ratio/2));
    
    [self updateRepeatBarInfo];
    [self showCircularView];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPercentageLabel:nil];
    [self setPanelView:nil];
    [self setTimeLabel2:nil];
    [self setTimeLabel1:nil];
    [self setTimeLabel3:nil];
    [self setTimeLabel4:nil];
    [self setTime1:nil];
    [self setTime2:nil];
    [self setTime3:nil];
    [self setTime4:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UI
- (void)setupUI
{
    [self configTopBar];
    
    ratio = [UIScreen mainScreen].scale; // HJR 2018-12-04
    ratio = ratio * self.scrollView.bounds.size.height/768;
    colorArray = [[NSMutableArray alloc] initWithObjects:[UIColor blackColor],
                  [UIColor colorWithRed:255.0/255.0 green:217/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:255.0/255.0 green:13/255.0 blue:13/255.0 alpha:1.0],
                  [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:45/255.0 green:45/255.0 blue:255/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:95/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:143/255.0 green:57/255.0 blue:215/255.0 alpha:1.0],
                  
                  [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0],
                  [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0],
                  [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0],
                  
                  [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0],
                  [UIColor colorWithRed:154/255.0 green:132/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:255/255.0 green:51/255.0 blue:51/255.0 alpha:1.0],
                  [UIColor colorWithRed:165/255.0 green:76/255.0 blue:5/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:89/255.0 blue:162/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:176/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:169/255.0 green:102/255.0 blue:224/255.0 alpha:1.0],
                  
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                  nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/data/data/%@.csv", fileName]];
    
    NSArray * arrayOfDictionaries = [CSVParser parseCSVIntoArrayOfDictionariesFromFile:file
                                                          withSeparatedCharacterString:@","
                                                                  quoteCharacterString:@"\""];
    //Channel 42
    displayArray = [[NSMutableArray alloc] init];
    
    //Channel 41
    self.shadowArray = [[NSMutableArray alloc] init];
    
    tempoArray = [[NSMutableArray alloc] init];
    
    upBtnControls = [[NSMutableArray alloc] init];
    
    downBtnControls = [[NSMutableArray alloc] init];
    
    tempLabelControls = [[NSMutableArray alloc] init];
    
    groupControls = [[NSMutableArray alloc] init];
    
    circlesArray = [[NSMutableArray alloc] init];
    
    UIView * circle = [[UIView alloc] initWithFrame:CGRectMake(100,100,12,12)];
    circle.alpha = 1;
    circle.layer.cornerRadius = 6;
    circle.backgroundColor = [UIColor redColor];
    circle.hidden = YES;
    [self.view addSubview:circle];
    
    [circlesArray addObject:circle];
    circle = [[UIView alloc] initWithFrame:CGRectMake(100,100,12,12)];
    circle.alpha = 1;
    circle.layer.cornerRadius = 6;
    circle.backgroundColor = [UIColor blueColor];
    circle.hidden = YES;
    [self.view addSubview:circle];
    
    [circlesArray addObject:circle];
    circle = [[UIView alloc] initWithFrame:CGRectMake(100,100,12,12)];
    circle.alpha = 1;
    circle.layer.cornerRadius = 6;
    circle.backgroundColor = [UIColor greenColor];
    circle.hidden = YES;
    [self.view addSubview:circle];
    
    [circlesArray addObject:circle];
    circle = [[UIView alloc] initWithFrame:CGRectMake(100,100,12,12)];
    circle.alpha = 1;
    circle.layer.cornerRadius = 6;
    circle.backgroundColor = [UIColor blueColor];
    circle.hidden = YES;
    [self.view addSubview:circle];
    [circlesArray addObject:circle];
    
    NSUserDefaults *storeData=[NSUserDefaults standardUserDefaults];
    
    if([storeData valueForKey:fileName] != nil){
        self.shadowArray = [storeData valueForKey:fileName];
        [self.playManager updateShadowArray:self.shadowArray];
    }
    
    for (NSDictionary * dict in arrayOfDictionaries) {
        
        [self drawData:dict];
        
        if([[NSUserDefaults standardUserDefaults] valueForKey:fileName] == nil){
            if([[dict objectForKey:@"channel"] isEqualToString:@"41"]){
                [self.shadowArray addObject:dict];
            }
        }
        
        
        if([[dict objectForKey:@"channel"] isEqualToString:@"42"]){
            [displayArray addObject:dict];
            totalLength += [[dict objectForKey:@"length(109)"] intValue];
        }
    }
    [self.playManager updateShadowArray:self.shadowArray];
    
    if (!halfLine)
    {
        [self hideHalfBeatLine];
    }
    
    NSCParameterAssert(ratio > 0);
    self.scrollView.contentSize = CGSizeMake((totalLength + 80)/ratio , SHEET_HEIGHT);
    
    /*Sorting Channel 42 & 41 Array if the data is not start by Zero*/
    NSArray * sortedArray;
    sortedArray = [displayArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * a, NSDictionary * b) {
        int first = [a[@"Bar No(40)"] intValue];
        int second = [b[@"Bar No(40)"] intValue];
        
        if (first > second) {
            return (NSComparisonResult)NSOrderedDescending;
        } else
            return (NSComparisonResult)NSOrderedAscending;
    }];
    
    displayArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    sortedArray = [self.shadowArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * a, NSDictionary * b) {
        int first = [a[@"Bar No(40)"] intValue];
        int second = [b[@"Bar No(40)"] intValue];
        
        if (first > second) {
            return (NSComparisonResult)NSOrderedDescending;
        } else
            return (NSComparisonResult)NSOrderedAscending;
    }];
    
    self.shadowArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    [self.playManager updateShadowArray:self.shadowArray];
    /*End of Sorting*/
    
    index = 0;
    
    timerFactor = 1;
    
    timer = [[NSTimer alloc]init];
    
    startPage = [displayArray[0][@"Bar No(40)"] intValue];
    
    page = 1;
    
    totalLength = 0;
    
    shaderIndex = 1;
    
    [self initGlobalFactor];
    
    /*Assume the number of channel 42 is equal to the total number of pages*/
    maxPage = ([displayArray[0][@"Bar No(40)"] intValue] == 0)?displayArray.count:displayArray.count+1;
    
    /*Arragne Shaders*/
    CGFloat x = [[[self.shadowArray objectAtIndex:index] objectForKey:@"ipad_col(107)"] intValue]/ratio;
    CGFloat y = [[[self.shadowArray objectAtIndex:index] objectForKey:@"ipad_rows"] intValue]/ratio;
    CGFloat h = [[[self.shadowArray objectAtIndex:index] objectForKey:@"height(110)"] intValue]/ratio;
    CGFloat w = [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/ratio;
    
    self.finalshader.frame = CGRectMake(x, y, w, h);
    
    circleIndex = 0;
    [self rearrangeTempoControls];
}

- (void)reset
{
    [self setScrollView:nil];
    [self setPercentageLabel:nil];
    [self setPanelView:nil];
    [self setTimeLabel2:nil];
    [self setTimeLabel1:nil];
    [self setTimeLabel3:nil];
    [self setTimeLabel4:nil];
    [self setTime1:nil];
    [self setTime2:nil];
    [self setTime3:nil];
    [self setTime4:nil];
}

- (void)configTopBar
{
    DSDPlayTopBar *topbar = [DSDPlayTopBar playTopBar];
    self.playTopBarView = topbar;
    topbar.delegate = self;
    topbar.titleLabel.text = self.fileName;
    [self.view addSubview:topbar];
    
    topbar.startBarTextField.delegate = self;
    topbar.endBarTextField.delegate = self;
}

// 更新顶部条中显示的开始小节和结束小节
- (void)updateRepeatBarInfo
{
    NSInteger startIndex = self.playManager.repeatStartBarIndex;
    NSInteger endIndex = self.playManager.repeatEndBarIndex;
    
    self.playTopBarView.startBarTextField.text = [NSString stringWithFormat:@"%@",@(startIndex)];
    self.playTopBarView.endBarTextField.text = [NSString stringWithFormat:@"%@",@(endIndex)];
}

#pragma mark - top bar action (deprecated)

- (IBAction)repeatControlChanged:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 1)
    {
        
        int _start = [self.start_TF.text intValue];
        int _end = [self.end_TF.text intValue];
        
        if( _end > maxPage){
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid input value" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
            [sender setSelectedSegmentIndex:0];
            
            return;
            
        }
        
        if(_start == _end)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Starting bar cannot be same as ending bar" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [sender setSelectedSegmentIndex:0];
            return;
        }
        
        if(_start > _end)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid input value" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
            [sender setSelectedSegmentIndex:0];
            
            return;
            
        }
        
        // 1. 更新数据源
        [self.playManager updateDisplayArray:_start endBar:_end];
        
        // 2.跳转到开始小节
        DSDDisplayModel *startModel = [self.playManager displayModelWithBar:_start];
        NSInteger offset = [startModel.ipadCol107 integerValue] - 80;
        [self.scrollView setContentOffset:CGPointMake(offset/ratio,0) animated:YES];
        
        // 3.节拍器跳转到开始小节
        for (NSInteger i =0; i < self.shadowArray.count; i++)
        {
            NSDictionary *dict = self.shadowArray[i];
            DSDShaderModel *model = [DSDShaderModel yy_modelWithJSON:dict];
            if ([model.barNo40 isEqualToString:self.start_TF.text])
            {
                self.playManager.shaderCurrentIndex = i;
                break;
            }
        }
        [self moveBeatsShader];
        
    }
    else
    {
        [self skipToPage:[displayArray[0][@"Bar No(40)"] intValue]];
        startPage = 1;
        maxPage = ([displayArray[0][@"Bar No(40)"] intValue] == 0)?displayArray.count-1:displayArray.count;
        
//        self.finalshader.frame = CGRectMake(self.rightShader.frame.origin.x - [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/2, 182, [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/2, 12);
    }
    
    shaderIndex = 1;
    circleIndex = 0;
    [self showCircularView];
}

//===============HJR 原来的代码，暂时保留
- (IBAction)repeatControlChanged1:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 1)
    {
        
        int _start = [self.start_TF.text intValue];
        int _end = [self.end_TF.text intValue];
        
        if( _end > maxPage){
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid input value" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
            [sender setSelectedSegmentIndex:0];
            
            return;
            
        }
        
        if(_start == _end)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Starting bar cannot be same as ending bar" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [sender setSelectedSegmentIndex:0];
            return;
        }
        
        if(_start > _end)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid input value" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
            [sender setSelectedSegmentIndex:0];
            
            return;
            
        }
        
        if(_start == (int)nil)
            _start = 0;
        
        [self skipToPage:_start];
        startPage = _start;
        maxPage = (_start == 0)?_end+1:_end;

    }
    else
    {
        [self skipToPage:[displayArray[0][@"Bar No(40)"] intValue]];
        startPage = 1;
        maxPage = ([displayArray[0][@"Bar No(40)"] intValue] == 0)?displayArray.count-1:displayArray.count;
        
//        self.finalshader.frame = CGRectMake(self.rightShader.frame.origin.x - [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/2, 182, [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/2, 12);
    }
    
    shaderIndex = 1;
    circleIndex = 0;
    [self showCircularView];
}

#pragma mark - DSDPlayTopBarDelegate

// 「我的乐曲」按钮点击
- (void)playTopBar:(DSDPlayTopBar *)bar backBtnAction:(UIButton *)sender
{
    [timer invalidate];
    [self.beatsTimer invalidate];
    self.beatsTimer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

// tempo +
- (void)playTopBar:(DSDPlayTopBar *)bar increaseBtnAction:(UIButton *)sender;
{
    global_factor = 1;
    [self tempoValue];
}

// tempo + 长按事件
- (void)playTopBarIncreaseBtnLongpressedAction:(DSDPlayTopBar *)bar
{
    global_factor = 1;
    [self tempoValue];
}


// tempo -
- (void)playTopBar:(DSDPlayTopBar *)bar decreaseBtnAction:(UIButton *)sender
{
    global_factor = -1;
    [self tempoValue];
}

// tempo - 长按事件
- (void)playTopBarDecreaseBtnLongpressedAction:(DSDPlayTopBar *)bar;
{
    global_factor = -1;
    [self tempoValue];
}

// 节拍器开关
- (void)playTopBar:(DSDPlayTopBar *)bar beatsBtnAction:(UIButton *)sender
{
///=============HJR
    NSLog(@"TODO ");
}


// 演奏/练习模式切换
- (void)playTopBar:(DSDPlayTopBar *)bar modeSwitchBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.isPracticeType = sender.selected;
    self.finalshader.hidden = !self.isPracticeType;
}

// 小节快速返回
- (void)playTopBar:(DSDPlayTopBar *)bar playBackBtnAction:(UIButton *)sender
{
    NSLog(@"TODO ");
    ///=============HJR
}

// 暂停/播放
- (void)playTopBar:(DSDPlayTopBar *)bar playPauseBtnAction:(UIButton *)sender
{
    // 练习模式：节拍器跳动
    if (self.isPracticeType == YES)
    {
        if (!sender.selected)
        {
            [self practicePlayAction];
            self.scrollView.userInteractionEnabled = NO;
        }
        else
        {
            [self practicePauseAction];
            self.scrollView.userInteractionEnabled = YES;
        }
        sender.selected = !sender.selected;
    }
    // 演奏模式：节拍器不跳动，乐谱自动滑动
    else
    {
        [timer invalidate];
        [circletimer invalidate];
        
        if (!sender.selected)
        {
            if (!self.isPlaying)
            {
                [self startScrollViewScroll];
                [self resumeScrollViewScroll];
            }
            else
            {
                [self resumeScrollViewScroll];
            }
            self.isPlaying = YES;
            self.scrollView.userInteractionEnabled = NO;
        }
        else
        {
            [self pauseScrollViewScroll];
            self.scrollView.userInteractionEnabled = YES;
        }
        
        sender.selected = !sender.selected;
    }
    
    [self.repeat_SC setEnabled:NO];
}

// 设置
- (void)playTopBar:(DSDPlayTopBar *)bar settingBtnAction:(UIButton *)sender
{
    if (!self.settingPopover)
    {
        self.settingPopover = [DSDPlayPopover playPopover];
        self.settingPopover.delegate = self;
        [self.view addSubview:self.settingPopover];
    }
    
    if (sender.selected)
    {
        [self.settingPopover dismiss];
    }
    else
    {
        [self.settingPopover show];
    }
    
    sender.selected = !sender.selected;
}

// 保存
- (void)playTopBar:(DSDPlayTopBar *)bar saveBtnAction:(UIButton *)sender
{
    for (NSMutableArray * group in tempLabelControls)
    {
        for (Tempo * label in group)
        {
            if(label.shouldBeHide)
                label.hidden = YES;
        }
    }
    
    for (UIButton * btn in upBtnControls)
    {
        btn.hidden = YES;
    }
    
    for (UIButton * btn in downBtnControls)
    {
        btn.hidden = YES;
    }
    
    NSUserDefaults *storeData=[NSUserDefaults standardUserDefaults];
    [storeData setObject:self.shadowArray forKey:fileName];
    [storeData synchronize];
    
    [self rearrangeTempoControls];
}

#pragma mark - DSDPlayPopoverDelegate
// 半拍线
- (void)playPopover:(DSDPlayPopover *)popover halfBeatLineSwithAction:(UISwitch *)sender
{
    if (sender.isOn)
    {
        [self showHalfBeatLine];
    }
    else
    {
        [self hideHalfBeatLine];
    }
}

// 指法
- (void)playPopover:(DSDPlayPopover *)popover fingeringSwitchAction:(UISwitch *)sender
{
    // channel 135、235 是指法数据
    for (UIView *aView in self.scrollView.subviews)
    {
        if (aView.tag == DSDFingeringViewsTag)
        {
            aView.hidden = !sender.on;
        }
    }
}

// 显示左手
- (void)playPopover:(DSDPlayPopover *)popover showLeftHandSwitchAction:(UISwitch *)sender
{
    //chanel 200-299 是左手的数据
    for (UIView *aView in self.scrollView.subviews)
    {
        if (aView.tag == DSDLeftHandViewsTag)
        {
            aView.hidden = !sender.on;
        }
    }
}

// 显示右手
- (void)playPopover:(DSDPlayPopover *)popover showRightHandSwitchAction:(UISwitch *)sender
{
    // chanel 100-199 是左右的数据
    for (UIView *aView in self.scrollView.subviews)
    {
        if (aView.tag == DSDRightHandViewsTag)
        {
            aView.hidden = !sender.on;
        }
    }
}

// 表情记号
- (void)playPopover:(DSDPlayPopover *)popover expressionSwitchAction:(UISwitch *)sender
{
    for (UIView *aView in self.scrollView.subviews)
    {
        if (aView.tag == DSDExpressionViewsTag)
        {
            aView.hidden = !sender.on;
        }
    }
}

// 预备拍-
- (void)playPopover:(DSDPlayPopover *)popover beatsDecreaceBtnAction:(UIButton *)sender
{
    NSString *text = popover.prepareBeatsTextField.text;
    if ([text integerValue] > 0 )
    {
        NSInteger count = [text integerValue] - 1;
        popover.prepareBeatsTextField.text = [NSString stringWithFormat:@"%@",@(count)];
    }
    
    self.playManager.prepareBeats = [popover.prepareBeatsTextField.text integerValue];
}

// 预备拍+
- (void)playPopover:(DSDPlayPopover *)popover beatsIncreaceBtnAction:(UIButton *)sender
{
    NSString *text = popover.prepareBeatsTextField.text;
    NSInteger count = [text integerValue] + 1;
    popover.prepareBeatsTextField.text = [NSString stringWithFormat:@"%@",@(count)];
    
    self.playManager.prepareBeats = [popover.prepareBeatsTextField.text integerValue];
}

// 还原乐谱
- (void)playPopover:(DSDPlayPopover *)popover resetScoreBtnAction:(UIButton *)sender
{
    NSUserDefaults *storeData = [NSUserDefaults standardUserDefaults];
    [storeData removeObjectForKey:fileName];
    
    [timer invalidate];
    [self dismissViewControllerAnimated:YES completion:^{
        UIStoryboard * story = [self storyboard];
        ViewController * vc = [story instantiateViewControllerWithIdentifier:@"Main"];
        
        [vc setMode:mode andFile:fileName andHalfLine:halfLine andTempo:minimunTempo];
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootVC presentViewController:vc animated:YES completion:nil];
    }];
}

#pragma mark - 预备拍
- (void)startPrepareBeatsTimer
{
    if ([_prepareBeatsTimer isValid])
    {
        [_prepareBeatsTimer invalidate];
        _prepareBeatsTimer = nil;
    }
    
    NSArray *array = [self.playManager getPrepareBeatsArray];
    DSDShaderModel *model = array[self.playManager.prepareShaderIndex];
    CGFloat duration = 60/[model.tempo40 floatValue];
    
    _prepareBeatsTimer =  [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(prepareBeatsTimerAction:) userInfo:nil repeats:NO];
}

- (void)prepareBeatsTimerAction:(NSTimer *)timer
{
    NSArray *array = [self.playManager getPrepareBeatsArray];
    if (self.playManager.prepareShaderIndex < (array.count - 1))
    {
         self.playManager.prepareShaderIndex++;
    }
    else
    {
        self.playManager.prepareBeatsPlayCount++;// 预备拍已经播放完成了1次
        if (self.playManager.prepareBeatsPlayCount == self.playManager.prepareBeats)
        {// 预备拍播放完成了,开始播放正常拍
            
            // 跳转到开始小节
            DSDShaderModel *shader = [array firstObject];
            CGFloat x = [shader.ipadCol107 intValue]/ratio;
            CGFloat h = [shader.height110 intValue]/ratio;
            CGFloat y = [shader.ipadRows intValue]/ratio;
            CGFloat w = [shader.length109 intValue]/ratio;
            self.finalshader.frame = CGRectMake(x, y, w, h);
            
            // 在开始小节显示完了开始正常打拍
//            CGFloat duration = 60/[shader.tempo40 floatValue];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startBeatsTimer];
//            });
            
            return;
        }
        
        self.playManager.prepareShaderIndex = 0;
        
    }
   
    DSDShaderModel *shader = array[self.playManager.prepareShaderIndex];
    CGFloat x = [shader.ipadCol107 intValue]/ratio;
    CGFloat h = [shader.height110 intValue]/ratio;
    CGFloat y = [shader.ipadRows intValue]/ratio - h;
    CGFloat w = [shader.length109 intValue]/ratio;
    self.finalshader.frame = CGRectMake(x, y, w, h);
    
    [self startPrepareBeatsTimer];
}


#pragma mark - 练习模式-播放/暂停
- (void)practicePlayAction
{
    if (self.playManager.isStartBarFistBeats && self.playManager.prepareBeats)
    {// 开始小节有预备拍
        
        /*
        NSInteger count = 4;
        // 1.有几个拍要从数据源中获取; 2.需要考虑多个预备拍; 3.tempo要从数据源中取
        [WZBCountDownButton playWithNumber:count success:^(WZBCountDownButton *button) {
            [self startBeatsTimer];
        }];
         */
        
        [self playPrepareBeats:[self.playManager getPrepareBeatsArray] prepareBeatsCount:self.playManager.prepareBeats];
        
    }
    else
    {// 播放
        [self startBeatsTimer];
    }
}

- (void)practicePauseAction
{
//    [timer invalidate];
//    [circletimer invalidate];
    [_beatsTimer invalidate];
}


- (void)startBeatsTimer
{
    if ([_beatsTimer isValid])
    {
        [_beatsTimer invalidate];
        _beatsTimer = nil;
    }
    
    NSTimeInterval duration = [self calculateDuration];
    _beatsTimer =  [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(beatsTimerAction:) userInfo:nil repeats:NO];
}

- (void)beatsTimerAction:(NSTimer *)sender
{
    DSDShaderModel *currentShaderModel = [self.playManager currentShaderModel:self.shadowArray];
    if (currentShaderModel.isLastBeatsInCurrentBar)
    {// 在当前小节最后一个拍
        
        // 同步进行以下两个流程
        // 流程: 判断翻页
        DSDShaderModel *currentShaderModel = [self.playManager currentShaderModel:self.shadowArray];
        [self skipPageIfNeeded:[currentShaderModel.barNo40 integerValue]];
        
        // 流程: 节拍器跳动
        if (self.playManager.repeatPractice)
        {// 重复练习
            BOOL isPracticeLastBar = (self.playManager.repeatEndBarIndex == [currentShaderModel.barNo40 integerValue])? YES : NO;
            if (isPracticeLastBar)
            {// 是最后一节
                //节拍器跳转到开始小节
                for (NSInteger i =0; i < self.shadowArray.count; i++)
                {
                    NSDictionary *dict = self.shadowArray[i];
                    DSDShaderModel *model = [DSDShaderModel yy_modelWithJSON:dict];
                    if ([model.barNo40 isEqualToString:self.start_TF.text])
                    {
                        self.playManager.shaderCurrentIndex = i;
                        break;
                    }
                }
                
                [self moveBeatsShader];
                [self startBeatsTimer];
            }
            else
            {
                self.playManager.shaderCurrentIndex++;
                [self moveBeatsShader];
                [self startBeatsTimer];
            }
        }
        else
        {            
            if (self.playManager.shaderCurrentIndex == self.shadowArray.count - 1)
            {
                self.playManager.shaderCurrentIndex = 0;
                [self moveBeatsShader];
                [self startBeatsTimer];
            }
            else
            {
                self.playManager.shaderCurrentIndex++;
                [self moveBeatsShader];
                [self startBeatsTimer];
            }
        }

    }
    else
    {
        self.playManager.shaderCurrentIndex++;
        [self moveBeatsShader];
        [self startBeatsTimer];
    }
}

- (void)moveBeatsShader
{
    NSInteger shaderIndex = self.playManager.shaderCurrentIndex;
    CGFloat x = [[[self.shadowArray objectAtIndex:shaderIndex] objectForKey:@"ipad_col(107)"] intValue]/ratio;
    CGFloat y = [[[self.shadowArray objectAtIndex:shaderIndex] objectForKey:@"ipad_rows"] intValue]/ratio;
    CGFloat h = [[[self.shadowArray objectAtIndex:shaderIndex] objectForKey:@"height(110)"] intValue]/ratio;
    CGFloat w = [[[self.shadowArray objectAtIndex:shaderIndex] objectForKey:@"length(109)"] intValue]/ratio;
    self.finalshader.frame = CGRectMake(x, y, w, h);
    
    
    NSLog(@"------%@",@(x));
}

// 播放预备拍
- (void)playPrepareBeats:(NSArray<DSDShaderModel *> *)prepareBeatsArray prepareBeatsCount:(NSInteger)count
{
    if (count < 1 || prepareBeatsArray.count < 1)
    {
        NSLog(@"没有预备拍可以播放");
        return;
    }
    
    // 播放预备拍时候将shader往上移动
    DSDShaderModel *startShader = prepareBeatsArray.firstObject;
    CGFloat x = [startShader.ipadCol107 intValue]/ratio;
    CGFloat h = [startShader.height110 intValue]/ratio;
    CGFloat y = [startShader.ipadRows intValue]/ratio - h;
    CGFloat w = [startShader.length109 intValue]/ratio;
    self.finalshader.frame = CGRectMake(x, y, w, h);
    
    // 初始化
    self.playManager.prepareShaderIndex = 0;
    self.playManager.prepareBeatsPlayCount = 0;
    
    // 开始预备拍定时器
    [self startPrepareBeatsTimer];
}

- (void)skipPageIfNeeded:(NSInteger)barNo
{
    DSDDisplayModel *displayModel = [self.playManager displayModelWithBar:barNo];
    NSCParameterAssert(displayModel);
    BOOL isLastBeatsInCurrentPage = displayModel.isLastBarInCurrentPage;
    if (!isLastBeatsInCurrentPage)
    {//不用跳页
        return;
    }
    
    if (self.playManager.repeatPractice)
    {
         DSDShaderModel *currentShaderModel = [self.playManager currentShaderModel:self.shadowArray];
        
        BOOL isPracticeLastBar = (self.playManager.repeatEndBarIndex == [currentShaderModel.barNo40 integerValue])? YES : NO;

        if (isPracticeLastBar)
        {// 跳转循环的第一节
            
            NSInteger index = self.playManager.repeatStartBarIndex;
            DSDDisplayModel *startModel = [self.playManager displayModelWithBar:index];
            if (![startModel.barNo40 isEqualToString:displayModel.barNo40])
            {
                NSInteger offset = [startModel.ipadCol107 integerValue] - 80;
                [self.scrollView setContentOffset:CGPointMake(offset/ratio,0) animated:YES];
            }
            
        }
        else
        {// 跳转循环内的下一节
            DSDDisplayModel *nextModel = [self.playManager displayModelWithBar:barNo+1];
            NSInteger offset = [nextModel.ipadCol107 integerValue] - 80;
            [self.scrollView setContentOffset:CGPointMake(offset/ratio,0) animated:YES];
        }
    }
    else
    {
        DSDDisplayModel *lastModel = self.playManager.displayArray.lastObject;
        BOOL isLastBar = [lastModel.barNo40 integerValue] == barNo;
        if (isLastBar)
        {
            //跳转回第一节
            NSInteger offset = 0;
            [self.scrollView setContentOffset:CGPointMake(offset/ratio,0) animated:YES];
        }
        else
        {
            DSDDisplayModel *nextModel = [self.playManager displayModelWithBar:barNo+1];
            NSInteger offset = [nextModel.ipadCol107 integerValue] - 80;
            [self.scrollView setContentOffset:CGPointMake(offset/ratio,0) animated:YES];
        }
    }
}

#pragma mark - 演奏模式-播放/暂停
- (void)startScrollViewScroll
{
    CGFloat fullDuration = [self caculateFullDuration];
    NSInteger canvasLength = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    NSAssert(fullDuration > 0, @"乐谱总长度不能小于0");
    NSAssert(canvasLength > 0, @"乐谱总长度不能小于0");
    NSLog(@"🚀开始演奏模式：总时长:%@ 乐谱总长度:%@",@(fullDuration),@(canvasLength));
    
    [UIScrollView beginAnimations:@"scrollAnimation" context:nil];
    [UIScrollView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIScrollView setAnimationDuration:fullDuration];
    [self.scrollView setContentOffset:CGPointMake(canvasLength, 0)];
    [UIScrollView commitAnimations];
    
    //==================HJR test
    self.debugLenghtLabel.text = [NSString stringWithFormat:@"%@",@(canvasLength*ratio)];
    self.debugTimeLabel.text = [NSString stringWithFormat:@"%.f秒",fullDuration];
}

- (void)pauseScrollViewScroll
{
    CALayer *layer = self.scrollView.layer;
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
//     [self.scrollView.layer removeAllAnimations];
}

- (void)resumeScrollViewScroll
{
    CALayer *layer = self.scrollView.layer;
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

#pragma mark - drawData
-(void) drawData:(NSDictionary *)dict
{
    NSInteger channel = [[dict objectForKey:@"channel"] integerValue];
    
    
    //=====================HJR test
//    if(channel == 135 ||  channel == 235)
//    {
//        [self drawOtherChanneles:dict];
//    }
//    return;
    //===================
    
    
    //Ignore Channel 0 with no reason
    if(channel == 0 )
    {
        return;
    }
    
    //Ignore Channel 36 in Color Mode
    if(mode == COLORMODE && channel == 36)
    {
        return;
    }
    
    //Ignore Channel 39 in Color Mode
    if(mode == COLORMODE && channel == 39)
    {
        return;
    }
    
    //Ignore Channel 52 in Color Mode
    if(mode == COLORMODE && channel == 52)
    {
        return;
    }
    
    //Ignore Channel 57 in Color Mode
    if(mode == BWMODE && channel == 57)
    {
        return;
    }
    
    if(channel == 37)
    {
        [self drawChannel_37:dict];
    }
    
    //Sign
    if(channel == 29 )
    {
        [self drawChannel_29:dict];
    }
    
    //Adjustment Item
    if(channel == 41 )
    {
        [self drawChannel_41:dict];
    }
    //KeyView Item
    else if(channel == 30 )
    {
        [self drawChannel_30:dict];
    }
    //#,b
    else if(channel == 36 )
    {
        [self drawChannel_36:dict];
    }
    //Wording
    else if((channel > 30 && channel < 38 && channel != 36) || channel == 50)
    {
        [self drawChannel_31To38_50:dict];
    }
    //DottedLine
    else if(channel == 14)
    {
        [self drawChannel_14:dict];
    }
    //Triangle
    else if(channel == 58 )
    {
        [self drawChannel_58:dict];
    }
    //  指法
    else if((channel >= 100 && channel <=199) || (channel >= 200 && channel <=299))
    {        
        if ([[dict objectForKey:@"Content"] length])
        {
             [self drawChannelWithWord:dict];
        }
        else
        {
            [self drawOtherChanneles:dict];
        }
    }
    //  表情符号
    else if(channel == 80)
    {
        [self drawChannel_80:dict];
    }
    else
    {
        [self drawOtherChanneles:dict];
    }
}

- (void)drawChannel_14:(NSDictionary *)dict
{
    DottedLine * view = [[DottedLine alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, [[dict objectForKey:@"length(109)"] floatValue]/ratio, [[dict objectForKey:@"height(110)"] floatValue]/ratio)];
    view.backgroundColor = [UIColor clearColor];
    view.layer.zPosition = [[dict objectForKey:@"Z-level"] intValue];
    view.tag = DSDhalfBeatLineTag;
    [self.scrollView addSubview:view];
}

- (void)drawChannel_29:(NSDictionary *)dict
{
    NSString * imgName;
    if([[dict objectForKey:@"Content"] isEqualToString:@"G-clef"])
    {
        imgName = @"g_clef.png";
    }
    else
    {
        imgName = @"f_clef.png";
    }
    
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, 35, 90)];
    img.image = [UIImage imageNamed:imgName];
    
    
    [self.keyView addSubview:img];
}

- (void)drawChannel_30:(NSDictionary *)dict
{
    UILabel * label = nil;
    label = [[UILabel alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, 75, 12)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"Arial" size:FONT_SIZE*2.7/(ratio/2)];
    label.text = [dict objectForKey:@"Content"];
    label.backgroundColor = [UIColor clearColor];
    [self.keyView addSubview:label];
    
    [self.view sendSubviewToBack:self.scrollView];
}

- (void)drawChannel_31To38_50:(NSDictionary *)dict
{
    if([[dict objectForKey:@"Content"] isEqualToString:@"n"])return;
    
    UILabel * label = nil;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, [[dict objectForKey:@"length(109)"] floatValue]/(2.5), 12/(ratio/2))];
    
    NSString *platform = [self platform];
    
    if ([platform isEqualToString:@"iPad6,8"] || [platform isEqualToString:@"iPad6,7"]) {
        
        label.frame = CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, (int)([[dict objectForKey:@"length(109)"] floatValue]/2.5), (int)(12/(ratio/2)));
        
    }
    
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"Arial" size:FONT_SIZE*[[dict objectForKey:@"flip_view"] floatValue]/(ratio/2)];
    label.text = [dict objectForKey:@"Content"];
    
    label.backgroundColor = [UIColor colorWithRed:[[dict objectForKey:@"Bar No(40)"] floatValue]/255.0 green:[[dict objectForKey:@"Beats per Bar(40)"] floatValue]/255.0 blue:[[dict objectForKey:@"tempo (40)"] floatValue]/255.0 alpha:1];
    
    
    label.layer.zPosition = [[dict objectForKey:@"Z-level"] intValue];
    [self.scrollView addSubview:label];
}

- (void)drawChannel_36:(NSDictionary *)dict
{
    UILabel * label = nil;
    label = [[UILabel alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, [[dict objectForKey:@"length(109)"] floatValue]/ratio,[[dict objectForKey:@"height(110)"] floatValue]/ratio)];
    
    NSString *platform = [self platform];
    
    if ([platform isEqualToString:@"iPad6,8"] || [platform isEqualToString:@"iPad6,7"]) {
        
        label.frame = CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, (int)([[dict objectForKey:@"length(109)"] floatValue]/2.7),(int)([[dict objectForKey:@"height(110)"] floatValue]/2.7));
        
    }
    
    label.textColor = [UIColor colorWithRed:[[dict objectForKey:@"fingering/chord"] floatValue]/255.0 green:[[dict objectForKey:@"lyrics"] floatValue]/255.0 blue:[[dict objectForKey:@"ipad_color(105)"] floatValue]/255.0 alpha:1];
    label.font = [UIFont fontWithName:@"Arial-Italic" size:FONT_SIZE*[[dict objectForKey:@"flip_view"] floatValue]/(ratio/2)];
    label.font = [label.font fontWithSize:FONT_SIZE*[[dict objectForKey:@"flip_view"] floatValue]/(ratio/2)];
    label.text = [dict objectForKey:@"Content"];
    
    label.backgroundColor = [UIColor colorWithRed:[[dict objectForKey:@"Bar No(40)"] floatValue]/255.0 green:[[dict objectForKey:@"Beats per Bar(40)"] floatValue]/255.0 blue:[[dict objectForKey:@"tempo (40)"] floatValue]/255.0 alpha:1];
    
    label.layer.zPosition = [[dict objectForKey:@"Z-level"] intValue];
    
    
    [self.scrollView addSubview:label];
}

- (void)drawChannel_37:(NSDictionary *)dict
{
    if([dict[@"Content"] isEqualToString:@"n"])
    {
        NShape * n = [[NShape alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, [[dict objectForKey:@"length(109)"] floatValue]/ratio, [[dict objectForKey:@"height(110)"] floatValue]/ratio)];
        
        [self.scrollView addSubview:n];
    }
}

- (void)drawChannel_41:(NSDictionary *)dict
{
    UIButton * showBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    showBtn.frame = CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"rise_fall"] floatValue]/ratio, [[dict objectForKey:@"length(109)"] floatValue]/ratio, [[dict objectForKey:@"height(110)"] floatValue]*3);
    showBtn.tag = ([[dict objectForKey:@"Bar No(40)"] intValue]) * [[dict objectForKey:@"flip_view"] intValue] + [[dict objectForKey:@"Beats per Bar(40)"] intValue];
    [showBtn addTarget:self action:@selector(showControl:) forControlEvents:UIControlEventTouchDown];
    
    UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] init];
    [gr addTarget:self action:@selector(userLongPressed:)];
    [showBtn addGestureRecognizer:gr];
    
    Tempo * label = nil;
    label = [[Tempo alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, 24, 12)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"Arial" size:FONT_SIZE*2.7/(ratio/2)];
    label.tag = TEMPO_TAG + ([[dict objectForKey:@"Bar No(40)"] intValue]) * [[dict objectForKey:@"flip_view"] intValue] + [[dict objectForKey:@"Beats per Bar(40)"] intValue];
    
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:fileName] != nil){
        NSDictionary * tmp_dict = [self.shadowArray objectAtIndex:label.tag - TEMPO_TAG - 1];
        label.text = [tmp_dict objectForKey:@"tempo (40)"];
        
    }
    else{
        label.text = [dict objectForKey:@"tempo (40)"];
        
    }
    
    label.group = [[dict objectForKey:@"Bar No(40)"] intValue];
    label.index =[[dict objectForKey:@"Beats per Bar(40)"] intValue];
    
    NSLog(@"Before Bar Number is %d", label.group);
    
    label.hidden = YES;
    
    UIButton * upBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    upBtn.frame = CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"rise_fall"] floatValue]/ratio, 25, 25);
    upBtn.tag = UP_TAG + ([[dict objectForKey:@"Bar No(40)"] intValue]) * [[dict objectForKey:@"flip_view"] intValue] + [[dict objectForKey:@"Beats per Bar(40)"] intValue];
    upBtn.backgroundColor = [UIColor clearColor];
    [upBtn addTarget:self action:@selector(addTempo:) forControlEvents:UIControlEventTouchUpInside];
    [upBtn setTitle:@"+" forState:UIControlStateNormal];
    upBtn.hidden = YES;
    
    UIButton * downBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    downBtn.frame = CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"sharp_flat"] floatValue]/ratio, 25, 25);
    downBtn.tag = DOWN_TAG + ([[dict objectForKey:@"Bar No(40)"] intValue]) * [[dict objectForKey:@"flip_view"] intValue] + [[dict objectForKey:@"Beats per Bar(40)"] intValue];
    [downBtn addTarget:self action:@selector(subtractTempo:) forControlEvents:UIControlEventTouchDown];
    [downBtn setTitle:@"-" forState:UIControlStateNormal];
    downBtn.hidden = YES;
    
    
    [upBtnControls addObject:upBtn];
    [downBtnControls addObject:downBtn];
    
    
    if([groupControls count] == 0 || ((Tempo*)[groupControls lastObject]).group == label.group){
        [groupControls addObject:label];
    }
    else{
        
        [tempLabelControls addObject:groupControls];
        groupControls = [[NSMutableArray alloc] init];
        [groupControls addObject:label];
        NSLog(@"Tempo Count : %zi", tempLabelControls.count);
    }
    
    if([dict[@"flip_view"] intValue] == groupControls.count){
        [tempLabelControls addObject:groupControls];
    }
    
    //[tempLabelControls addObject:label];
    
    showBtn.layer.zPosition = 9999;
    label.layer.zPosition = 9999;
    upBtn.layer.zPosition = 9999;
    downBtn.layer.zPosition = 9999;
    
    
    [self.scrollView addSubview:showBtn];
    [self.scrollView addSubview:label];
    [self.scrollView addSubview:upBtn];
    [self.scrollView addSubview:downBtn];
    
    [tempoArray addObject:label];
}

- (void)drawChannel_58:(NSDictionary *)dict
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, [[dict objectForKey:@"length(109)"] floatValue]/ratio, [[dict objectForKey:@"height(110)"] floatValue]/ratio)];
    view.backgroundColor = [UIColor colorWithRed:[[dict objectForKey:@"Bar No(40)"] floatValue]/255.0 green:[[dict objectForKey:@"Beats per Bar(40)"] floatValue]/255.0 blue:[[dict objectForKey:@"tempo (40)"] floatValue]/255.0 alpha:1];
    
    if(mode == BWMODE )
    {
        view.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:1];
    }
    
    TriangleView * triangle;
    
    if([[dict objectForKey:@"Content"] isEqualToString:@"U"])
    {
        triangle = [[TriangleView alloc] initWithFrame:CGRectMake(2, -12, 320, 320)];
        triangle.backgroundColor = [UIColor clearColor];
        
        if(mode == BWMODE )
        {
            [triangle setColor:[UIColor colorWithRed:150.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:1]];
        }
        else
        {
            [triangle setColor:[UIColor colorWithRed:[[dict objectForKey:@"Bar No(40)"] floatValue]/255.0 green:[[dict objectForKey:@"Beats per Bar(40)"] floatValue]/255.0 blue:[[dict objectForKey:@"tempo (40)"] floatValue]/255.0 alpha:1]];
        }
        
        
        [triangle setType:@"U"];
        [view addSubview:triangle];
    }
    
    if([[dict objectForKey:@"Content"] isEqualToString:@"D"])
    {
        triangle = [[TriangleView alloc] initWithFrame:CGRectMake(2, -12, 320, 320)];
        triangle.backgroundColor = [UIColor clearColor];
        if(mode == BWMODE )
        {
            [triangle setColor:[UIColor colorWithRed:150.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:1]];
        }
        else
        {
            [triangle setColor:[UIColor colorWithRed:[[dict objectForKey:@"Bar No(40)"] floatValue]/255.0 green:[[dict objectForKey:@"Beats per Bar(40)"] floatValue]/255.0 blue:[[dict objectForKey:@"tempo (40)"] floatValue]/255.0 alpha:1]];
        }
        
        [triangle setType:@"D"];
        [view addSubview:triangle];
    }
    
    NSString *platform = [self platform];
    
    [triangle setSize:NO];
    
    if ([platform isEqualToString:@"iPad6,8"] || [platform isEqualToString:@"iPad6,7"])
    {
        triangle.frame = CGRectMake(2, -9, 320, 320);
        [triangle setSize:YES];
    }
    
    view.layer.zPosition = [[dict objectForKey:@"Z-level"] intValue];
    [self.scrollView addSubview:view];
}

// 表情符号
- (void)drawChannel_80:(NSDictionary *)dict
{
    NSString *content = dict[@"Content"];
    if (!content)
    {
        NSCParameterAssert(NO);
        return;
    }
    
    if (!_expressionDictionary)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"expression" ofType:@"csv"];
        NSArray *tempArray = [CSVParser parseCSVIntoArrayOfDictionariesFromFile:path
                                                 withSeparatedCharacterString:@","
                                                         quoteCharacterString:@"\""];
        NSMutableDictionary *muDict = [NSMutableDictionary new];
        for (NSDictionary *dict in tempArray)
        {
            if (dict[@"image file name"] && dict[@"Index"])
            {
                [muDict setObject:dict[@"image file name"] forKey:dict[@"Index"]];
            }
        }
        _expressionDictionary = [muDict copy];
    }
    
    NSString * imgName = _expressionDictionary[content];
    UIImage *image = [UIImage imageNamed:imgName];
    if (!image) {
        NSLog(@"⚠️⚠️找不到 %@ 这个表情符号图片",imgName);
    }
    
    CGFloat scale = 8;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, image.size.width/scale, image.size.height/scale)];
    
    imageView.image = image;
    imageView.tag = DSDExpressionViewsTag;
    
    [self.scrollView addSubview:imageView];
}

// 指法 (135、136、137、235、236、237)
- (void)drawChannelWithWord:(NSDictionary *)dict
{
    UILabel *label = [[UILabel alloc] init];
    label.tag = DSDFingeringViewsTag;
    [self.scrollView addSubview:label];
    
    label.backgroundColor = [UIColor colorWithRed:[[dict objectForKey:@"Bar No(40)"] floatValue]/255.0 green:[[dict objectForKey:@"Beats per Bar(40)"] floatValue]/255.0 blue:[[dict objectForKey:@"tempo (40)"] floatValue]/255.0 alpha:1];
    label.layer.zPosition = [[dict objectForKey:@"Z-level"] intValue];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    NSString *fontStr = [dict objectForKey:@"flip_view"];
    CGFloat fontSize = [fontStr floatValue];
    if(fontSize < 11.0)
    {
        fontSize = 11.0;
    }
    
    // 根据字体大小调整label的frame
    CGFloat labelWidth = [[dict objectForKey:@"length(109)"] floatValue]/ratio;
    if(labelWidth < fontSize)
    {
        labelWidth = fontSize;
    }
    
    CGFloat labelHeight = [[dict objectForKey:@"height(110)"] floatValue]/ratio;
    if(labelHeight < fontSize)
    {
        labelHeight = fontSize;
    }
    
    label.frame = CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, labelWidth, labelHeight);
    
    label.font = [UIFont fontWithName:@"Georgia" size:fontSize];
    
    label.textColor = [UIColor colorWithRed:[[dict objectForKey:@"fingering/chord"] floatValue]/255.0 green:[[dict objectForKey:@"lyrics"] floatValue]/255.0 blue:[[dict objectForKey:@"ipad_color(105)"] floatValue]/255.0 alpha:1];
    
    if (![[NSString stringWithFormat:@"%@",dict[@"Content"]] isEqualToString:@"0"]) {
        label.text = [NSString stringWithFormat:@"%@",dict[@"Content"]];
    }
    else
    {
        label.text = nil;
    }
}

- (void)drawOtherChanneles:(NSDictionary *)dict
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake([[dict objectForKey:@"ipad_col(107)"] floatValue]/ratio, [[dict objectForKey:@"ipad_rows"] floatValue]/ratio, [[dict objectForKey:@"length(109)"] floatValue]/ratio, [[dict objectForKey:@"height(110)"] floatValue]/ratio)];
    view.backgroundColor = [UIColor colorWithRed:[[dict objectForKey:@"Bar No(40)"] floatValue]/255.0 green:[[dict objectForKey:@"Beats per Bar(40)"] floatValue]/255.0 blue:[[dict objectForKey:@"tempo (40)"] floatValue]/255.0 alpha:1];
    
    
    
    if([[dict objectForKey:@"channel"] intValue] == 20){
        view.backgroundColor = [UIColor redColor];
    }
    
    if([[dict objectForKey:@"flip_view"] intValue] > 0){
        CGFloat borderWidth = [[dict objectForKey:@"flip_view"] floatValue];
        view.layer.borderColor = [UIColor blackColor].CGColor;
        view.layer.borderWidth = borderWidth;
    }
    
    
    
    UILabel * label = nil;
    
    
    
    //Apply Gray color in channel 1 under BW Mode
    if(mode == BWMODE && [dict[@"channel"] intValue] == 1){
        view.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:1];
    }
    
    UIImageView * img = nil;
    
    
    if([[dict objectForKey:@"channel"] isEqualToString:@"105"] || [[dict objectForKey:@"channel"] isEqualToString:@"110"])
        [view addRoundedCorners:UIRectCornerTopRight withRadii:CGSizeMake(15, 15)];
    
    if([[dict objectForKey:@"channel"] isEqualToString:@"106"]){
        [view addRoundedCorners:(UIRectCornerTopRight|UIRectCornerBottomRight) withRadii:CGSizeMake(15, 15)];
    }
    
    
    view.layer.zPosition = [[dict objectForKey:@"Z-level"] intValue];
    
    if(([[dict objectForKey:@"channel"] intValue] == 53 || [[dict objectForKey:@"channel"] intValue] == 54) && mode == BWMODE)
    {
        view.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:1];
    }
    
    [self.scrollView addSubview:view];
    
    
    NSInteger channel = [[dict objectForKey:@"channel"] integerValue];
    // channel 100-199 是右手
    if ((channel >= 100) && (channel <= 199))
    {
        view.tag = DSDRightHandViewsTag;
    }
    // channel 200-299 是左手
    else if ((channel >= 200) && (channel <= 299))
    {
        view.tag = DSDLeftHandViewsTag;
    }
    
    if([[dict objectForKey:@"channel"] intValue] == 6 || [[dict objectForKey:@"channel"] intValue] == 7)
    {
        [self.scrollView sendSubviewToBack:view];
        return;
    }
}

#pragma mark -
-(void)skipToPage:(int)_page
{
    int _distance = 0;
    int _index = 0;
    
    if(_page > 0)
    {
        for (NSDictionary * _d in displayArray)
        {
            _distance += [_d[@"length(109)"] intValue];
            _index += [_d[@"Beats per Bar(40)"] intValue];
            
            if([_d[@"Bar No(40)"] intValue] + 1 == _page)
            {
                break;
            }
        }
        
        page = _page;
    }
    else
    {
        page = 1;
        //!!!Page cannot be Zero!!!
    }

    [self.scrollView setContentOffset:CGPointMake(_distance/ratio,0) animated:NO];
    movedLength = 0;

    index = _index;

//    self.finalshader.frame = CGRectMake(self.rightShader.frame.origin.x - [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/ratio, 182/(ratio/2) + 12/(ratio/2), [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/ratio,12/(ratio/2));
}

-(void)showCircularView
{
    
    /*Determine to show or not by tempo value*/
    if([self.shadowArray[index][@"tempo (40)"] intValue] < minimunTempo)
    {
        CGFloat barWidth = [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] floatValue]/ratio;
        CGFloat spaceForEach = barWidth/4;

        /*Arrange position of circular views*/
        int _i = 0;
        for (UIView * c in circlesArray)
        {
            //[c setHidden:NO];
            c.frame = CGRectMake(self.finalshader.frame.origin.x + spaceForEach*_i + (spaceForEach - 12)/ratio, 182/(ratio/2) + 12/(ratio/2), 12, 12);
            
            _i++;
        }
        
        [(UIView*)circlesArray[0] setHidden:NO];
        
        [self.finalshader setHidden:YES];
        
    }
    else
    {
        for (UIView * c in circlesArray)
        {
            [c setHidden:YES];
        }
        
        [self.finalshader setHidden:NO];
    }
    
}

-(void)circleLife
{
    for (UIView* view in circlesArray)
    {
        [view setHidden:YES];
    }
    
    if([self.shadowArray[index][@"tempo (40)"] intValue] >= minimunTempo)
    {
        return;
    }

    circleIndex = (circleIndex < 3)?circleIndex+1:0;
    if(circleIndex != 0)
    {
        UIView * nextView = circlesArray[circleIndex];
        [nextView setHidden:NO];
    }
    
    [self startCircleTimer:[self calculateDuration]/4];
}

-(void) initGlobalFactor
{
    global_factor = 0;
}

- (void) rearrangeTempoControls
{
    for (NSMutableArray * group in tempLabelControls)
    {
        BOOL all_same_value = YES;
        int value = [((Tempo*) [group firstObject]).text intValue];
        
        for (Tempo * label in group)
        {
            if(value != [label.text intValue])
            {
                all_same_value = NO;
            }
            
            NSLog(@"Bar Number is %d", label.group);
            [label setHidden:YES];
        }

        if(all_same_value)
        {
            [((Tempo*) [group firstObject]) setHidden:NO];
        }
        else
        {
            for (Tempo * label in group)
            {
                [label setHidden:NO];
            }
        }
    }
}

- (void)userLongPressed:(UILongPressGestureRecognizer*)sender
{
    int tag = (int)sender.view.tag;
    NSDictionary * dict = [self.shadowArray objectAtIndex:tag-1];
    
    int _index = tag % [[dict objectForKey:@"flip_view"] intValue];
    
    int target = 0;
    
    if(_index == 0)
    {
        target = tag - ([[dict objectForKey:@"flip_view"] intValue] - 1);
    }
    else
    {
        target = tag - (_index - 1);
    }
    
    for (int i = target; i < target + [[dict objectForKey:@"flip_view"] intValue]; i++)
    {
        UILabel * tempo = (UILabel*)[self.view viewWithTag:i + TEMPO_TAG];
        tempo.hidden = NO;
        
        UIButton * upBtn = (UIButton*)[self.view viewWithTag:i + UP_TAG];
        upBtn.hidden = NO;
        
        UIButton * downBtn = (UIButton*)[self.view viewWithTag:i + DOWN_TAG];
        downBtn.hidden = NO;
    }
    
}

-(void) showControl:(UIButton*)sender
{
    int tag = (int)sender.tag;
    Tempo * tempo = (Tempo*)[self.view viewWithTag:tag + TEMPO_TAG];
    tempo.hidden = NO;
    
    UIButton * upBtn = (UIButton*)[self.view viewWithTag:tag + UP_TAG];
    upBtn.hidden = NO;
    
    UIButton * downBtn = (UIButton*)[self.view viewWithTag:tag + DOWN_TAG];
    downBtn.hidden = NO;
    
}

-(void) addTempo:(UIButton*)sender
{
    int tag = (int)sender.tag - UP_TAG;
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        NSMutableDictionary * dict = [[self.shadowArray objectAtIndex:tag-1] mutableCopy];
        
        Tempo * label = (Tempo *)[self.scrollView viewWithTag:tag + TEMPO_TAG];
        
        [label setText:[NSString stringWithFormat:@"%d", ([label.text intValue]+1)]];
        

        
        [dict setObject:[NSString stringWithFormat:@"%d", [label.text intValue]] forKey:@"tempo (40)"];
        
        NSMutableArray * sArray = [self.shadowArray mutableCopy];
        
        [sArray replaceObjectAtIndex:tag-1 withObject:dict];
        
        self.shadowArray = [sArray mutableCopy];
        
        NSLog(@"%d", tag-1);
    });
}

-(void) subtractTempo:(UIButton*)sender
{
    int tag = (int)sender.tag - DOWN_TAG;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSMutableDictionary * dict = [[self.shadowArray objectAtIndex:tag-1] mutableCopy];
        
        Tempo * label = (Tempo *)[self.scrollView viewWithTag:tag + TEMPO_TAG];
        
        [label setText:[NSString stringWithFormat:@"%d", ([label.text intValue]-1)]];
        
        [dict setObject:[NSString stringWithFormat:@"%d", [label.text intValue]] forKey:@"tempo (40)"];
        
        NSMutableArray * sArray = [self.shadowArray mutableCopy];
        
        [sArray replaceObjectAtIndex:tag-1 withObject:dict];
        
        self.shadowArray = [sArray mutableCopy];
        [self.playManager updateShadowArray:self.shadowArray];
        
        NSLog(@"%d", tag-1);
    });
}

-(void) tempoValue
{
    int _i = 0;
    for (Tempo * label in tempoArray)
    {
        if(([label.text intValue]+global_factor) > 0)
        {
            [label setText:[NSString stringWithFormat:@"%d", [label.text intValue]+global_factor]];
            
            NSMutableDictionary * dict = [[self.shadowArray objectAtIndex:_i] mutableCopy];
            
            [dict setObject:[NSString stringWithFormat:@"%d", [label.text intValue]] forKey:@"tempo (40)"];
            
            NSMutableArray * sArray = [self.shadowArray mutableCopy];
            
            [sArray replaceObjectAtIndex:_i withObject:dict];
            
            self.shadowArray = [sArray mutableCopy];
            [self.playManager updateShadowArray:self.shadowArray];
        }
        
        _i++;
    }
}

-(void)updateDisplayArray
{
    [[NSUserDefaults standardUserDefaults] setObject:displayArray forKey:[NSString stringWithFormat:@"%@displayArray", fileName]];
}

-(float)calculateDuration
{
    CGFloat duration = 60/[[[self.shadowArray objectAtIndex:index] objectForKey:@"tempo (40)"] floatValue];
    return duration;
}

-(void) moveShader
{
    //by:HJR shadowArray数据结构
    /*
             {
             "Bar No(40)" = 16;
             "Beats per Bar(40)" = 3;
             Content = "";
             "Z-level" = 2;
             channel = 41;
             "fingering/chord" = "";
             "flip_view" = 3;
             "height(110)" = 40;
             "ipad_col(107)" = 6166;
             "ipad_color(105)" = "";
             "ipad_rows" = 263;
             "length(109)" = 120;
             lyrics = "";
             "rise_fall" = 170;
             "sharp_flat" = 340;
             "tempo (40)" = 70;
             }
     */
    
//    CGFloat  ipad_col = [[[self.shadowArray objectAtIndex:index] objectForKey:@"ipad_col(107)"] intValue];
//    CGFloat x = self.rightShader.frame.origin.x - ipad_col/ratio;
//    CGFloat y = 182/(ratio/2) + 12/(ratio/2);
//    CGFloat w = [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/ratio;
//    CGFloat h = 12/(ratio/2);
    
    CGFloat x = [[[self.shadowArray objectAtIndex:index] objectForKey:@"ipad_col(107)"] intValue]/ratio;
    CGFloat y = [[[self.shadowArray objectAtIndex:index] objectForKey:@"ipad_rows"] intValue]/ratio;
    CGFloat h = [[[self.shadowArray objectAtIndex:index] objectForKey:@"height(110)"] intValue]/ratio;
    CGFloat w = [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/ratio;
    
    self.finalshader.frame = CGRectMake(x, y, w, h);
    [self showCircularView];
    [self startTimer:[self calculateDuration]];
}

-(void)resetCircle
{
    for (UIView* view in circlesArray)
    {
        [view setHidden:YES];
    }
    
    circleIndex = 0;
    
    [circletimer invalidate];
}

-(void)startCircleTimer:(float)time
{
    if([circletimer isValid])
    {
        [circletimer invalidate];
    }
    
    circletimer =  [NSTimer scheduledTimerWithTimeInterval: time/timerFactor target:self selector:@selector(circleLife) userInfo:nil repeats:NO];
}

-(void)startTimer:(float)time
{
    if([timer isValid])
    {
        [timer invalidate];
    }

    timer =  [NSTimer scheduledTimerWithTimeInterval: time/timerFactor target:self selector:@selector(next:) userInfo:nil repeats:NO];
}

- (IBAction)next:(id)sender
{
    [self startTimer:[self calculateDuration]];
    [self resetCircle];
    [self startCircleTimer:[self calculateDuration]/4];
    [self nextSection];
}

- (IBAction)previous:(id)sender
{
    [self startTimer:[self calculateDuration]];
    [self previousSection];
}

- (IBAction)changeOpacity:(UISlider*)sender
{
}

-(int) getSectionNumber
{
    for(int i=1;i<[self.dict count];i++)
    {
        if(page-1 == [[[self.dict objectForKey:[NSString stringWithFormat:@"%d", i]] objectForKey:@"bars"] intValue])
        {
            return [[[self.dict objectForKey:[NSString stringWithFormat:@"%d", i]] objectForKey:@"time_sig_n"] intValue];
        }
    }
    
    return 0;
}

-(void) nextSection
{
    if(shaderIndex+1 > [[[displayArray objectAtIndex:page-1] objectForKey:@"Beats per Bar(40)"] intValue])
    {
        shaderIndex = 1;
        if(page == maxPage)
        {
            [self skipToPage:startPage];
            [self moveShader];
            return;
        }
        else
        {
            movedLength += [[[displayArray objectAtIndex:page-1] objectForKey:@"length(109)"] floatValue] /ratio;
            index++;
        }
        page++;
        [self changePage];
    }
    else
    {
        shaderIndex++;
        index++;
    }
    
    [self moveShader];
}

-(void)previousSection
{
    if(sectionNow - 1 > 0)
    {
        sectionNow--;
    }
    else
    {
        if(page - 1 < 1)
            return;
        page--;
        sectionNow = [self getSectionNumber];
        [self changePage];
    }
    [self moveShader];
}

-(void)renewData{
    
    sectionNow = 1;
}

-(void)changePage
{
    //by:hjr 这里换页的算法不对，需修改 2018-12-09
    BOOL needChangePage = NO;
    
    CGFloat nowPosition = 0;// self.leftShader.frame.origin.x + self.leftShader.frame.size.width;
    CGFloat lengthToNextTwoBar = 0.0;
    for(int i=2;i<1;i--)
    {
        lengthToNextTwoBar += [displayArray[page-i][@"length(109)"] floatValue]/2;
    }
    
    CGFloat startingPoint = nowPosition + lengthToNextTwoBar;
    
    CGFloat edge = EDGE;
    
    NSString *platform = [self platform];
    
    if ([platform isEqualToString:@"iPad6,8"] || [platform isEqualToString:@"iPad6,7"])
    {
        edge = self.view.frame.size.width*0.85;
    }
    
    if(page+1 <= displayArray.count)
    {
        if(startingPoint < edge && (startingPoint + [displayArray[page][@"length(109)"] floatValue]/ratio) > edge && ((page - ((startPage == 0)?1:0))) != maxPage)
        {
            needChangePage = YES;
        }
        
        if(needChangePage)
        {
            needChangePage = [self checkBarsInView:page-1];
        }
    }

    if(!needChangePage)
    {
        return;
    }

    self.finalshader.frame = CGRectMake(/*self.rightShader.frame.origin.x - */[[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/2, 182, [[[self.shadowArray objectAtIndex:index] objectForKey:@"length(109)"] intValue]/2, 12);
    
    if(page > startPage)
    {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + movedLength,0) animated:NO];
    }
    else
    {
        [self.scrollView setContentOffset:CGPointMake(0,0) animated:NO];
    }
    
    movedLength = 0;
}

-(BOOL) checkBarsInView:(int) _page
{
    
    CGFloat length = 0.0;
    for(int i=_page;i<maxPage;i++)
    {
        length+= [displayArray[i][@"length(109)"] floatValue]/2;
    }
    
//    if(self.rightShader.frame.origin.x + length <= self.view.bounds.size.width)
//    {
//        return NO;
//    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)captureImageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, theView.opaque, 0.0);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *captureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return captureImage;
}

#pragma mark - half beat line
- (void)showHalfBeatLine
{
    for (UIView *aSubView in self.scrollView.subviews)
    {
        if (aSubView.tag == DSDhalfBeatLineTag && [aSubView isKindOfClass:[DottedLine class]])
        {
            aSubView.hidden = NO;
        }
    }
}

- (void)hideHalfBeatLine
{
    for (UIView *aSubView in self.scrollView.subviews)
    {
        if (aSubView.tag == DSDhalfBeatLineTag && [aSubView isKindOfClass:[DottedLine class]])
        {
            aSubView.hidden = YES;
        }
    }
}

#pragma mark - data parser
// 计算曲谱时长
- (CGFloat)caculateFullDuration
{
    if (self.shadowArray.count < 1)
    {
        return 0;
    }
    
    CGFloat duration = 0;
    for (NSDictionary *dict in self.shadowArray)
    {
        duration += 60/[[dict objectForKey:@"tempo (40)"] floatValue];
    }
    
    return duration;
}

#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}




#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.isPlaying)
    {
        self.isPlaying = NO;
        [self.scrollView.layer removeAllAnimations];
        
    }
    
    NSLog(@"fdahofhdsaofhasfh");
}

#pragma mark - utility
- (NSString *)platform
{
    //================HJR test
    return @"iPad6,8";
    //================HJR test
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

@end
