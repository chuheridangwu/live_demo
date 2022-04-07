//
//  DeerPushViewModel.m
//  DeerLive
//
//  Created by 鹿容 on 2019/6/26.
//  Copyright © 2019 Deer. All rights reserved.
//

#import "DeerPushViewModel.h"

//#import <LFLiveKit/LFLiveKit.h>
#import "LFLiveKit.h"
#import <WT_Camera/WT_Camera.h>

#import <GPUImage/GPUImage.h>

//#import <SSZipArchive/SSZipArchive.h>

#import <objc/runtime.h>

time_t time(time_t* t)
{
    if (t) {
        *t = (time_t)[NSDate date].timeIntervalSince1970;
        return *t;
    }
    return (time_t)[NSDate date].timeIntervalSince1970;
}






@interface MyWTCamera : WT_Camera
{
    NSString *_jsonString;
    NSString *_picPath;
}

@end

@implementation WTGPUImageContext


@end
@implementation MyWTCamera

- (void)drawGifWithJson:(NSString *)arg1 isInMainBundle:(BOOL)arg2 PicFolder:(NSString *)arg3
{
    _jsonString = arg1.copy;
    _picPath = arg3.copy;
    [super drawGifWithJson:arg1 isInMainBundle:arg2 PicFolder:arg3];
}


- (void)drawWithPhotoDict:(NSMutableDictionary *)arg1
{
    NSString *jsonString = [NSString stringWithContentsOfFile:_jsonString encoding:NSUTF8StringEncoding error:nil];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\\" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSArray *array = dict[@"KEY_MODULE_SET"];
    for (NSDictionary *dd in array) {
        if ([arg1[@"PHOTO_NAME"] isEqualToString:dd[@"PHOTO_NAME"]]) {
            arg1[@"PHOTOS_DATA_SET"] = dd[@"PHOTOS_DATA_SET"];
        }
    }
    [super drawWithPhotoDict:arg1];
}

@end


@interface DeerPushViewModel ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    LFLiveSession *_liveSession;
    MyWTCamera *_camera;
    
    dispatch_semaphore_t _frameRenderingSemaphore;
    dispatch_queue_t _cameraProcessingQueue;
    
    CVPixelBufferRef _currentPixel;
    
    BOOL _isPaused;
    
}
@property(readonly, retain, nonatomic) AVCaptureSession *captureSession;
@property(nonatomic) AVCaptureDeviceInput *videoInput;
@property(nonatomic) AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic) AVCaptureAudioDataOutput *audioOutput;
@property(nonatomic) AVCaptureDevice *videoDevice;

@end

@implementation DeerPushViewModel

@synthesize preView = _preView;
@synthesize captureDevicePosition = _captureDevicePosition;

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!self.captureSession.isRunning)
    {
        return;
    }
    else if (captureOutput == _videoOutput)
    {
        
        if(!_captureSession)
        {
            return;
        }
        if (_isPaused) {
            return;
        }
        if (!CMSampleBufferIsValid(sampleBuffer) || !sampleBuffer) {
            return;
        }
        
        CVPixelBufferRef WT_PixelBuffer = [_camera processSampleBufferInput:sampleBuffer];
        if (_currentPixel) {
            CVPixelBufferRelease(_currentPixel);
            _currentPixel = nil;
        }
        _currentPixel = WT_PixelBuffer;
        CVPixelBufferRetain(_currentPixel);
        if (self.onPixelBuffer) {
        self.onPixelBuffer(_currentPixel,CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
        }
        
        [_liveSession pushVideo:WT_PixelBuffer];
        
    }
}


