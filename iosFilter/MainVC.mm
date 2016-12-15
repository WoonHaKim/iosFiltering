//
//  ViewController.m
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 15..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import "MainVC.hpp"

Mat image_copy;


@interface MainVC ()



@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (assign, nonatomic) BOOL started;


@end


@implementation MainVC


#pragma mark - Camera 세팅

-(void)initCamera{
    _camera = [[CvVideoCamera alloc] initWithParentView:cameraView];
    
    
    _camera.delegate = self;
    _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; //장치 설정
    _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480; //사이즈 설정
    _camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; //방향 설정

    _camera.rotateVideo = YES;
    _camera.defaultFPS = 30; // 프레임률 [camera start];
    
    
}

- (void)viewDidLoad {
    videoCamera.recordVideo = YES;

    
    [self initCamera];
    
    [super viewDidLoad];
    
    [_camera start];

    
}

- (void)processImage:(Mat&)image; { //여기서 opencv 작업을 함
    Mat image_copy2;
    
    cvtColor(image, image_copy, CV_BGRA2GRAY); //흑백 1채널로 변환
    cvtColor(image, image_copy2, CV_BGRA2GRAY);
    Canny(image_copy2,image_copy,200,200); //외곽선 따기
    bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, image, CV_GRAY2BGRA);
    
    if (self.started) {
        videoWriter.write(image);
    }

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)stopVideo:(id)sender {
    [self saveVideo];
}

- (void)saveVideo{
    NSString* relativePath = [videoCamera.videoFileURL relativePath];
    UISaveVideoAtPathToSavedPhotosAlbum(relativePath, nil, NULL, NULL);
    
    
    //Alert window
    UIAlertView *alert = [UIAlertView alloc];
    alert = [alert initWithTitle:@"Status"
                         message:@"Saved to the Gallery!"
                        delegate:nil
               cancelButtonTitle:@"Continue"
               otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Action and Selector methods
- (IBAction)startBtnTapped:(id)sender {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath= [self pathToPatientPhotoFolder];

    filePath = [filePath stringByAppendingPathComponent:@"/output.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    const char *filePathStr = [filePath UTF8String];
    NSLog(@"Path Initialized");
    videoWriter = VideoWriter(filePathStr, CV_FOURCC('M','P','4','V'), 30, image_copy.size(), true);
   // videoWriter.open(filePathStr, CV_FOURCC('H','2','6','4'), 30, image_copy.size(), true);

    // Also used RPZA, H264, MP4V.
    self.started = YES;
    NSLog(@"Video Capture Started");

}

- (IBAction)endBtnTapped:(id)sender {
    self.started = NO;
    
    videoWriter.release();
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath= [self pathToPatientPhotoFolder];
    filePath = [filePath stringByAppendingPathComponent:@"/output.mp4"];
    [self performSelector:@selector(UpdateVideoAndConfigureScreenForURL:) withObject:filePath afterDelay:0.2];

}

- (void)UpdateVideoAndConfigureScreenForURL:(NSString * ) filePath{
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath)) {
        NSLog(@"Compatible");
        UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
    }
    else {
        NSLog(@"Not Compatible");
    }
}

- (NSString *)pathToPatientPhotoFolder {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask,
                                                                        YES) lastObject];
    NSString *patientPhotoFolder = [documentsDirectory stringByAppendingPathComponent:@"patientPhotoFolder"];
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:patientPhotoFolder  isDirectory:&isDir] && isDir == NO) {
        [fileManager createDirectoryAtPath:patientPhotoFolder
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
        NSLog(@"Dir Created!!");
    }
    return patientPhotoFolder;
}
@end
