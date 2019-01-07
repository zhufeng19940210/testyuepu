//
//  ViewController.h
//  DSDDemo
//
//  Created by Leong on 18/1/13.
//  Copyright (c) 2013 Leong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    
    int bar;
    NSMutableArray * dictArray;
    
    NSInteger sectionNow;
    
    NSTimer * timer;
    
    NSInteger page;
    
    NSInteger maxPage;
    float timerFactor;
    
    
    
    //02-07-2013
    NSString * fileName;
    
    int openedTag;
    
    int totalLength;
    
    float movedLength;
    
    NSMutableArray * sheetArray;
    
    int shaderIndex;
    
    NSMutableArray * colorArray;
    
    
    
    NSMutableArray * tempoArray;
    
    int index;
    
    NSMutableArray * upBtnControls;
    NSMutableArray * downBtnControls;
    NSMutableArray * tempLabelControls;
    
    NSMutableArray * groupControls;
    
    int mode;
    
    int global_factor;
    
    NSMutableArray * circlesArray;
    int circleIndex;
    NSTimer * circletimer;
    
    BOOL halfLine;
    
    int minimunTempo;
}

@property(strong, nonatomic) NSMutableDictionary * dict;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *upShader;
@property (strong, nonatomic) IBOutlet UIView *downShader;
@property (strong, nonatomic) IBOutlet UIView *finalshader;
@property (strong, nonatomic) IBOutlet UILabel *percentageLabel;
@property (strong, nonatomic) IBOutlet UIView *panelView;
@property (strong, nonatomic) IBOutlet UITextField *timeLabel2;
@property (strong, nonatomic) IBOutlet UITextField *timeLabel1;
@property (strong, nonatomic) IBOutlet UITextField *timeLabel3;
@property (strong, nonatomic) IBOutlet UITextField *timeLabel4;

// by:HJR from CSV tempo
@property(strong, nonatomic)NSMutableArray * shadowArray;
@property(strong, nonatomic)NSMutableArray * shaderArray;;

@property (strong, nonatomic) IBOutlet UILabel *time1;
@property (strong, nonatomic) IBOutlet UILabel *time2;
@property (strong, nonatomic) IBOutlet UILabel *time3;
@property (strong, nonatomic) IBOutlet UILabel *time4;

@property (strong, nonatomic) IBOutlet UIView *keyView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *repeat_SC;
@property (strong, nonatomic) IBOutlet UITextField *start_TF;
@property (strong, nonatomic) IBOutlet UITextField *end_TF;
//- (IBAction)repeatControlChanged:(UISegmentedControl *)sender;

- (void)setMode:(int)_mode andFile:(NSString*)_name andHalfLine:(BOOL)enabled andTempo:(int)_t;
@property (copy, nonatomic) NSString *fileName;



+ (instancetype)controller;


//- (IBAction)changeOpacity:(UISlider*)sender;


//- (IBAction)increase:(id)sender;
//- (IBAction)decrease:(id)sender;
//- (IBAction)saveChanges:(UIButton *)sender;

//-(void) updateDisplayArray;
//- (IBAction)backtoModeSelection:(id)sender;

/*
 
 【进行中】:
 1. 跳页；
 2. 段落练习：在当前段落中来回循环；
 3. 预备拍；
 4. 回头键：在当前演奏的小节中跳到最前；
 
 【准备做】- 需要CSV文件完善
 1. 指法；
 2. 显示右手；
 3. 显示左手；
 4. 表情记号；
 
 【已完成】
 1. 半拍线；
 2. 还原乐谱；
 

 
 */


@end
