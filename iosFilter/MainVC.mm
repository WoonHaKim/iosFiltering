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
#import "ShareVC.h"


cv::Size image_size;

@interface MainVC ()


@property (assign, nonatomic) BOOL started;
@property (assign, nonatomic) BOOL filterEdit;

@property (assign, nonatomic) NSInteger filterNo;


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
    _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720; //사이즈 설정

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
    self.filterConf=[[VideoFilterConf alloc ]init];
    self.filterEdit=NO;
    
    [self initRecBtn];
    
    [self initCamera:CAMERA_POSITION_BACK];

    self.slider1.hidden=YES;
    self.slider2.hidden=YES;

    [self.filterPickerView setTransform:CGAffineTransformMakeTranslation(self.view.frame.size.width, 0)];
    filterList = [[NSArray alloc] initWithObjects:@"없음",@"흑백",@"흐림",@"윤곽선",nil];
    self.filterPickerView.delegate=self;

    
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



- (void)setFilter:(VideoFilterConf *)filterConf{
    self.filterConf=filterConf;
}


#pragma mark - openCV image Processing
- (void)processImage:(Mat&)image; {
    if (image_size.width<=0){
        image_size=image.size();
    }
    switch (self.filterNo) {
        case 0:
            
            
            break;
        case 1:
            
            [VideoFilterFunctions filterMonoChrome:image conf:self.filterConf];
            break;
        case 2:
            [VideoFilterFunctions filterblur:image conf:self.filterConf];
            break;
        case 3:
            [VideoFilterFunctions filterCanny:image conf:self.filterConf];
            break;
        default:
            break;
    }

    //[VideoFilterFunctions filterMonoChrome:image conf:self.filterConf];
 //   [VideoFilterFunctions filterblur:image conf:self.filterConf];
   // [VideoFilterFunctions filterCanny:image conf:self.filterConf];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.started==YES) {
            videoWriter.write(image);
        }
    });


    
}





#pragma mark - Button Tapped

- (IBAction)recBtnTapped:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self.started ==NO){
            [self startRecVideo];
        }else{
            [self stopRecVideo];
        }
    [self initRecBtn];
    });

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
- (IBAction)filterBtnTapped:(id)sender {
    CGFloat origin=0;
    NSString *btnTitle=@"";
    if (self.filterEdit==NO){
        origin=0;
        self.filterEdit=YES;
        btnTitle=@"OK";

    }else{
        origin=self.view.frame.size.width;
        self.filterEdit=NO;
        btnTitle=@"Filter";

    }
    [UIView animateWithDuration:0.2f
                     animations:^{
                         CGRect frame = self.filterPickerView.frame;
                         frame.origin.x = origin;
                         self.filterPickerView.frame = frame;
                     }
                     completion:^(BOOL finished){

                     }
     ];
    


}






#pragma mark - Record Video

- (void)startRecVideo{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath= [self pathToPatientPhotoFolder];

    filePath = [filePath stringByAppendingPathComponent:@"/output.mov"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    const char *filePathStr = [filePath UTF8String];
    NSLog(@"Path Initialized");
    videoWriter = VideoWriter(filePathStr, CV_FOURCC('H','2','6','4'), DEFAULT_FPS, image_size, true);
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
    filePath = [filePath stringByAppendingPathComponent:@"/output.mov"];
    
    //Alert window
    UIAlertController * choiceVC=   [UIAlertController
                                  alertControllerWithTitle:@"녹화가 완료 되었습니다."
                                  message:@"어떤 작업을 할지 선택해 주세요"
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* actionSaveVideo = [UIAlertAction
                         actionWithTitle:@"저장하기"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self performSelector:@selector(UpdateVideoAndConfigureScreenForURL:) withObject:filePath afterDelay:0.1];
                             [choiceVC dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* actionShareVideo = [UIAlertAction
                                      actionWithTitle:@"공유하기"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [self shareAction:@"Hello" param:@"aaa"];
                                          [choiceVC dismissViewControllerAnimated:YES completion:nil];
                                          
                                      }];

    
    [choiceVC addAction:actionSaveVideo];
    [choiceVC addAction:actionShareVideo];
    
    [self presentViewController:choiceVC animated:YES completion:nil];
    
    



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



-(void)shareAction:(NSString *)str param:(NSString *)strTitle{
    NSString *title = strTitle;
    NSURL *url = [[NSURL alloc]initWithString:str];
    NSMutableArray *postItems = [NSMutableArray new];
    
    [postItems addObject:title];
    [postItems addObject:url];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[];
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *) pickerView numberOfRowsInComponent : (NSInteger)component{
        return [filterList count];
}

// 피커를 사용하기 위해 반드시 사용되어야 할 필수 델리게이트이다.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow: (NSInteger)row forComponent: (NSInteger)component{
    
    return [filterList objectAtIndex:row]; //0번째 컴퍼넌트의 선택된 문자열을 반환한다.
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.filterNo=row;
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
