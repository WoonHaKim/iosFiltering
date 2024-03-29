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
cv::Mat image_temp;
cv::Mat image_read;
std::deque<cv::Mat> play_buffer;
dispatch_queue_t queue;

@interface MainVC ()


@property (assign, nonatomic) BOOL started;
@property (assign, nonatomic) BOOL filterEdit;

@property (assign, nonatomic) NSInteger filterNo;

@property (assign, nonatomic) NSInteger recSec;
@property (assign, nonatomic) NSInteger recMin;


@end


@implementation MainVC


#pragma mark - Camera 세팅

-(void)initCamera:(NSInteger)cameraPosition{
    self.camera = [[CvVideoCamera alloc] initWithParentView:cameraView];
    self.camera.delegate = self;

    [cameraView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-150) ];

    NSLog(@"%f",cameraView.frame.size.height);

    [cameraView setContentMode:UIViewContentModeScaleToFill];
    if (cameraPosition==CAMERA_POSITION_FRONT){
        self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;

    }else if (cameraPosition==CAMERA_POSITION_BACK ){
        self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;

    }else{
        UIAlertController *alert=[UtilFunctions getSimpleAlertVC:@"Camera" msg:@"Camera Configuration Error" okMsg:@"OK"];
        
        [self presentViewController:alert animated:YES completion:nil];
        self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;

    }
    self.camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium; //사이즈 설정
    
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; //방향 설정

    self.camera.rotateVideo = YES;
    self.camera.defaultFPS=DEFAULT_FPS; // 프레임률
    [self.camera start];

}
#pragma mark - view cycle
- (void)viewDidLoad {
    
    queue = dispatch_queue_create("com.uhkim.iosFilter", NULL);
 
    
    videoCamera.recordVideo = YES;
    self.started =NO;
    self.infoText1.text=@"";
    filterConf=0;
    self.filterEdit=NO;
    self.filterNo=0;
    
    image_temp=Mat();
    
    [self initRecBtn];
    
    [self initCamera:CAMERA_POSITION_BACK];

    self.slider1.hidden=YES;
    self.slider2.hidden=YES;
    

    self.filterPickerView.hidden=YES;
    filterList = [[NSArray alloc] initWithObjects:@"없음",@"흑백",@"흐림",@"경계",@"단순화",@"윤곽선",nil];
    self.filterPickerView.delegate=self;

    play_buffer=std::deque<cv::Mat>();
    play_buffer.clear();

    
    [super viewDidLoad];
    
    
}
- (void)viewWillAppear:(BOOL)animated{

}

- (void)viewWillDisappear:(BOOL)animated{

}




#pragma mark - openCV image Processing
- (void)processImage:(Mat&)image; {
    if (image_size.width<=0){
        image_size=image.size();
    }

    filterConf=self.slider1.value;

    [VideoFilterFunctions filterProcess:image filterNo:self.filterNo conf:filterConf];

    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.started==YES) {

            cv::cvtColor(image, image_temp, CV_BGRA2RGBA);
          //  play_buffer.push_back(image_temp);
          //  videoWriter.write(image_temp);

        }
    });
    


    
}





#pragma mark - Button Tapped

- (IBAction)recBtnTapped:(id)sender {
        if ( self.started ==NO){
            [self startRecVideo];
        }else{
            [self stopFrameGetTimer];
            [self.camera stop];
            //[self flushVector];
            [self stopRecVideo];

        }
    dispatch_async(dispatch_get_main_queue(), ^{
        
    [self initRecBtn];
    });

}

- (void)initRecBtn{
    if ( self.started ==NO){
        [self.recBtn setImage:[UIImage imageNamed:@"rec_normal"] forState:UIControlStateNormal];
        [self.recBtn setImage:[UIImage imageNamed:@"rec_pressed"] forState:UIControlStateHighlighted];

    }else{
        [self.recBtn setImage:[UIImage imageNamed:@"stop_normal"] forState:UIControlStateNormal];
        [self.recBtn setImage:[UIImage imageNamed:@"stop_pressed"] forState:UIControlStateHighlighted];
    }
}
- (IBAction)filterBtnTapped:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *btnTitle=@"";
        if (self.filterEdit==NO){
            self.filterEdit=YES;
            self.filterPickerView.hidden=YES;
            btnTitle=@"OK";
            [self.settingsBtn setImage:[UIImage imageNamed:@"filter_normal"] forState:UIControlStateNormal];


        }else{
            self.filterEdit=NO;
            self.filterPickerView.hidden=NO;

            btnTitle=@"Filter";
            [self.settingsBtn setImage:[UIImage imageNamed:@"filter_selected"] forState:UIControlStateNormal];


        }
        if (self.filterNo==0 || self.filterNo==1){

            self.slider1.hidden=YES;
            
        }else{
            self.slider1.hidden=NO;
            
        }

        
    });
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

    play_buffer.clear();
    [self initTimer];
    // Also used RPZA, H264, MP4V.
    self.started = YES;
    NSLog(@"Video Capture Started");
    [self initFrameGetTimer];
}


-(void)flushVector{
    NSLog(@"Vector Size:%ld",play_buffer.size());
    if(videoWriter.isOpened()){
        for(int i=0;i<play_buffer.size();i++){
            
            videoWriter.write(play_buffer[i]);
            
        }
    }
}

