//
//  RecordVideoViewController.m
//  AVStream
//
//  Created by gaoshuang  on 2018/4/26.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import "RecordVideoViewController.h"
#import "AVUtil.h"
#define DEFAULT_VIDEO_SIZE (CGSizeMake(576.,1024.))
#import "GPUImageBeautifyFilter.h"
#import "LFGPUImageBeautyFilter.h"
#import "LFGPUImageEmptyFilter.h"
#import "FilterTypeView.h"
#import "AVProgressView.h"
#import "AVPlayerViewController.h"
#define PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject

@interface RecordVideoViewController ()
{
    NSTimer *_timer;
}
@property (strong, nonatomic)GPUImageStillCamera* videoCamera;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *output;
//美颜
@property (nonatomic, strong) LFGPUImageBeautyFilter<GPUImageInput> *filter;
//滤镜
@property (nonatomic, strong) GPUImageFilter<GPUImageInput> *filterViewfilter;
//滤镜组
@property (nonatomic,strong) GPUImageFilterGroup    *filterGroup;

@property (nonatomic, strong) GPUImageMovieWriter* writer;
@property (nonatomic,strong)NSURL* urlWriter;
@property (strong,nonatomic) CNMImageView* imageView;
////实时预览的view,GPUImageView是响应链的终点，一般用于显示GPUImage的图像。
@property (strong,nonatomic) GPUImageView* viewGPUImageVideo;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (strong, nonatomic) GPUImageMovie *movie;
@property (strong,nonatomic) GPUImageView* imageViewPayer;
//滤镜view
@property (nonatomic, strong) FilterTypeView *filterView;

//美颜
@property (strong,nonatomic) CNMButton* butttonBeauty;
//录制暂停
@property (strong,nonatomic) CNMButton* butttonRecord;
//录制结束
@property (strong,nonatomic) CNMButton* butttonRecordFinish;

//滤镜
@property (strong,nonatomic) CNMButton* butttonfilterView;
//水印
@property (strong,nonatomic) CNMButton* butttonWaterView;

//存放视频URL
@property (nonatomic, strong) NSMutableArray *videoArray;
//存放每一段视频的进度
@property (nonatomic, strong) NSMutableArray *videoDurationArray;
//进度条view
@property (nonatomic, strong) AVProgressView *progressBgView;

//水印
@property (nonatomic, strong) UIView *waterMarkContentView;
@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;
@property (nonatomic, strong) GPUImageUIElement *uiElementInput;
@end

@implementation RecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testVideo];
    // Do any additional setup after loading the view.
}

-(void)testVideo{
  
//    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = YES;
    self.videoArray = [NSMutableArray new];
      self.videoDurationArray = [NSMutableArray new];
    [self initUI];
    
    // 初始化 filterGroup
    [self reloadFilter];
    [self.videoCamera startCameraCapture];
    
    
}
-(GPUImageStillCamera *)videoCamera{
    if (!_videoCamera) {
        _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
        //设置下面这个后，倒转手机后，画面也会跟着倒过来
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
        _videoCamera.horizontallyMirrorRearFacingCamera = NO;
        
        //        //该句可防止允许声音通过的情况下，避免录制第一帧黑屏闪屏(====)
        //是否录制音频
        [_videoCamera addAudioInputsAndOutputs];
        //帧数
        //    _videoCamera.frameRate = (int32_t)32;
        
        //设备方向
        _videoCamera.outputImageOrientation =UIInterfaceOrientationPortrait;
        
        //  GPUImageOutput   继承GPUImageOutput且遵循GPUImageInput的filter，处理完成后输出又可以作为下一个filter的输入。
        // 作为最终的输出target只实现了GPUImageInput的协议，只能接受source或者filter传过来的数据，不再作为输出了；
        
//        GPUImageFilter和响应链的其他元素实现了GPUImageInput协议，他们都可以提供纹理参与响应链，或者从响应链的前面接收并处理纹理。响应链的下一个对象是target，响应链可能有多个分支（添加多个targets）。
        _viewGPUImageVideo = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kMinScreenWidth, kMinScreenHeight)];
        
        // Add the view somewhere so it's visible
        [self.view addSubview:_viewGPUImageVideo];
        [self.view insertSubview:_viewGPUImageVideo atIndex:0];
     

        
        
      
    }
    return _videoCamera;
}

