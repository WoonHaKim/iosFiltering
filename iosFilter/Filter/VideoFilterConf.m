//
//  VideoFilterConf.m
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 17..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import "VideoFilterConf.h"

@implementation VideoFilterConf

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"Initializing Filter Conf...");
        self.filterName=@"defaultFilter";
        self.filterName=@"filter Default";
        self.filterConfValue=nil;
    }
    return self;
}

@end