-(void)stopRecVideo{
    self.started = NO;

    videoWriter.release();


    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath= [self pathToPatientPhotoFolder];
    filePath = [filePath stringByAppendingPathComponent:@"/output.mov"];
    
    [self stopTimer];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *devType=device.model;
    
    UIAlertControllerStyle style=UIAlertControllerStyleActionSheet;
    if ([devType containsString:@"iPad"]){
        style=UIAlertControllerStyleAlert;
    }else{
        
    }
    
    
    //Alert window
    UIAlertController * choiceVC=   [UIAlertController
                                  alertControllerWithTitle:@"녹화가 완료 되었습니다."
                                  message:@"어떤 작업을 할지 선택해 주세요"
                                  preferredStyle:style];
    
    UIAlertAction* actionSaveVideo = [UIAlertAction
                         actionWithTitle:@"저장하기"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self performSelector:@selector(UpdateVideoAndConfigureScreenForURL:) withObject:filePath afterDelay:0.2];
                             [choiceVC dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* actionShareVideo = [UIAlertAction
                                      actionWithTitle:@"공유하기"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [self shareAction:@"Hello" title:@"이 비디오는 테스트 앱에서 생성 되었습니다." params:[NSMutableArray arrayWithObject:[NSURL fileURLWithPath:filePath isDirectory:NO]]];
                                          [choiceVC dismissViewControllerAnimated:YES completion:nil];
                                          
                                      }];
    UIAlertAction* actionCancelVideo = [UIAlertAction
                                      actionWithTitle:@"취소"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [choiceVC dismissViewControllerAnimated:YES completion:nil];
                                          
                                      }];
    
    [choiceVC addAction:actionSaveVideo];
    [choiceVC addAction:actionShareVideo];
    [choiceVC addAction:actionCancelVideo];

    [self presentViewController:choiceVC animated:YES completion:nil];
    [self initCamera:self.cameraSelect.selectedSegmentIndex];
    



}

- (void)UpdateVideoAndConfigureScreenForURL:(NSString * ) filePath{
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath)) {
        NSLog(@"Compatible");
        UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
        
        UIAlertController *alert=[UtilFunctions getSimpleAlertVC:@"저장 완료" msg:@"사진에 저장되었습니다."];
        
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });

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

#pragma mark - 공유기능


-(void)shareAction:(NSString *)urlStr title:(NSString *)strTitle params:(NSMutableArray *)paramItems{
    NSString *title = strTitle;
    NSURL *url = [[NSURL alloc]initWithString:urlStr];
    NSMutableArray *postItems = [NSMutableArray new];
    
    [postItems addObject:title];
    [postItems addObject:url];
    [postItems addObjectsFromArray:paramItems];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    activityVC.popoverPresentationController.sourceView=self.view;
    activityVC.excludedActivityTypes = @[];
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    
}

#pragma mark - Filter 선택용 PickerView

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
    self.slider1.value=0.5;
    self.slider2.value=0;
}




- (void)setFilter:(float)value{
    filterConf=value;
}

#pragma mark - prepare for sague

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"settingsMenuModalSegue"]){
        
    }
}

#pragma mark - 메모리 관리

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - timer

- (void)initTimer{
    self.recSec=0;
    self.recMin=0;

    self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:[[NSDictionary alloc]initWithObjects:@[@"timerID"] forKeys:@[@"t00001"]] repeats:YES];
    NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];
    [theRunLoop addTimer:self.countTimer forMode:NSDefaultRunLoopMode];
}

- (void)updateTimer{
    if (self.countTimer.isValid){
        self.recSec++;
        if(self.recSec==60){
            self.recMin++;
            self.recSec=0;

        }

    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.infoText2.text=[NSString stringWithFormat:@"%ld:%ld",(long)self.recMin,(long)self.recSec];
    });
}

- (void)stopTimer{
    [self.countTimer invalidate];

    self.recSec=0;
    self.recMin=0;
    
    [self updateTimer];
}

#pragma mark - 프레임 저장
-(void)initFrameGetTimer{
    float timeInterval=(float)1/(float)DEFAULT_FPS;
    self.frameTimer= [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(getFrameCapture) userInfo:[[NSDictionary alloc]initWithObjects:@[@"timerID"] forKeys:@[@"t00002"]] repeats:YES];
    NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];
    [theRunLoop addTimer:self.countTimer forMode:NSDefaultRunLoopMode];
}

-(void)getFrameCapture{

        image_read=image_temp.clone();
    dispatch_async(dispatch_get_main_queue(), ^{

        if(videoWriter.isOpened()){
            videoWriter.write(image_read);
        }
    });

}

-(void)stopFrameGetTimer{
    [self.frameTimer invalidate];

}

#pragma mark - 전후면 카메라 선택

- (IBAction)cameraSelChange:(UISegmentedControl *)sender {
    if(self.started==YES){
        self.started=NO;
        videoWriter.release();
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initRecBtn];
    });
    
    [self.camera stop];
    image_size.width=-1;
    if (sender.selectedSegmentIndex==0){
        [self initCamera:CAMERA_POSITION_BACK];
    }else{
        
        [self initCamera:CAMERA_POSITION_FRONT];

    }
}




@end
