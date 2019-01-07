//
//  DSDShaderModel.m
//  DSDDemo
//
//  Created by HJR on 2018/12/16.
//  Copyright © 2018年 Leong. All rights reserved.
//

#import "DSDShaderModel.h"

@implementation DSDShaderModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"content" : @"Content",
             @"fingeringChord" : @"fingering/chord",
             @"barNo40" : @"Bar No(40)",
             @"flipView" : @"flip_view",
             @"channel" : @"channel",
             @"height110" : @"height(110)",
             @"ipadCol107" : @"ipad_col(107)",
             @"beatsPerBar40" : @"Beats per Bar(40)",
             @"tempo40" : @"tempo (40)",
             @"riseFall" : @"rise_fall",
             @"length109" : @"length(109)",
             @"sharpFlat" : @"sharp_flat",
             @"zLevel" : @"Z-level",
             @"lyrics" : @"lyrics",
             @"ipadRows" : @"ipad_rows",
             @"length109" : @"length(109)",
             @"ipadColor105" : @"ipad_color(105)"};
}
@end
