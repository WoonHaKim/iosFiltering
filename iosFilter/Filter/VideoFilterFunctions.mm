//
//  VideoFilterFunctions.m
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 17..
//  Copyright © 2016년 김운하. All rights reserved.
//
#import "Constants.h"
#import "VideoFilterFunctions.h"

@implementation VideoFilterFunctions

void filterMonoChrome(Mat & input ,float filterConf){
    Mat image_copy;
    cvtColor(input, image_copy, CV_BGRA2GRAY); //흑백 1채널로 변환
    cvtColor(image_copy, input, CV_GRAY2BGRA);

}

void filterblur(Mat & input, float filterConf){
    Mat image_copy;
    int dSize=FILTER_BLUR_DSIZE_MAX;
    dSize=floor(filterConf*(float)FILTER_BLUR_DSIZE_MAX)+1;
    

    cv::blur(input, image_copy, cv::Size(dSize,dSize));
    image_copy.convertTo(input, CV_BGR2BGRA);
    
}

void filterCanny(Mat & input ,float filterConf){
    Mat image_copy,image_copy2;

    int dSize=FILTER_CANNY_DSIZE_MIN;
    dSize=floor(filterConf*(float)FILTER_CANNY_DSIZE_MAX);
    
    
    cvtColor(input, image_copy, CV_BGRA2GRAY); //흑백 1채널로 변환
    cvtColor(input, image_copy2, CV_BGRA2GRAY);

    Canny(image_copy2,image_copy,dSize,FILTER_CANNY_DSIZE_MAX); //외곽선 따기
    bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, input, CV_GRAY2BGRA);
}

void filterthr( Mat & input ,float filterConf){
    Mat image_copy,image_copy2;
    cvtColor(input, image_copy, CV_BGRA2GRAY );
    threshold( image_copy, image_copy2, floor(filterConf*FILTER_THRESHOLD_MAX), FILTER_THRESHOLD_MAX,CV_THRESH_BINARY );
   // bitwise_not(image_copy2 , image_copy2);
    cvtColor(image_copy2, input, CV_GRAY2BGRA);


}

void filterErode(Mat & input, float filterConf){
    Mat image_copy;
    int erosion_value=floor(filterConf*FILTER_EROSION_MAX);
    Mat kernel_element = Mat(erosion_value, erosion_value, CV_8U, cv::Scalar(1));
    erode(input, input, kernel_element);

    
}


+(void)filterProcess:(Mat &)input filterNo:(NSInteger)filterNo conf:(float)filterConf{
    switch (filterNo) {
        case 0:
            break;
        case 1:
            
            filterMonoChrome(input ,filterConf);
            break;
        case 2:
            filterblur(input ,filterConf);
            break;
        case 3:
            filterthr(input ,filterConf);
            break;
        case 4:
            filterErode(input ,filterConf);
            break;
        case 5:
            filterCanny(input ,filterConf);
            break;
        default:
            break;
    }
}

@end
