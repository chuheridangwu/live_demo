//
//  WTRecordVideoViewController.m
//  AVStream
//
//  Created by gaoshuang  on 2018/7/5.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//
//#import <LFLiveKit/LFLiveKit.h>
#import "LFLiveKit.h"
#import "TGViewController.h"
#import "AVUtil.h"
#define DEFAULT_VIDEO_SIZE (CGSizeMake(576.,1024.))
#import "GPUImageBeautifyFilter.h"
//#import "SSCaptureMedia.h"
#import "LFLivePreview.h"
#define SHORT_VIDEO_FPS (20)
#import "DeerPushViewModel.h"
#import "TGOpenGLView.h"
#import "TGCamera.h"
@interface TGViewController ()<LFLiveSessionDelegate,TGCameraDelegate>
{
    LFLivePreview *livePreview;
    
    LFLiveSession *_liveSession;
}
@property (strong,nonatomic) UIView* videoView;
@property (strong, nonatomic)CNMButton* buttonBack;
@property (strong, nonatomic)CNMButton* buttonFlash;
@property (strong, nonatomic)CNMButton* buttonSwitch;
@property (strong, nonatomic)CNMButton* buttonFilters;
@property (strong, nonatomic)CNMButton* buttonBeauty;
@property (strong, nonatomic)CNMButton* buttonFace;
@property (strong, nonatomic)CNMButton* buttonFaceEyes;
@property (strong, nonatomic)CNMButton* buttonMusic;
@property (strong, nonatomic)CNMButton* buttonRecord;
@property (nonatomic,assign) BOOL isAllowViedo;
@property (nonatomic,strong)TGCamera *mCamera;
@property (nonatomic,strong)TGOpenGLView *viewSession;

@end
@implementation TGViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [livePreview removeFromSuperview];
    livePreview = nil;
    [super viewDidDisappear:YES];
}

//-(void)LFLiveSessionCustom{
//    LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
//    audioConfiguration.numberOfChannels = 2;
//    audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
//    audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
//
//
//    LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
//
//    videoConfiguration.videoBitRate = 1100*1024;
//    videoConfiguration.videoMaxBitRate = 1300*1024;
//    videoConfiguration.videoMinBitRate = 100*1024;
//
//    videoConfiguration.videoFrameRate = 20;//FPS:16
//    videoConfiguration.videoMinFrameRate = 20;//FPS:16
//    videoConfiguration.videoMaxFrameRate = 20;//FPS:16
//    videoConfiguration.videoMaxKeyframeInterval = 20 * 2;
//    //    videoConfiguration.outputImageOrientation = UIInterfaceOrientationPortrait;
//    //    videoConfiguration.autorotate = YES;
//    LFLiveVideoSessionPreset preset ;
//    preset = LFCaptureSessionPreset720x1280;
//    videoConfiguration.sessionPreset = preset;
//    videoConfiguration.videoSize = CGSizeMake(432, 768);
//    _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
//
//    _liveSession.delegate = self;
//    _liveSession.showDebugInfo = YES;
//    _liveSession.preView = self.view;
//    [_liveSession setRunning:YES];
//
//}

-(void)TGCaptureMedia{
    
    LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
    audioConfiguration.numberOfChannels = 2;
    audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
    audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;


    LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];

    videoConfiguration.videoBitRate = 1100*1024;
    videoConfiguration.videoMaxBitRate = 1300*1024;
    videoConfiguration.videoMinBitRate = 100*1024;

    videoConfiguration.videoFrameRate = 20;//FPS:16
    videoConfiguration.videoMinFrameRate = 20;//FPS:16
    videoConfiguration.videoMaxFrameRate = 20;//FPS:16
    videoConfiguration.videoMaxKeyframeInterval = 20 * 2;
//        videoConfiguration.outputImageOrientation = UIInterfaceOrientationPortrait;
//        videoConfiguration.autorotate = YES;
    LFLiveVideoSessionPreset preset ;
    preset = LFCaptureSessionPreset720x1280;
    videoConfiguration.sessionPreset = preset;
    videoConfiguration.videoSize = CGSizeMake(432, 768);
//
//内部捕获音频和外部输入视频
    _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration captureType:LFLiveCaptureMaskAudioInputVideo];
    //手动录制
//    _liveSession.audioCaptureSource.running = YES;
    _liveSession.running = YES;
    
 
    
    
    _viewSession = [[TGOpenGLView alloc]init];
    _viewSession.frame = self.view.frame;
    _viewSession.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_viewSession];
    [self.mCamera startCapture];
}
- (TGCamera*)mCamera{
    if (!_mCamera) {
        _mCamera = [[TGCamera alloc]init];
        _mCamera.delegate = self;
    }
    return _mCamera;
}
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    //    CVPixelBufferRef outputbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferRef outputbuffer =pixelBuffer;
    CVPixelBufferRetain(outputbuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_viewSession) {
            [self->_viewSession displayPixelBuffer:outputbuffer];
        }
        else {
            [self.mCamera stopCapture];
        }
        CVPixelBufferRelease(outputbuffer);
    });
    [_liveSession pushVideo:outputbuffer];
  
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