#pragma mark- 初始化界面
-(void)initUI{

    WEAKSELF
    _butttonRecord =   [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalTitle(@"back");
        
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.size.mas_equalTo(CGSizeMake(50, 30));
        make.top.equalTo(self.view).offset(50);
        make.left.equalTo(self.view).offset(50);
    } withButtonBlock:^(CNMButton *button) {
        [weakSelf back];
    }];

    _butttonBeauty =  [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.backgroundColor = kColorWithRandom;
        button.butNormalTitle(@"美眼开");
        button.butSelectTitle(@"美眼关");
        button.butSelectTitleColor(kColorWithRandom);
        button.butNormalTitleColor(kWhiteColor);
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.size.mas_equalTo(CGSizeMake(60, 30));
        make.top.equalTo(self.view).offset(100);
        make.right.equalTo(self.view).offset(-30);
    } withButtonBlock:^(CNMButton *button) {
        button.selected = !button.selected;
        [weakSelf reloadFilter];
        
    }];
    
    _butttonRecord =   [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.backgroundColor = kColorWithRandom;
        button.butNormalTitle(@"录制");
        button.butSelectTitle(@"暂停");
        button.butSelectTitleColor(kColorWithRandom);
        button.butNormalTitleColor(kWhiteColor);
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.size.mas_equalTo(CGSizeMake(50, 30));
        make.top.equalTo(_butttonBeauty.mas_bottom).offset(50);
        make.right.equalTo(_butttonBeauty);
    } withButtonBlock:^(CNMButton *button) {
        button.selected = !button.selected;
        [weakSelf beginRecord];
    }];
    
    
    CNMButton* buttonDeleate =   [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.backgroundColor = kColorWithRandom;
         button.butNormalTitle(@"删除上一段");
         button.butNormalTitleColor(kWhiteColor);
     } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
         make.size.mas_equalTo(CGSizeMake(130, 30));
         make.top.equalTo(_butttonRecord.mas_bottom).offset(50);
         make.right.equalTo(_butttonRecord);
     } withButtonBlock:^(CNMButton *button) {
         button.selected = !button.selected;
         [weakSelf deleteLastVideo];
     }];
    
    _butttonRecordFinish =   [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.backgroundColor = kColorWithRandom;
        button.butNormalTitle(@"播放");
        button.butSelectTitleColor(kColorWithRandom);
        button.butNormalTitleColor(kWhiteColor);
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.size.mas_equalTo(CGSizeMake(50, 30));
        make.top.equalTo(buttonDeleate.mas_bottom).offset(50);
        make.right.equalTo(buttonDeleate);
    } withButtonBlock:^(CNMButton *button) {
        button.selected = !button.selected;
        [weakSelf playVideo];
    }];
    
    
    _butttonfilterView =   [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.backgroundColor = kColorWithRandom;
        button.butNormalTitle(@"滤镜");
        //             button.butSelectTitle(@"结束");
        button.butSelectTitleColor(kColorWithRandom);
        button.butNormalTitleColor(kWhiteColor);
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.size.mas_equalTo(CGSizeMake(50, 30));
        make.top.equalTo(_butttonRecordFinish.mas_bottom).offset(50);
        make.right.equalTo(_butttonRecordFinish);
    } withButtonBlock:^(CNMButton *button) {
        button.selected = !button.selected;
        [weakSelf filterViewAction];
    }];
    
    
    _butttonWaterView =   [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.backgroundColor = kColorWithRandom;
        button.butNormalTitle(@"水印开");
        button.butSelectTitle(@"水印关");
        //             button.butSelectTitle(@"结束");
        button.butSelectTitleColor(kColorWithRandom);
        button.butNormalTitleColor(kWhiteColor);
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.top.equalTo(_butttonfilterView.mas_bottom).offset(50);
        make.right.equalTo(_butttonfilterView);
    } withButtonBlock:^(CNMButton *button) {
        button.selected = !button.selected;
        [weakSelf waterViewAction];
    }];
    [weakSelf waterViewAction];
    
    
}
-(void)filterViewAction{
    
    self.filterView.hidden = !self.butttonfilterView;
    if (self.filterView.hidden) {
        _filterViewfilter = nil;
    }
}

#pragma mark- recordAction 删除上一段视频

