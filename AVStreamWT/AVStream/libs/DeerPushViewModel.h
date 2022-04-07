//
//  DeerPushViewModel.h
//  DeerLive
//
//  Created by 鹿容 on 2019/6/26.
//  Copyright © 2019 Deer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>

@interface WTGPUImageContext : GPUImageContext

@end

typedef enum{
    beauty_type_Whiten = 10001,
    beauty_type_Width,
    beauty_type_FaceWidth,
    beauty_type_Jaw,
    beauty_type_EyeSize,
    beauty_type_Lips,
    beauty_type_Nose
} beauty_type;

NS_ASSUME_NONNULL_BEGIN

@interface DeerPushViewModel : NSObject


//set 各种参数，范围 [0.0, 1.0];
//磨皮
@property (nonatomic,assign)CGFloat moPi;

//瘦脸
@property (nonatomic,assign)CGFloat shouLian;

//削脸
@property (nonatomic,assign)CGFloat xiaoLian;

//下巴
@property (nonatomic,assign)CGFloat xiaBa;

//嘴型
@property (nonatomic,assign)CGFloat zuiXing;

//瘦鼻
@property (nonatomic,assign)CGFloat shouBi;

//大眼;
@property (nonatomic,assign)CGFloat daYan;

@property (nonatomic,strong)UIImage *filterImage;

@property (nonatomic,assign)CGFloat filterAlpha;

@property (nonatomic,strong,nullable)UIImage *coverImage;
//
@property (nonatomic,copy,nullable)NSString *effectPath;

@property (nonatomic,assign)BOOL mirrorPushStream;

/** The torch control camera zoom scale default 1.0, between 1.0 ~ 3.0 */
//@property (nonatomic, assign) CGFloat zoomScale;

/** The torch control capture flash is on or off */
@property (nonatomic, assign) BOOL torch;

/** The muted control callbackAudioData,muted will memset 0.*/
@property (nonatomic, assign) BOOL muted;

/** The captureDevicePosition control camraPosition ,default front*/
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

@property (nonatomic, assign) int fps;

@property (nonatomic,copy)void (^onPixelBuffer)(CVPixelBufferRef pixelBuffer,CMTime time);

/** The preView will show OpenGL ES view*/
@property (nonatomic, strong) UIView *preView;

-(UIImage *)currentImage;

-(void)startCapture;

-(void)stopCaptue;

-(void)startLive:(NSString *)url;

-(void)stopLive;

+(instancetype)instance;

-(void)saveData;

-(CGFloat)currentWithType:(beauty_type)type;

-(void)setCurrentWithType:(beauty_type)type current:(CGFloat)current;

-(void)runAsynchronouslyOnContextQueue:(GPUImageContext *)context block:(void (^)(void))block;

-(void)runSynchronouslyOnContextQueue:(GPUImageContext *)context block:(void (^)(void))block;

-(void)runSynchronouslyblock:(void (^)(void))block;

-(void)changeToSmall:(BOOL)isSmall;

@end

NS_ASSUME_NONNULL_END
