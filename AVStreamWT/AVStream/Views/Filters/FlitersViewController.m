//
//  FlitersViewController.m
//  AVStream
//
//  Created by R on 2018/4/27.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import "FlitersViewController.h"
#import "FilterTypeView.h"
#import "AVProgressView.h"
#import "AVPlayerViewController.h"
#import "AVUtil.h"
#import "AVPhotoViewController.h"

#define PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject

@interface FlitersViewController ()
{
    NSTimer *_timer;
}
@property (nonatomic, strong) FilterTypeView *filterView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) NSMutableArray *videoArray;//存放视频URL
@property (nonatomic, strong) NSMutableArray *videoDurationArray;//存放每一段视频的进度
@property (nonatomic, strong) AVProgressView *progressBgView;

@end

@implementation FlitersViewController

static CGFloat maxDuration = 15;
static CGFloat timeInterval = 1/30.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCamera];
    
    [self setupUI];
}

- (void)initCamera {
    //初始化相机,参数一:采集质量  参数二:前后置摄像头
    self.camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    //相机竖屏
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //该句可防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
    [self.camera addAudioInputsAndOutputs];
    //初始化一个滤镜
    self.filter = [[GPUImageFilter alloc] init];
    //初始化GPUImageView
    self.imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, kMinScreenWidth, kMinScreenHeight)];
    //相机上添加滤镜
    [self.camera addTarget:self.filter];
    //滤镜添加imageView
    [self.filter addTarget:self.imageView];
    [self.view addSubview:self.imageView];
    //开始捕捉
    [self.camera startCameraCapture];
}

- (void)setupUI {
    self.navigationItem.title = @"相机";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"滤镜" style:UIBarButtonItemStylePlain target:self action:@selector(filterViewShow)];
    [self.view addSubview:self.progressBgView];
    self.videoArray = [NSMutableArray new];
    self.videoDurationArray = [NSMutableArray new];
    __weak typeof(self) weakSelf = self;

    [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalTitle(@"录制");
        button.butSelectTitle(@"暂停");
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.bottom.equalTo(self.view).offset(-30);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    } withButtonBlock:^(CNMButton *button) {

        [weakSelf recordVideo:button];
        
    }];

    [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalTitle(@"删除上一段视频");
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.bottom.equalTo(self.view).offset(-130);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(140, 40));
    } withButtonBlock:^(CNMButton *button) {
        [weakSelf deleteLastVideo];
    }];

    [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalTitle(@"播放");
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.bottom.equalTo(self.view).offset(-80);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(140, 40));
    } withButtonBlock:^(CNMButton *button) {
        [weakSelf playVideo];
    }];
    
    [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalImageName(@"video_reCamra");
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.top.equalTo(self.view).offset(100);
        make.right.equalTo(self.view).offset(-20);
    } withButtonBlock:^(CNMButton *button) {
        [weakSelf.camera rotateCamera];
    }];
    
    [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalTitle(@"拍摄");
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.top.equalTo(self.view).offset(180);
        make.right.equalTo(self.view).offset(-20);
    } withButtonBlock:^(CNMButton *button) {
       
        [weakSelf.camera capturePhotoAsPNGProcessedUpToFilter:weakSelf.filter withCompletionHandler:^(NSData *processedPNG, NSError *error) {
            NSLog(@"拍摄成功");
            AVPhotoViewController *ctl = [[AVPhotoViewController alloc] init];
            ctl.imageData = processedPNG;
            [self.navigationController pushViewController:ctl animated:NO];
            
        }];
    }];

}

#pragma mark- 录制 删除 播放
- (void)recordVideo:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        NSString *urlStr = [PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[NSString cnm_Date_geStringtCurrentTimes]]];
        self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:urlStr] size:CGSizeMake(720, 1280)];
        //影响expectsMediaDataInRealTime,YES时用于输入流是实时的，比如说摄像头
        self.movieWriter.encodingLiveVideo = YES;
        [self.filter addTarget:self.movieWriter];
        //表示音频来源是文件
        self.camera.audioEncodingTarget = self.movieWriter;
        [self.movieWriter startRecording];
        [self.videoArray addObject:[NSURL fileURLWithPath:urlStr]];

        _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(progressAction) userInfo:nil repeats:YES];
    } else {

        [self finishRecord];

        self.progressBgView.interval = 2;
        [self.videoDurationArray addObject:[NSString stringWithFormat:@"%f",self.progressBgView.progress]];
    }
}

- (void)finishRecord {

    [_timer invalidate];
    _timer = nil;

    [self.movieWriter finishRecording];
    self.camera.audioEncodingTarget = nil;
    [self.filter removeTarget:self.movieWriter];
    self.movieWriter = nil;

}

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

