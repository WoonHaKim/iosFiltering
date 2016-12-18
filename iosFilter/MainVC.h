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
#import "VideoFilterConf.h"
#import "VideoFilterFunctions.h"


//OpenCV
#import <opencv2/opencv.hpp> 
#import <opencv2/imgproc/imgproc_c.h> 
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/core/core_c.h>
using namespace cv;

@interface MainVC : UIViewController <CvVideoCameraDelegate, AVCaptureVideoDataOutputSampleBufferDelegate,UIPickerViewDelegate, UIPickerViewDataSource>{
    IBOutlet UIImageView *cameraView;
    CvVideoCamera* videoCamera;
    
    cv::VideoWriter videoWriter;
    float filterConf;
    NSArray* filterList;
}

@property (nonatomic, retain) CvVideoCamera *camera;
@property (weak, nonatomic) IBOutlet UIButton *recBtn;


@property (strong, nonatomic) NSTimer *countTimer;

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;


@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;

@property (weak, nonatomic) IBOutlet UIPickerView *filterPickerView;

@property (weak, nonatomic) IBOutlet UILabel *infoText1;
@property (weak, nonatomic) IBOutlet UILabel *infoText2;


@end