- (void)willEnterBackground:(NSNotification *)notification {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)willEnterForeground:(NSNotification *)notification {
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(UIImage *)currentImage
{
    if (_currentPixel) {
        UIImage *image = [UIImage imageWithCIImage:[CIImage imageWithCVPixelBuffer:_currentPixel]];
        return image;
    }
    return nil;
}

-(void)changeToSmall:(BOOL)isSmall
{
    CGSize size = CGSizeMake(432, 768);
    if (isSmall) {
        size = CGSizeMake(16 *9 *2, 16 * 16 * 2);
    }
//    dispatch_sync(_cameraProcessingQueue, ^{
//        [_camera resizeGPU:size];
//    });
    [self runSynchronouslyblock:^{
        [_camera resizeGPU:size];
    }];
}

-(void)startCapture
{
    if (!_camera) {
        
        self.fps = 20;
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
        _liveSession.audioCaptureSource.running = YES;

        
        _frameRenderingSemaphore = dispatch_semaphore_create(1);
        
        
        _cameraProcessingQueue = dispatch_queue_create("video", NULL);
        
        _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
        
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession beginConfiguration];
        
        NSError *error = nil;
        
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
        
        if (!_videoInput) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        
        if ([_captureSession canAddInput:_videoInput])
        {
            [_captureSession addInput:_videoInput];
        }
        
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setAlwaysDiscardsLateVideoFrames:NO];
        
        [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        
        
        AVCaptureConnection *captureConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoOrientationSupported]) {
            captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        [_videoOutput setSampleBufferDelegate:self queue:_cameraProcessingQueue];
        if ([_captureSession canAddOutput:_videoOutput])
        {
            [_captureSession addOutput:_videoOutput];
        }
        else
        {
            NSLog(@"Couldn't add video output");
        }
        
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
        //            [_captureSession setSessionPreset:AVCaptureSessionPresetiFrame960x540];
        
        
        [_captureSession commitConfiguration];
        
        [UIImage imageNamed:@""];
        [UIImage imageWithContentsOfFile:@""];
        [[NSBundle mainBundle] pathForResource:@"" ofType:@""];
        
        [WT2Tools changeMethodWithModel:[NSBundle class] sel:@selector(bundleIdentifier) newSel:@selector(WT_Bundle)];
        [WT2Tools changeMethodWithModel:[NSBundle class] sel:@selector(infoDictionary) newSel:@selector(WT_infoDictionary)];
        [WT2Tools changeMethodWithModel:[NSDate class] sel:@selector(timeIntervalSince1970) newSel:@selector(timeIntervalSince1970A)];
        [WT2Tools changeStaticMethodWithModel:[NSDate class] sel:@selector(date) newSel:@selector(dateA)];
        
        
        if (!_camera) {
            _camera = [[MyWTCamera alloc] initWithFrame:[UIScreen mainScreen].bounds CamResolution:CamResolution1280x720 ProcessSize:CGSizeMake(432, 768)];
            //                [_camera requestForAuthorization:@"-968174656,-93406956,-631386373"];
            
        }
        
        
        
        [_camera requestForAuthorization:@"806657876,1549138301,2081837424"];
//        [_camera resizeGPU:videoConfiguration.videoSize];
        
        [WT2Tools changeMethodWithModel:[NSBundle class] sel:@selector(bundleIdentifier) newSel:@selector(WT_Bundle)];
        [WT2Tools changeMethodWithModel:[NSBundle class] sel:@selector(infoDictionary) newSel:@selector(WT_infoDictionary)];
        [WT2Tools changeMethodWithModel:[NSDate class] sel:@selector(timeIntervalSince1970) newSel:@selector(timeIntervalSince1970A)];
        [WT2Tools changeStaticMethodWithModel:[NSDate class] sel:@selector(date) newSel:@selector(dateA)];
        
        [self setFrameRate:self.fps];
        
        [_camera styleAlpha:.5];
        
        self.mirrorPushStream = NO;
        
        [_camera giveYourSession:_captureSession];
        
        self.captureDevicePosition = AVCaptureDevicePositionFront;
        
        self.muted = NO;
        
        [self loadData];
        [self changeToSmall:NO];
    }
    
    
    
    if (!_captureSession.isRunning) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        AVCaptureDevice *device = nil;
        
        device = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:self.captureDevicePosition];
        
        NSError *error = nil;
        AVCaptureDeviceInput *newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        
        if (newVideoInput) {
            [_captureSession beginConfiguration];
            [_captureSession removeInput:_videoInput];
            if ([_captureSession canAddInput:newVideoInput]) {
                [_captureSession addInput:newVideoInput];
                _videoInput = newVideoInput;
            }else{
                [_captureSession addInput:_videoInput];
            }
            [_captureSession commitConfiguration];
            _videoDevice = device;
            //        return YES;
        }
        [_captureSession startRunning];
        _isPaused = NO;
    }
}