- (void)playVideo {
    if (self.videoArray.count > 0) {
        if (self.movieWriter.isRecording) {
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
        _progressBgView = [[AVProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 10)];
        _progressBgView.backgroundColor = kColorWithHex(@"e8e8e8");
    }
    return _progressBgView;
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
            //移除原先滤镜
            [weakSelf.filter removeTarget:weakSelf.imageView];
            [weakSelf.camera removeTarget:weakSelf.filter];

            //添加新的滤镜
            weakSelf.filter = [[NSClassFromString(filterClass) alloc] init];
            [weakSelf.camera addTarget:weakSelf.filter];
            [weakSelf.filter addTarget:weakSelf.imageView];
        };
        [self.view addSubview:_filterView];
    }
    return _filterView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)dealloc {
    NSLog(@"%@------dealloc",[self class]);
}


/**
 使用GPUImage加载水印
 
 @param vedioPath 视频路径
 @param img 水印图片
 @param coverImg 水印图片二
 @param question 字符串水印
 @param fileName 生成之后的视频名字
 */
/*
-(void)saveVedioPath:(NSURL*)vedioPath WithWaterImg:(UIImage*)img WithCoverImage:(UIImage*)coverImg WithQustion:(NSString*)question WithFileName:(NSString*)fileName
{
    filter = [[GPUImageNormalBlendFilter alloc] init];
    
    NSURL *sampleURL  = vedioPath;
    AVAsset *asset = [AVAsset assetWithURL:sampleURL];
    CGSize size = asset.naturalSize;
    
    movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    movieFile.playAtActualSpeed = NO;
    
    // 文字水印
    UILabel *label = [[UILabel alloc] init];
    label.text = question;
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor whiteColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label sizeToFit];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 18.0f;
    [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [label setFrame:CGRectMake(50, 100, label.frame.size.width+20, label.frame.size.height)];
    
    //图片水印
    UIImage *coverImage1 = [img copy];
    UIImageView *coverImageView1 = [[UIImageView alloc] initWithImage:coverImage1];
    [coverImageView1 setFrame:CGRectMake(0, 100, 210, 50)];
    
    //第二个图片水印
    UIImage *coverImage2 = [coverImg copy];
    UIImageView *coverImageView2 = [[UIImageView alloc] initWithImage:coverImage2];
    [coverImageView2 setFrame:CGRectMake(270, 100, 210, 50)];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    
    [subView addSubview:coverImageView1];
    [subView addSubview:coverImageView2];
    [subView addSubview:label];
    
    
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4",fileName]];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [progressFilter addTarget:filter];
    [movieFile addTarget:progressFilter];
    [uielement addTarget:filter];
    movieWriter.shouldPassthroughAudio = YES;
    //    movieFile.playAtActualSpeed = true;
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
        movieFile.audioEncodingTarget = movieWriter;
    } else {//no audio
        movieFile.audioEncodingTarget = nil;
    }
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    // 显示到界面
    [filter addTarget:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    
    __weak typeof(self) weakSelf = self;
    //渲染
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        //水印可以移动
        CGRect frame = coverImageView1.frame;
        frame.origin.x += 1;
        frame.origin.y += 1;
        coverImageView1.frame = frame;
        //第5秒之后隐藏coverImageView2
        if (time.value/time.timescale>=5.0) {
            [coverImageView2 removeFromSuperview];
        }
        [uielement update];
        
    }];
    //保存相册
    [movieWriter setCompletionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf->filter removeTarget:strongSelf->movieWriter];
            [strongSelf->movieWriter finishRecording];
            __block PHObjectPlaceholder *placeholder;
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie))
            {
                NSError *error;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
                    placeholder = [createAssetRequest placeholderForCreatedAsset];
                } error:&error];
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error]];
                }
                else{
                    [SVProgressHUD showSuccessWithStatus:@"视频已经保存到相册"];
                }
            }
        });
    }];
}
*/


