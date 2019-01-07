//
//  NSData+JSON.m
//  StaffSocialNetwork
//
//  Created by Gary on 29/9/13.
//  Copyright (c) 2013 Nuthon IT Solutions Ltd. All rights reserved.
//

#import "NSData+JSON.h"

@implementation NSData (JSON)


- (id)JSONObject {
    id jsonObj = [NSJSONSerialization JSONObjectWithData:self
                                                 options:NSJSONReadingAllowFragments
                                                   error:nil];
    return jsonObj;
}

- (NSString *)string {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}
@end
