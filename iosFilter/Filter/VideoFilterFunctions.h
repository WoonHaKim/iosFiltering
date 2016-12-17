//
//  VideoFilterFunctions.h
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 17..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoFilterConf.h"


//OpenCV
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/core/core_c.h>
using namespace cv;

@interface VideoFilterFunctions : NSObject

+(void)filterMonoChrome:(Mat &)input conf:(VideoFilterConf *)conf;
+(void)filterblur:(Mat &)input conf:(VideoFilterConf *)conf;
+(void)filterCanny:(Mat &)input conf:(VideoFilterConf *)conf;

@end