/*
 #pragma mark - 调整颜色 Handle Color
 
 #import "GPUImageBrightnessFilter.h"                //亮度
 #import "GPUImageExposureFilter.h"                  //曝光
 #import "GPUImageContrastFilter.h"                  //对比度
 #import "GPUImageSaturationFilter.h"                //饱和度
 #import "GPUImageGammaFilter.h"                     //伽马线
 #import "GPUImageColorInvertFilter.h"               //反色
 #import "GPUImageSepiaFilter.h"                     //褐色（怀旧）
 #import "GPUImageLevelsFilter.h"                    //色阶
 #import "GPUImageGrayscaleFilter.h"                 //灰度
 #import "GPUImageHistogramFilter.h"                 //色彩直方图，显示在图片上
 #import "GPUImageHistogramGenerator.h"              //色彩直方图
 #import "GPUImageRGBFilter.h"                       //RGB
 #import "GPUImageToneCurveFilter.h"                 //色调曲线
 #import "GPUImageMonochromeFilter.h"                //单色
 #import "GPUImageOpacityFilter.h"                   //不透明度
 #import "GPUImageHighlightShadowFilter.h"           //提亮阴影
 #import "GPUImageFalseColorFilter.h"                //色彩替换（替换亮部和暗部色彩）
 #import "GPUImageHueFilter.h"                       //色度
 #import "GPUImageChromaKeyFilter.h"                 //色度键
 #import "GPUImageWhiteBalanceFilter.h"              //白平横
 #import "GPUImageAverageColor.h"                    //像素平均色值
 #import "GPUImageSolidColorGenerator.h"             //纯色
 #import "GPUImageLuminosity.h"                      //亮度平均
 #import "GPUImageAverageLuminanceThresholdFilter.h" //像素色值亮度平均，图像黑白（有类似漫画效果）
 
 #import "GPUImageLookupFilter.h"                    //lookup 色彩调整
 #import "GPUImageAmatorkaFilter.h"                  //Amatorka lookup
 #import "GPUImageMissEtikateFilter.h"               //MissEtikate lookup
 #import "GPUImageSoftEleganceFilter.h"              //SoftElegance lookup
 
 
 
 
 #pragma mark - 图像处理 Handle Image
 
 #import "GPUImageCrosshairGenerator.h"              //十字
 #import "GPUImageLineGenerator.h"                   //线条
 
 #import "GPUImageTransformFilter.h"                 //形状变化
 #import "GPUImageCropFilter.h"                      //剪裁
 #import "GPUImageSharpenFilter.h"                   //锐化
 #import "GPUImageUnsharpMaskFilter.h"               //反遮罩锐化
 
 #import "GPUImageFastBlurFilter.h"                  //模糊
 #import "GPUImageGaussianBlurFilter.h"              //高斯模糊
 #import "GPUImageGaussianSelectiveBlurFilter.h"     //高斯模糊，选择部分清晰
 #import "GPUImageBoxBlurFilter.h"                   //盒状模糊
 #import "GPUImageTiltShiftFilter.h"                 //条纹模糊，中间清晰，上下两端模糊
 #import "GPUImageMedianFilter.h"                    //中间值，有种稍微模糊边缘的效果
 #import "GPUImageBilateralFilter.h"                 //双边模糊
 #import "GPUImageErosionFilter.h"                   //侵蚀边缘模糊，变黑白
 #import "GPUImageRGBErosionFilter.h"                //RGB侵蚀边缘模糊，有色彩
 #import "GPUImageDilationFilter.h"                  //扩展边缘模糊，变黑白
 #import "GPUImageRGBDilationFilter.h"               //RGB扩展边缘模糊，有色彩
 #import "GPUImageOpeningFilter.h"                   //黑白色调模糊
 #import "GPUImageRGBOpeningFilter.h"                //彩色模糊
 #import "GPUImageClosingFilter.h"                   //黑白色调模糊，暗色会被提亮
 #import "GPUImageRGBClosingFilter.h"                //彩色模糊，暗色会被提亮
 #import "GPUImageLanczosResamplingFilter.h"         //Lanczos重取样，模糊效果
 #import "GPUImageNonMaximumSuppressionFilter.h"     //非最大抑制，只显示亮度最高的像素，其他为黑
 #import "GPUImageThresholdedNonMaximumSuppressionFilter.h" //与上相比，像素丢失更多
 
 #import "GPUImageSobelEdgeDetectionFilter.h"        //Sobel边缘检测算法(白边，黑内容，有点漫画的反色效果)
 #import "GPUImageCannyEdgeDetectionFilter.h"        //Canny边缘检测算法（比上更强烈的黑白对比度）
 #import "GPUImageThresholdEdgeDetectionFilter.h"    //阈值边缘检测（效果与上差别不大）
 #import "GPUImagePrewittEdgeDetectionFilter.h"      //普瑞维特(Prewitt)边缘检测(效果与Sobel差不多，貌似更平滑)
 #import "GPUImageXYDerivativeFilter.h"              //XYDerivative边缘检测，画面以蓝色为主，绿色为边缘，带彩色
 #import "GPUImageHarrisCornerDetectionFilter.h"     //Harris角点检测，会有绿色小十字显示在图片角点处
 #import "GPUImageNobleCornerDetectionFilter.h"      //Noble角点检测，检测点更多
 #import "GPUImageShiTomasiFeatureDetectionFilter.h" //ShiTomasi角点检测，与上差别不大
 #import "GPUImageMotionDetector.h"                  //动作检测
 #import "GPUImageHoughTransformLineDetector.h"      //线条检测
 #import "GPUImageParallelCoordinateLineTransformFilter.h" //平行线检测
 
 #import "GPUImageLocalBinaryPatternFilter.h"        //图像黑白化，并有大量噪点
 
 #import "GPUImageLowPassFilter.h"                   //用于图像加亮
 #import "GPUImageHighPassFilter.h"                  //图像低于某值时显示为黑
 
 
 #pragma mark - 视觉效果 Visual Effect
 
 #import "GPUImageSketchFilter.h"                    //素描
 #import "GPUImageThresholdSketchFilter.h"           //阀值素描，形成有噪点的素描
 #import "GPUImageToonFilter.h"                      //卡通效果（黑色粗线描边）
 #import "GPUImageSmoothToonFilter.h"                //相比上面的效果更细腻，上面是粗旷的画风
 #import "GPUImageKuwaharaFilter.h"                  //桑原(Kuwahara)滤波,水粉画的模糊效果；处理时间比较长，慎用
 
 #import "GPUImageMosaicFilter.h"                    //黑白马赛克
 #import "GPUImagePixellateFilter.h"                 //像素化
 #import "GPUImagePolarPixellateFilter.h"            //同心圆像素化
 #import "GPUImageCrosshatchFilter.h"                //交叉线阴影，形成黑白网状画面
 #import "GPUImageColorPackingFilter.h"              //色彩丢失，模糊（类似监控摄像效果）
 
 #import "GPUImageVignetteFilter.h"                  //晕影，形成黑色圆形边缘，突出中间图像的效果
 #import "GPUImageSwirlFilter.h"                     //漩涡，中间形成卷曲的画面
 #import "GPUImageBulgeDistortionFilter.h"           //凸起失真，鱼眼效果
 #import "GPUImagePinchDistortionFilter.h"           //收缩失真，凹面镜
 #import "GPUImageStretchDistortionFilter.h"         //伸展失真，哈哈镜
 #import "GPUImageGlassSphereFilter.h"               //水晶球效果
 #import "GPUImageSphereRefractionFilter.h"          //球形折射，图形倒立
 
 #import "GPUImagePosterizeFilter.h"                 //色调分离，形成噪点效果
 #import "GPUImageCGAColorspaceFilter.h"             //CGA色彩滤镜，形成黑、浅蓝、紫色块的画面
 #import "GPUImagePerlinNoiseFilter.h"               //柏林噪点，花边噪点
 #import "GPUImage3x3ConvolutionFilter.h"            //3x3卷积，高亮大色块变黑，加亮边缘、线条等
 #import "GPUImageEmbossFilter.h"                    //浮雕效果，带有点3d的感觉
 #import "GPUImagePolkaDotFilter.h"                  //像素圆点花样
 #import "GPUImageHalftoneFilter.h"                  //点染,图像黑白化，由黑点构成原图的大致图形
 
 
 #pragma mark - 混合模式 Blend
 
 #import "GPUImageMultiplyBlendFilter.h"             //通常用于创建阴影和深度效果
 #import "GPUImageNormalBlendFilter.h"               //正常
 #import "GPUImageAlphaBlendFilter.h"                //透明混合,通常用于在背景上应用前景的透明度
 #import "GPUImageDissolveBlendFilter.h"             //溶解
 #import "GPUImageOverlayBlendFilter.h"              //叠加,通常用于创建阴影效果
 #import "GPUImageDarkenBlendFilter.h"               //加深混合,通常用于重叠类型
 #import "GPUImageLightenBlendFilter.h"              //减淡混合,通常用于重叠类型
 #import "GPUImageSourceOverBlendFilter.h"           //源混合
 #import "GPUImageColorBurnBlendFilter.h"            //色彩加深混合
 #import "GPUImageColorDodgeBlendFilter.h"           //色彩减淡混合
 #import "GPUImageScreenBlendFilter.h"               //屏幕包裹,通常用于创建亮点和镜头眩光
 #import "GPUImageExclusionBlendFilter.h"            //排除混合
 #import "GPUImageDifferenceBlendFilter.h"           //差异混合,通常用于创建更多变动的颜色
 #import "GPUImageSubtractBlendFilter.h"             //差值混合,通常用于创建两个图像之间的动画变暗模糊效果
 #import "GPUImageHardLightBlendFilter.h"            //强光混合,通常用于创建阴影效果
 #import "GPUImageSoftLightBlendFilter.h"            //柔光混合
 #import "GPUImageChromaKeyBlendFilter.h"            //色度键混合
 #import "GPUImageMaskFilter.h"                      //遮罩混合
 #import "GPUImageHazeFilter.h"                      //朦胧加暗
 #import "GPUImageLuminanceThresholdFilter.h"        //亮度阈
 #import "GPUImageAdaptiveThresholdFilter.h"         //自适应阈值
 #import "GPUImageAddBlendFilter.h"                  //通常用于创建两个图像之间的动画变亮模糊效果
 #import "GPUImageDivideBlendFilter.h"               //通常用于创建两个图像之间的动画变暗模糊效果
 */

@end