-(void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition
{
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count]<2) {
        //        return NO;
        return;
    }
    if (_captureDevicePosition == captureDevicePosition) {
        return;
    }
    _captureDevicePosition = captureDevicePosition;
    [_camera rotateCam:captureDevicePosition];
    if (captureDevicePosition == AVCaptureDevicePositionFront) {
        self.torch = NO;
    }
    
    AVCaptureDevice *device = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:captureDevicePosition];
    
    NSError *error = nil;
    AVCaptureDeviceInput *newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (newVideoInput) {
        [_captureSession beginConfiguration];
        [_captureSession removeInput:_videoInput];
        if ([_captureSession canAddInput:newVideoInput]) {
            [_captureSession addInput:newVideoInput];
            _videoInput = newVideoInput;
        }else{
            [_captureSession addInput:_videoInput];
        }
        [_captureSession commitConfiguration];
        _videoDevice = device;
        //        return YES;
    }else{
        //        return NO;
    }
    
    [self setFrameRate:self.fps];
    
}

-(AVCaptureDevicePosition)captureDevicePosition
{
    return _captureDevicePosition;
}

-(void)stopCaptue
{
    if (!_captureSession.isRunning) {
        return;
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [_captureSession stopRunning];
    Ivar ivar = class_getInstanceVariable(_camera.mainView.class, @"displayProgram".UTF8String);
    [NSClassFromString(@"WTGPUImageContext") setActiveShaderProgram:object_getIvar(_camera.mainView, ivar)];
    glClearColor(0, 0, 0, 0);
}

-(void)setMuted:(BOOL)muted
{
    _liveSession.muted = muted;
}

-(BOOL)muted
{
//    return 0;
    return _liveSession.muted;
}

-(void)setFilterImage:(UIImage *)filterImage
{
    _filterImage = filterImage;
    [_camera addStyle:filterImage];
}

-(void)setFilterAlpha:(CGFloat)filterAlpha
{
    _filterAlpha = filterAlpha;
    [_camera styleAlpha:_filterAlpha];
}

-(void)setEffectPath:(NSString *)effectPath
{
    _effectPath = effectPath.copy;
    
    if (!_effectPath) {
        [_camera cleanCurrentGIF];
        return;
    }
    
    [self getIndexJsonPathWithZipPath:_effectPath callBack:^(NSString *path) {
        [self startEffectWithPath:path times:0];
    }];
    
}

-(void)startEffectWithPath:(NSString *)effectPath times:(int)showTimes
{
    if (effectPath) {
        
        [WT2Tools changeMethodWithModel:[NSBundle class] sel:@selector(bundleIdentifier) newSel:@selector(WT_Bundle)];
        [WT2Tools changeMethodWithModel:[NSBundle class] sel:@selector(infoDictionary) newSel:@selector(WT_infoDictionary)];
        [WT2Tools changeStaticMethodWithModel:[NSDate class] sel:@selector(date) newSel:@selector(dateA)];
        
        if (!effectPath || ![[NSFileManager defaultManager] fileExistsAtPath:effectPath]) {
            [_camera cleanCurrentGIF];
        }else
        {
            [_camera drawGifWithJson:effectPath isInMainBundle:NO PicFolder:
             [effectPath stringByReplacingOccurrencesOfString:@"/index.json" withString:@""]
             ];
        }
        
        [WT2Tools changeMethodWithModel:[NSBundle class] sel:@selector(bundleIdentifier) newSel:@selector(WT_Bundle)];
        [WT2Tools changeMethodWithModel:[NSBundle class] sel:@selector(infoDictionary) newSel:@selector(WT_infoDictionary)];
        [WT2Tools changeStaticMethodWithModel:[NSDate class] sel:@selector(date) newSel:@selector(dateA)];
        
        if (showTimes == 1) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doPlayEnd) object:nil];
            [self performSelector:@selector(doPlayEnd) withObject:nil afterDelay:3 inModes:@[NSRunLoopCommonModes]];
        }
        
    }
}

-(void)doPlayEnd
{
    
}