- (void)deleteLastVideo {
    if (self.videoArray.count > 0) {
        if (self.videoDurationArray.count > 1) {
            [self.progressBgView deleteLastProgress:[self.videoDurationArray[self.videoDurationArray.count - 2] floatValue]];

        } else {
            [self.progressBgView deleteLastProgress:0];
        }
        [self.videoDurationArray removeLastObject];
        [self.videoArray removeLastObject];
    }
}
#pragma mark -开始录制
-(void)beginRecord{
    
    if (!self.writer.isRecording) {
         NSString *urlStr = [PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[NSString cnm_Date_geStringtCurrentTimes]]];
        self.writer = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:urlStr] size:CGSizeMake(720, 1280)];
        //影响expectsMediaDataInRealTime,YES时用于输入流是实时的，比如说摄像头
        self.writer.encodingLiveVideo = YES;
        
        //开启声音采集
        self.writer.hasAudioTrack = YES;
        self.videoCamera.audioEncodingTarget = self.writer;//加入声音
        self.writer.shouldPassthroughAudio = YES;//是否使用源音源

        [self.writer startRecording];
        [self.videoArray addObject:[NSURL fileURLWithPath:urlStr]];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(progressAction) userInfo:nil repeats:YES];
    }else{
        [self finishRecord];
        
        self.progressBgView.interval = 2;
        [self.videoDurationArray addObject:[NSString stringWithFormat:@"%f",self.progressBgView.progress]];
       
    }
}
#pragma mark -结束录制
- (void)finishRecord {

    [_timer invalidate];
    _timer = nil;
    [self.writer finishRecording];
    self.writer  = nil;
   

}
#pragma mark -播放录制的视频
- (void)playVideo {
    if (self.videoArray.count > 0) {
        if (self.writer.isRecording) {
            [self finishRecord];
            [self.videoDurationArray addObject:[NSString stringWithFormat:@"%f",self.progressBgView.progress]];
        }
        [[AVUtil shared] mergeAndExportVideosAtFileURLs:self.videoArray callBack:^(BOOL rs, NSObject *obj) {
            if (rs) {
                NSURL *url = (NSURL *)obj;
                AVPlayerViewController *playerCtl = [AVPlayerViewController new];
                playerCtl.videoUrl = url;
                [self.navigationController pushViewController:playerCtl animated:YES];
            }
        }];

    }
}
#pragma mark- 更新滤镜
-(void)reloadFilter{

    [self.filterViewfilter removeAllTargets];
    [self.videoCamera removeAllTargets];
    [self.filter removeAllTargets];
    [self.output removeAllTargets];
    [self.filterGroup removeAllTargets];
    [self.blendFilter removeAllTargets];
    [self.uiElementInput removeAllTargets];
    
    
    _filterGroup = [[GPUImageFilterGroup alloc] init];

    if (_butttonBeauty.selected) {
        //不美颜，创建一个空的GPUImageFilter
        self.filter = (LFGPUImageBeautyFilter*)[[GPUImageFilter alloc ]init];

    }else{
        //创建一个用需要使用的美颜滤镜等的filter,当然self.filter也继承自GPUImageOutput也可作为输出filter
        self.filter = (LFGPUImageBeautyFilter*)[[LFGPUImageBeautyFilter  alloc ]init];
        self.filter.beautyLevel  = 0.9f;
        self.filter.brightLevel = 0.8f;
        self.filter.toneLevel = 0.8f;
    }


    //美颜加入到滤镜组
    [self addGPUImageFilter:self.filter];

    //滤镜加入到滤镜组
    if (self.filterViewfilter) {
        [self addGPUImageFilter:_filterViewfilter];
    }

    //添加水印
    if (_waterMarkContentView) {
        //混合filter加入到滤镜组
        [self addGPUImageFilter:self.blendFilter];
        //讲UIView对象转换成纹理对象加入到混合filter中
        [self.uiElementInput addTarget:self.blendFilter];
    }
    
    //相机画面添加到filter流
    [self.videoCamera addTarget:self.filterGroup];

    //创建一个用输出的Filter
     self.output = [[GPUImageFilter alloc ]init];

    //filter流用output输出
    [self.filterGroup addTarget:self.output];
    //    当然filter也可以直接输出到view上，为了output输出带美颜的视频流
    //  [self.filter addTarget:_viewGPUImageVideo];//美颜filter作为流输出

    [self.output addTarget:_viewGPUImageVideo];//美颜filter流通过outputs输出到预览层

    WEAKSELF
    [self.output setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [weakSelf.uiElementInput update];
        [weakSelf tellUpVideoGPUImageBuffer:output.framebufferForOutput];
        [weakSelf newFrameReadyAtTime:time atIndex:0];

    }];


}
//滤镜组
- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    [_filterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = _filterGroup.filterCount;
    
    if (count == 1)
    {
        _filterGroup.initialFilters = @[newTerminalFilter];
        _filterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = _filterGroup.terminalFilter;
        NSArray *initialFilters                          = _filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        _filterGroup.initialFilters = @[initialFilters[0]];
        _filterGroup.terminalFilter = newTerminalFilter;
    }
}
#pragma mark- 滤镜视图
- (void)filterViewShow {
    self.filterView.hidden = NO;
}

