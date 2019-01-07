//
//  Constant.m
//  DSDDemo
//
//  Created by Leong on 18/1/13.
//  Copyright (c) 2013 Leong. All rights reserved.
//

#import "Constant.h"

@implementation Constant

- (id)init {
    self = [super init];
    if (self) {
        self.unit_size = 36;
        self.note_gap = 6;
        self.v_spacing_size = 14;
        self.display_size = self.unit_size - self.note_gap;
        self.v_offset_size = (self.unit_size + self.v_spacing_size)/2;
    }
    return self;
}

@end
