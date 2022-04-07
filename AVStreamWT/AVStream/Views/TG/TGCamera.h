//
//  TGCamera.h
//  videochatdemo
//
//  Created by sc on 2018/5/30.
//  Copyright © 2018年 sc. All rights reserved.
//

#ifndef TGCamera_h
#define TGCamera_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol TGCameraDelegate <NSObject>

- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface TGCameraConfig : NSObject

@property(nonatomic, copy) AVCaptureSessionPreset captureSize;     //采集大小
@property(nonatomic) CMTime fps;                                 //采集率
@property(nonatomic, assign) BOOL Mirrored;                       //是否镜像

@end

@interface TGCamera : NSObject
@property (nonatomic, weak) id<TGCameraDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isFrontCamera;
@property (assign, nonatomic) CGPoint focusPoint;
@property (assign, nonatomic) CGPoint exposurePoint;
@property (assign, nonatomic) int captureFormat; //采集格式
@property (copy  , nonatomic) dispatch_queue_t  captureQueue;//录制的队列

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition captureFormat:(int)captureFormat;

- (instancetype)initWithCameraConfig:(TGCameraConfig *)config;

- (void)startCapture;

- (void)stopCapture;

- (void)changeCameraInputDeviceisFront:(BOOL)isFront;
- (BOOL)changeCameraStatus;

@end


#endif /* TGCamera_h */
