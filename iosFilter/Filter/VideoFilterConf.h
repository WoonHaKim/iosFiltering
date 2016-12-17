//
//  VideoFilterConf.h
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 17..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface VideoFilterConf : NSObject

@property (strong, nonatomic) NSString* filterName;
@property (strong, nonatomic) NSString* filterDetail;

@property (strong, nonatomic) NSArray* filterConfValue;

- (instancetype)init;

@end