-(NSString *)getIndexJsonPathWithZipPath:(NSString *)zipPath callBack:(void (^)(NSString *path))callBack
{
    NSString *toPath = [zipPath stringByReplacingOccurrencesOfString:@".zip" withString:@"EFFECT_JOSN"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        toPath = [toPath stringByAppendingString:@"/index.json"];
        //        [toPath retain];
        callBack(toPath);
        return toPath;
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:nil];
//    [SSZipArchive unzipFileAtPath:zipPath toDestination:toPath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
//        
//    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nonnull error) {
//        if (succeeded) {
//            callBack([path stringByReplacingOccurrencesOfString:@".zip" withString:@"EFFECT_JOSN/index.json"]);
//        }else
//        {
//            callBack(nil);
//        }
//    }];
    
    return nil;
}

-(void)setCoverImage:(UIImage *)coverImage
{
    _coverImage = coverImage;
    if (_coverImage) {
        
        CGFloat scale = [UIScreen mainScreen].bounds.size.height / _coverImage.size.height;
        scale *= 2;
        [_camera addWaterMark:_coverImage portraitRegion:CGRectMake(-1, 1, scale, scale) landscapeRegion:CGRectMake(-1, 1, scale, scale)];
        
    }else
    {
        [_camera removeWaterMark];
    }
    _coverImage = coverImage;
}

-(void)setMoPi:(CGFloat)moPi
{
    _moPi = moPi;
    [_camera moPi:_moPi];
}

-(void)setShouLian:(CGFloat)shouLian
{
    _shouLian = shouLian;
    [_camera shouLian:_shouLian];
}

-(void)setXiaoLian:(CGFloat)xiaoLian
{
    _xiaoLian = xiaoLian;
    [_camera xiaoLian:_xiaoLian];
}

-(void)setXiaBa:(CGFloat)xiaBa
{
    _xiaBa = xiaBa;
    [_camera xiaBa:_xiaBa];
}

-(void)setZuiXing:(CGFloat)zuiXing
{
    _zuiXing = zuiXing;
    [_camera zuiXing:_zuiXing];
}

-(void)setShouBi:(CGFloat)shouBi
{
    _shouBi = shouBi;
    [_camera shouBi:_shouBi];
}

-(void)setDaYan:(CGFloat)daYan
{
    _daYan = daYan;
    [_camera daYan:_daYan];
}

-(void)setTorch:(BOOL)torch
{
    if (self.captureDevicePosition == AVCaptureDevicePositionFront && torch) {
        return;
    }
    AVCaptureDevice *device = self.videoDevice;
    
    AVCaptureSession *session = _captureSession;
    [session beginConfiguration];
    if (device) {
        if (device.torchAvailable) {
            NSError *err = nil;
            if ([device lockForConfiguration:&err]) {
                [device setTorchMode:(torch ? AVCaptureTorchModeOn : AVCaptureTorchModeOff) ];
                [device unlockForConfiguration];
                //                ret = (device.torchMode == AVCaptureTorchModeOn);
            } else {
                NSLog(@"Error while locking device for torch: %@", err);
                //                ret = false;
            }
        } else {
            NSLog(@"Torch not available in current camera input");
        }
    }
    [session commitConfiguration];
}

-(BOOL)torch
{
    return self.videoDevice.torchMode == AVCaptureTorchModeOn;
}

-(void)setMirrorPushStream:(BOOL)mirrorPushStream
{
    _mirrorPushStream = mirrorPushStream;
    [_camera mirrorPushStream:_mirrorPushStream];
}

-(void)startLive:(NSString *)url
{
//    if (url.length > 0 && ![_liveSession.streamInfo.url isEqualToString:url] && [url rangeOfString:@"rtmp://pushws."].location != NSNotFound) {
//        [self pullUrlFromNetwork:url block:^(BOOL rs, NSString *msg) {
//            if (rs) {
//                LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
//                stream.url = msg;
//                [_liveSession startLive:stream];
//
//            }else
//            {
//                LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
//                stream.url = url;
//                [_liveSession startLive:stream];
//
//            }
//        }];
//
//    }else
//    {
//        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
//        stream.url = url;
//        [_liveSession startLive:stream];
//    }
            LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
              stream.url = @"rtmp://129.227.156.179/live/702269646_1648554386?vhost=pushbs.overseaslive.com&wsSecret=2329b1a64d47ae01726eccf9a29dc2e3&wsTime=1648554386&sid=2267&stream=702269646&wsPRI=1";
              [_liveSession startLive:stream];
}

