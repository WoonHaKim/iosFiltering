//
//  ViewController.m
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 15..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import "MainVC.h"
#import "Constants.h"

#import "UtilFunctions.h"
#import "VideoFilterConf.h"


Mat image_copy;


@interface MainVC ()


@property (assign, nonatomic) BOOL started;


@end


@implementation MainVC


#pragma mark - Camera 세팅

-(void)initCamera:(NSInteger)cameraPosition{
    _camera = [[CvVideoCamera alloc] initWithParentView:cameraView];
    
    
    _camera.delegate = self;
    
    if (cameraPosition==CAMERA_POSITION_FRONT){
        _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;

    }else if (cameraPosition==CAMERA_POSITION_BACK ){
        _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;

    }else{
        UIAlertController *alert=[UtilFunctions getSimpleAlertVC:@"Camera" msg:@"Camera Configuration Error" okMsg:@"OK"];
        
        [self presentViewController:alert animated:YES completion:nil];
        _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;

    }
    _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetPhoto; //사이즈 설정

    _camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; //방향 설정

    _camera.rotateVideo = YES;
    _camera.defaultFPS = DEFAULT_FPS; // 프레임률
    [_camera start];
    

}
#pragma mark - view cycle
- (void)viewDidLoad {
    videoCamera.recordVideo = YES;
    self.started =NO;
    self.infoText1.text=@"";

    [self initRecBtn];
    
    [self initCamera:CAMERA_POSITION_BACK];



    
    [super viewDidLoad];
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    //화면 필터용 Observer 등록
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFilter:) name:@"filterObserver" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    //사용 하지 않는 Observer 제거
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:@"filterObserver" object:nil];

}



- (void)setFilter:(VideoFilterConf *)filterMode{
    
}


#pragma mark - openCV image Processing
- (void)processImage:(Mat&)image; {
    Mat image_copy2;
    
    cvtColor(image, image_copy, CV_BGRA2GRAY); //흑백 1채널로 변환
    cvtColor(image, image_copy2, CV_BGRA2GRAY);

    if (self.slider1.value>0 && self.slider2.value>0){
        Canny(image_copy2,image_copy,self.slider1.value*400,self.slider2.value*400); //외곽선 따기
    }
    //bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, image, CV_GRAY2BGRA);
    
    if (self.started) {
        videoWriter.write(image);
    }

    
}





#pragma mark - Button Tapped

- (IBAction)recBtnTapped:(id)sender {
    if ( self.started ==NO){
        [self startRecVideo];
    }else{
        [self stopRecVideo];
    }
    [self initRecBtn];
}

- (void)initRecBtn{
    if ( self.started ==NO){
        [self.recBtn setImage:[UIImage imageNamed:@"rec_normal"] forState:UIControlStateNormal];
        [self.recBtn setImage:[UIImage imageNamed:@"rec_pressed"] forState:UIControlStateFocused];

    }else{
        [self.recBtn setImage:[UIImage imageNamed:@"stop_normal"] forState:UIControlStateNormal];
        [self.recBtn setImage:[UIImage imageNamed:@"stop_pressed"] forState:UIControlStateFocused];
    }
}

#pragma mark - Record Video

- (void)startRecVideo{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath= [self pathToPatientPhotoFolder];

    filePath = [filePath stringByAppendingPathComponent:@"/output.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    const char *filePathStr = [filePath UTF8String];
    NSLog(@"Path Initialized");
    videoWriter = VideoWriter(filePathStr, CV_FOURCC('M','P','4','V'), DEFAULT_FPS, image_copy.size(), true);
    // videoWriter.open(filePathStr, CV_FOURCC('H','2','6','4'), 30, image_copy.size(), true);

    // Also used RPZA, H264, MP4V.
    self.started = YES;
    NSLog(@"Video Capture Started");
}

-(void)stopRecVideo{
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
    
    UIAlertController *alert=[UtilFunctions getSimpleAlertVC:@"Video Saved" msg:@"Video Saved in Photo-gallery" okMsg:@"OK"];
    
    [self presentViewController:alert animated:YES completion:nil];
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"settingsMenuModalSegue"]){
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