[self TGCaptureMedia];


    WEAKSELF
    [self setupViews];
    self.navigationController.navigationBarHidden = YES;

     [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
         button.butNormalTitle(@"back");
         
     } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
         make.size.mas_equalTo(CGSizeMake(50, 30));
         make.top.equalTo(self.view).offset(50);
         make.left.equalTo(self.view).offset(50);
     } withButtonBlock:^(CNMButton *button) {
         [weakSelf back];
     }];
}

//-(void)processAudioBuffer:(CMSampleBufferRef)audioBuffer{
//
//
//    CMSampleBufferRef  ref = audioBuffer;
//    //复制数据到文件
//    //读取下一个
//    AudioBufferList audioBufferList;
//    NSMutableData *data=[[NSMutableData alloc] init];
//    CMBlockBufferRef blockBuffer;
//    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(ref, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
//    NSLog(@"%@",blockBuffer);
//
//
//
//    for( int y=0; y<audioBufferList.mNumberBuffers; y++ )
//    {
//        AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
//        Float32 *frame = (Float32*)audioBuffer.mData;
//
//
//        [data appendBytes:frame length:audioBuffer.mDataByteSize];
//
//
//
//    }
//    ref=NULL;
//    blockBuffer=NULL;
//    [_liveSession pushAudio:data];
//}
//-(void)processVideoBuffer:(CVPixelBufferRef)videoBuffer{
//    [_liveSession pushVideo:videoBuffer];
//}
-(void)setupViews{
    _buttonBack = [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalImageName(@"video_Back-1");
        
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.size.mas_equalTo(cnm.imageView.image.size);
        make.left.top.equalTo(self.view).offset(15);
    } withButtonBlock:^(CNMButton *button) {
        [self popCanvas];
    }];
    
    _buttonSwitch = [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalImageName(@"video_flash_off");
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.size.mas_equalTo(cnm.imageView.image.size);
        make.right.top.equalTo(self.view).offset(-15);
    } withButtonBlock:^(CNMButton *button) {
        
    }];
    
    
    NSArray *array = @[
        @{@"TITLE":@"滤镜",@"IMAGE":@"video_filters",@"SELECTOR":@"doShowFilters"},
        @{@"TITLE":@"美颜开",@"IMAGE":@"video_beauty_on",@"SELECTOR":@"doChangeBeauty"},
        @{@"TITLE":@"萌颜",@"IMAGE":@"logo_face",@"SELECTOR":@"doShowFaces"},
        @{@"TITLE":@"大眼瘦脸",@"IMAGE":@"DREditFaceThin",@"SELECTOR":@"doViewBigEyeThin"},
        @{@"TITLE":@"音乐",@"IMAGE":@"DRSelectMusic",@"SELECTOR":@"doChanggeMusic"},
    ];
    
    CGFloat top = 50;
    
    for (NSInteger i = 0; i<array.count; i++) {
        
        CNMButton* button = [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
            button.butNormalTitle(@"开始直播");
        } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.right.equalTo(_buttonSwitch);
            make.top.equalTo(self.view).offset(top);
        } withButtonBlock:^(CNMButton *button) {
            LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
            stream.url = @"rtmp://push.mlive.in.th/live/536e2386a2d598824fa3605a644fd67c";
            [_liveSession startLive:stream];
            
//            [[DeerPushViewModel instance] startLive:nil];
        }];
        
        [CNMLabel cnm_LabInitWithSuperView:self.view withBlock:^(CNMLabel *cnm) {
            cnm.labText(array[i][@"TITLE"]);
        } withlabWithMas_makeConstraints:^(MASConstraintMaker *make, CNMLabel *cnm) {
            make.size.mas_equalTo(cnm.sizeFree);
            make.top.equalTo(button.mas_bottom).offset(10);
            make.centerX.equalTo(button);
        }];
        top+=50;
    }
    
    
    
    
    
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc___LFLiveKitViewController");
}
-(void)back{


    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"liveStateDidChange: %ld", state);
    switch (state) {
        case LFLiveReady:
            NSLog(@"未连接");
            //            _stateLabel.text = @"未连接";
            break;
        case LFLivePending:
            NSLog(@"连接中");
            //            _stateLabel.text = @"连接中";
            break;
        case LFLiveStart:
            NSLog(@"已连接");
            //            _stateLabel.text = @"已连接";
            break;
        case LFLiveError:
            NSLog(@"连接错误");
            //            _stateLabel.text = @"连接错误";
            break;
        case LFLiveStop:
            NSLog(@"未连接");
            //            _stateLabel.text = @"未连接";
            break;
        default:
            break;
    }
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    //    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"errorCode: %ld", errorCode);
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