-(void)pullUrlFromNetwork:(NSString *)pullUrl block:(void (^)(BOOL,NSString *))block
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://sdkoptedge.chinanetcenter.com"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [request setValue:pullUrl forHTTPHeaderField:@"WS_URL"];
    [request setValue:[NSString stringWithFormat:@"%d",1] forHTTPHeaderField:@"WS_RETIP_NUM"];
    [request setValue:[NSString stringWithFormat:@"%d",3] forHTTPHeaderField:@"WS_URL_TYPE"];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && ((NSHTTPURLResponse *)response).statusCode < 400) {
            NSString *url = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            url = [url stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if (url) {
                if (block) {
                    block(YES,url);
                }
            }else
            {
                if (block) {
                    block(NO,@"");
                }
            }
        }else
        {
            if (block) {
                block(NO,@"");
            }
        }
    }];
    [task resume];
}


-(void)stopLive
{
    [_liveSession stopLive];
}

-(UIView *)preView
{
    UIView *view = _camera.mainView;
    view.backgroundColor = [UIColor blackColor];
    @try {
        UIView *subview = view.subviews[0];
        GPUImageView *imageView = subview;
        imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_equalTo(view);
        }];
    } @catch (NSException *exception) {
        
    } @finally {
        if (view.superview != _preView) {
            [view removeFromSuperview];
            if (_preView) {
                [_preView addSubview:view];
                __weak typeof(_preView) weakPreView = _preView;
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.bottom.right.mas_equalTo(weakPreView);
                }];
            }
        }
        return _preView;
    }
}

-(void)setPreView:(UIView *)preView
{
    _preView = preView;
    
    _preView.layer.masksToBounds = YES;
}

+(instancetype)instance
{
    static dispatch_once_t onceToken;
    static DeerPushViewModel *model;
    dispatch_once(&onceToken, ^{
        model = [[DeerPushViewModel alloc] init];
    });
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        
        
    }
    return self;
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

- (void)setFrameRate:(int32_t)frameRate;
{
    
    AVCaptureDeviceFormat *bestFormat = nil;
    AVFrameRateRange *bestFrameRateRange = nil;
    for ( AVCaptureDeviceFormat *format in [_videoDevice formats] ) {
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
                bestFormat = format;
                bestFrameRateRange = range;
            }
        }
    }
    
    if (frameRate > 0)
    {
        if ([_videoDevice respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
            [_videoDevice respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]) {
            
            NSError *error111;
            BOOL result = [_videoDevice lockForConfiguration:&error111];
            
            if(result){
                [_videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, frameRate)];
                [_videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, frameRate)];
                
            }
            [_videoDevice unlockForConfiguration];
            
        } else {
            
            for (AVCaptureConnection *connection in _videoOutput.connections)
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
                    connection.videoMinFrameDuration = CMTimeMake(1, frameRate);
                
                if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
                    connection.videoMaxFrameDuration = CMTimeMake(1, frameRate);
#pragma clang diagnostic pop
            }
        }
        
    }
    else
    {
        if ([_videoDevice respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
            [_videoDevice respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]) {
            
            NSError *error111;
            [_videoDevice lockForConfiguration:&error111];
            if (error111 == nil) {
                
                [_videoDevice setActiveVideoMinFrameDuration:kCMTimeInvalid];
                [_videoDevice setActiveVideoMaxFrameDuration:kCMTimeInvalid];
                
            }
            [_videoDevice unlockForConfiguration];
            
        } else {
            
            for (AVCaptureConnection *connection in _videoOutput.connections)
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
                    connection.videoMinFrameDuration = kCMTimeInvalid; // This sets videoMinFrameDuration back to default
                
                if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
                    connection.videoMaxFrameDuration = kCMTimeInvalid; // This sets videoMaxFrameDuration back to default
#pragma clang diagnostic pop
            }
        }
        
    }
}

