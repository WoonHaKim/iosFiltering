//
//  ViewController.h
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 15..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <stdlib.h>


#import <opencv2/opencv.hpp> 
#import <opencv2/imgproc/imgproc_c.h> 
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/core/core_c.h>
using namespace cv;

@interface MainVC : UIViewController <CvVideoCameraDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>{
    IBOutlet UIImageView *cameraView;
    CvVideoCamera* videoCamera;
    
    cv::VideoWriter videoWriter;

}

@property (nonatomic, retain) CvVideoCamera *camera;



@end

