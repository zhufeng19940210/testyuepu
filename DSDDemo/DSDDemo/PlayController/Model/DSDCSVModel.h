//
//  DSDCSVModel.h
//  DSDDemo
//
//  Created by HJR on 2018/12/16.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSDCSVModel : NSObject

//----------- parse from csv
@property (nonatomic, assign) NSInteger content;//index
@property (nonatomic, copy) NSString *fingeringChord;
@property (nonatomic, copy) NSString *barNo40;
@property (nonatomic, copy) NSString *flipView;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, copy) NSString *height110;
@property (nonatomic, copy) NSString *ipadCol107;
@property (nonatomic, copy) NSString *beatsPerBar40;
@property (nonatomic, copy) NSString *tempo40;
@property (nonatomic, copy) NSString *riseFall;
@property (nonatomic, assign) NSInteger length109;
@property (nonatomic, copy) NSString *sharpFlat;
@property (nonatomic, copy) NSString *zLevel;
@property (nonatomic, copy) NSString *lyrics;
@property (nonatomic, copy) NSString *ipadRows;
@property (nonatomic, copy) NSString *ipadColor105;

@end