-(NSMutableDictionary *)beautyDicationay
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (beauty_type i = beauty_type_Whiten; i<beauty_type_Nose; i++) {
        dictionary[[NSString stringWithFormat:@"%d",i]] = @([self currentWithType:i]);
    }
    return dictionary;
}

-(NSString *)dataPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"pathOfBeauty.beauty"];
}

-(void)saveData
{
    NSMutableDictionary *dictionary = [self beautyDicationay];
    NSData *data = [WT2Tools jsonDataFromObject:dictionary];
    [data writeToFile:[self dataPath] atomically:YES];
}

-(void)loadData
{
    NSMutableDictionary *dictionary = nil;
    NSData *beautyData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[self dataPath]]];
    if (beautyData) {
        NSDictionary *info = [WT2Tools jsonDataToObject:beautyData];
        dictionary = [info mutableCopy];
    }
    
    if (!dictionary) {
        [self setDaYan:0];
        [self setShouLian:0];
        [self setMoPi:.5];
        
        [self setZuiXing:.3];
        [self setShouBi:0];
        [self setXiaBa:.5];
        [self setXiaoLian:.5];
        dictionary = [self beautyDicationay];
        [self saveData];
    }
    for (NSNumber *number in dictionary.allKeys) {
        [self setCurrentWithType:[number intValue] current:[dictionary[number] floatValue]];
    }
}

-(CGFloat)currentWithType:(beauty_type)type
{
    switch (type) {
        case beauty_type_Whiten:
        {
            return [self moPi];
        }
            break;
        case beauty_type_Width:
        {
            return [self shouLian];
        }
            break;
        case beauty_type_FaceWidth:
        {
            return [self xiaoLian];
        }
            break;
        case beauty_type_Jaw:
        {
            return [self xiaBa];
        }
            break;
        case beauty_type_EyeSize:
        {
            return [self daYan];
        }
            break;
        case beauty_type_Lips:
        {
            return [self zuiXing];
        }
            break;
        case beauty_type_Nose:
        {
            return [self shouBi];
        }
            break;
            
        default:
            break;
    }
    return 0;
}

-(void)setCurrentWithType:(beauty_type)type current:(CGFloat)current
{
    switch (type) {
        case beauty_type_Whiten:
        {
            [self setMoPi:current];
        }
            break;
        case beauty_type_Width:
        {
            [self setShouLian:current];
        }
            break;
        case beauty_type_FaceWidth:
        {
            [self setXiaoLian:current];
        }
            break;
        case beauty_type_Jaw:
        {
            [self setXiaBa:current];
        }
            break;
        case beauty_type_EyeSize:
        {
            [self setDaYan:current];
        }
            break;
        case beauty_type_Lips:
        {
            [self setZuiXing:current];
        }
            break;
        case beauty_type_Nose:
        {
            [self setShouBi:current];
        }
            break;
            
        default:
            break;
    }
}


-(void)runAsynchronouslyOnContextQueue:(GPUImageContext *)context block:(void (^)(void))block
{
    dispatch_queue_t videoProcessingQueue = [context contextQueue];
    
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == videoProcessingQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([WTGPUImageContext contextKey]))
#endif
        {
            block();
        }else
        {
            dispatch_async(videoProcessingQueue, block);
        }
}

-(void)runSynchronouslyOnContextQueue:(GPUImageContext *)context block:(void (^)(void))block
{
    dispatch_queue_t videoProcessingQueue = [context contextQueue];
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == videoProcessingQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([WTGPUImageContext contextKey]))
#endif
        {
            block();
        }else
        {
            dispatch_sync(videoProcessingQueue, block);
        }
}

-(void)runSynchronouslyblock:(void (^)(void))block
{
    dispatch_queue_t videoProcessingQueue = [WTGPUImageContext sharedContextQueue];
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == videoProcessingQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([WTGPUImageContext contextKey]))
#endif
        {
            block();
        }else
        {
            dispatch_sync(videoProcessingQueue, block);
        }
}

-(void)runAsynchronouslyblock:(void (^)(void))block
{
    dispatch_queue_t videoProcessingQueue = [WTGPUImageContext sharedContextQueue];
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == videoProcessingQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([WTGPUImageContext contextKey]))
#endif
        {
            block();
        }else
        {
            dispatch_async(videoProcessingQueue, block);
        }
}

@end
