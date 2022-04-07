//  WT_Camera.h
//
//  Created by Benqu on 16/4/1.
//  Copyright © 2016年 Benqu Dali. All rights reserved.
//

//#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

typedef enum{
    CamResolution640x480,
    CamResolution1280x720
}CamResolution;

typedef enum{
    OutputOrientationPortrait,
    OutputOrientationLandscapeLeft,
    OutputOrientationLandscapeRight
}OutputOrientation;


@interface WT_Camera : NSObject<UIAccelerometerDelegate>
//filter view
@property (nonatomic,readonly) UIView *mainView;
//
- (void)drawWithPhotoDict:(NSMutableDictionary *)arg1;

//设置显示的frame
- (void)setCameraFrame:(CGRect)frame;

//设置管道中处理的及最后输出分辨率
- (void)resizeGPU:(CGSize)textureSize;
//初始化
- (id)initWithFrame:(CGRect)colorFrame CamResolution:(CamResolution)camResolution ProcessSize:(CGSize)processSize;
//设置流输入
- (CVPixelBufferRef)processSampleBufferInput:(CMSampleBufferRef)sampleBuffer;

//鉴权
- (void)requestForAuthorization:(NSString *)codeString;


#pragma mark - Accessors
//set 各种参数，范围 [0.0, 1.0];
//磨皮
- (void)moPi:(float)value;

//瘦脸
- (void)shouLian:(float)value;

//削脸
- (void)xiaoLian:(float)value;

//下巴
- (void)xiaBa:(float)value;

//嘴型
- (void)zuiXing:(float)value;

//瘦鼻
- (void)shouBi:(float)value;

//大眼;
- (void)daYan:(float)value;

/**
 色彩滤镜

 @param image 穿nil则取消滤镜效果
 */
- (void)addStyle:(UIImage*)image;
//滤镜透明度
- (void)styleAlpha:(float)value;

//若把json和png文件夹放在app MainBundle里，isIn设为yes，picDir设为nil即可;
//若把json和png文件夹放在Documents里，isIn设为no，picDir为图片所在的上级目录名称，末尾不加斜杠
- (void)drawGifWithJson:(NSString *)jsonRealPath isInMainBundle:(BOOL)isIn PicFolder:(NSString *)picDir;
//清除特效
- (void)cleanCurrentGIF;
//旋转摄像头,传入目的position(即要转为的前置or后置摄像头）
- (void)rotateCam:(AVCaptureDevicePosition)position;

//设置流的横屏or竖屏
- (void)streamOrientation:(OutputOrientation)orientation;

//初始化摄像头之后，把摄像头的session传进来
- (void)giveYourSession:(AVCaptureSession*)session;

/**添加水印，
 * 参考坐标系：竖竖屏推流均以屏幕左上角为第二象限
 * (UIImage*)waterMark 水印图片
 * (CGRect)portraitRegion 竖屏推流水印位置， 需要归一化，没有竖屏推流时传CGRectZero即可
 * (CGRect)landscapeRegion 横屏推流水印位置，需要归一化，没有横屏推流时传CGRectZero即可
 *
 *  sample示例：
 *  水印图片size：256*128，若希望水印出现在屏幕左上角(-1.0, 1.0),则：
 *  portraitRegion = CGRectMake(-1.0, 1.0, 1.0, 0.5*9.0/16.0) 以屏幕短边为基准，1.0:0.5是图片宽高比，9.0/16.0是屏幕长宽比
 *  landscapeRegion = CGRectMake(-1.0, 1.0, 1.0, 0.5*16.0/9.0) 以屏幕长边为基准，1.0:0.5是图片宽高比，16.0/9.0是屏幕长宽比
 */
- (void)addWaterMark:(UIImage*)waterMark portraitRegion:(CGRect)portraitRegion landscapeRegion:(CGRect)landscapeRegion;

- (void)removeWaterMark;

//推流镜像选择，value=YES时镜像，默认NO
- (void)mirrorPushStream:(BOOL)value;


@end
