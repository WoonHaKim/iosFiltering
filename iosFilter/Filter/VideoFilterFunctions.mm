//
//  VideoFilterFunctions.m
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 17..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import "VideoFilterFunctions.h"

@implementation VideoFilterFunctions

+(void)filterMonoChrome:(Mat &)input conf:(VideoFilterConf *)filterConf{
    Mat image_copy;
    cvtColor(input, image_copy, CV_BGRA2GRAY); //흑백 1채널로 변환
    cvtColor(image_copy, input, CV_GRAY2BGRA);

}

+(void)filterblur:(Mat &)input conf:(VideoFilterConf *)filterConf{
    Mat image_copy;

    cv::blur(input, image_copy, cv::Size(23,23));
    image_copy.convertTo(input, CV_BGR2BGRA);
    
}

+(void)filterCanny:(Mat &)input conf:(VideoFilterConf *)filterConf{
    Mat image_copy,image_copy2;

    cvtColor(input, image_copy, CV_BGRA2GRAY); //흑백 1채널로 변환
    cvtColor(input, image_copy2, CV_BGRA2GRAY);

    Canny(image_copy2,image_copy,20,400); //외곽선 따기
    //bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, input, CV_GRAY2BGRA);
}


+(void)filterProcess:(Mat &)input filterNo:(NSInteger)filterNo conf:(VideoFilterConf *)filterConf{
    switch (filterNo) {
        case 0:
            break;
        case 1:
            
            [VideoFilterFunctions filterMonoChrome:input conf:filterConf];
            break;
        case 2:
            [VideoFilterFunctions filterblur:input conf:filterConf];
            break;
        case 3:
            [VideoFilterFunctions filterCanny:input conf:filterConf];
            break;
        default:
            break;
    }
}

@end