- (FilterTypeView *)filterView {
    if (!_filterView) {
        _filterView = [[FilterTypeView alloc] initWithFrame:CGRectMake(0, kMinScreenHeight - 105, kMinScreenWidth, 105)];
        __weak typeof(self) weakSelf = self;
        _filterView.filterBlock = ^(NSString *filterClass) {
            weakSelf.filterViewfilter = [[NSClassFromString(filterClass) alloc] init];
            [weakSelf reloadFilter];
        };
        [self.view addSubview:_filterView];
    }
    return _filterView;
}



#pragma mark - 水印
-(void)waterViewAction{
    
    if (!_butttonWaterView.selected) {
        UIView*viewWater = [[UIView alloc]initWithFrame:CGRectMake(0, kMinScreenHeight-100, 100, 100)];
          viewWater.backgroundColor = [UIColor redColor];
          UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
          imageView.image = [UIImage imageNamed:@"logo"];
          [viewWater addSubview:imageView];
          [self.waterMarkContentView addSubview:viewWater];
        self.blendFilter.mix = 0.5f;
        
    }else{
        [self.waterMarkContentView removeFromSuperview];
        self.waterMarkContentView = nil;
    }
  
    
    [self reloadFilter];
}
- (GPUImageUIElement *)uiElementInput{
    if(!_uiElementInput){
        _uiElementInput = [[GPUImageUIElement alloc] initWithView:self.waterMarkContentView];
    }
    return _uiElementInput;
}

- (GPUImageAlphaBlendFilter *)blendFilter{
    if(!_blendFilter){
        //两个帧缓存对象的输入合并成一个帧缓存对象的输出
        _blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
        _blendFilter.mix = 1.0;
        // 如果不检查第一个纹理输入，则直接默认已经接收了第一个纹理
        //检查第二个纹理输入
        [_blendFilter disableSecondFrameCheck];
    }
    return _blendFilter;
}
- (UIView *)waterMarkContentView{
    if(!_waterMarkContentView){
        _waterMarkContentView = [UIView new];
        _waterMarkContentView.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height);        _waterMarkContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _waterMarkContentView;
}
-(void)tellUpVideoGPUImageBuffer:(GPUImageFramebuffer *)buffer{
    [_writer setInputSize:buffer.size atIndex:0];
    [_writer setInputFramebuffer:buffer atIndex:0];
    [_writer newFrameReadyAtTime:CMTimeMake((CACurrentMediaTime()*20), 20) atIndex:0];
}
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex{
    
}
static CGFloat maxDuration = 15;
static CGFloat timeInterval = 1/30.f;

#pragma mark- 进度条
- (void)progressAction {
    self.progressBgView.progress += timeInterval/maxDuration;
    if (self.progressBgView.progress >= 1) {
        [self finishRecord];
        [self.videoDurationArray addObject:@"1.0"];
    }
}

- (UIView *)progressBgView {
    if (!_progressBgView) {
        _progressBgView = [[AVProgressView alloc] initWithFrame:CGRectMake(0, 20, kMinScreenWidth, 10)];
        _progressBgView.backgroundColor = kColorWithHex(@"e8e8e8");
        [_viewGPUImageVideo  addSubview:_progressBgView];
        
    }
    return _progressBgView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc_______");
}
-(void)back{
    if (_timer) {
          [_timer invalidate];
          _timer = nil;
      }
    [_writer cancelRecording];
    _writer  = nil;
    [_videoCamera stopCameraCapture];
    _videoCamera = nil;
    [_filterView removeFromSuperview];
    _filterView = nil;
    [self.navigationController popViewControllerAnimated:YES];
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
