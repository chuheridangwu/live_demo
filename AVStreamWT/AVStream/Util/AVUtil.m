//
//  AVUtil.m
//  AVStream
//
//  Created by gaoshuang  on 2018/5/2.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import "AVUtil.h"

@implementation AVUtil
HELPER_SHARED(AVUtil)
- (NSString *)getVideoMergeFilePathString
{
    NSString *path = NSHomeDirectory();
    path = [path stringByAppendingPathComponent:@"Documents/XX_VIDEO1"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingFormat:@"m%d.mp4",arc4random()%10000];
    
    unlink(fileName.UTF8String);
    
    
    return fileName;
}

- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray callBack:(NetObjLCallBackBlock)callBack
{
    
    [self mergeAndExportVideos:fileURLArray withOutPath:[self getVideoMergeFilePathString] callBack:^(BOOL rs, NSObject *obj) {
        if (callBack) {
            callBack(YES,obj);
        }
    }];
}

- (void)mergeAndExportVideos:(NSArray*)videosPathArray withOutPath:(NSString*)outpath callBack:(NetObjLCallBackBlock)callBack{
    if (videosPathArray.count == 0) {
        return;
    }
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    
    //  注释无声音
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 注释无声音
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < videosPathArray.count; i++) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:videosPathArray[i]];
        
        
        // 注释无声音
                NSError *erroraudio = nil;
//        获取AVAsset中的音频 或者视频
                AVAssetTrack *assetAudioTrack = nil;
                if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
                    assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
                }
//        向通道内加入音频或者视频
                BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                              ofTrack:assetAudioTrack
                                               atTime:totalDuration
                                                error:&erroraudio];
        
                NSLog(@"erroraudio:%@%d",erroraudio,ba);
        
        // 注释无声音
        
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        NSLog(@"errorVideo:%@%d",errorVideo,bl);
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    NSLog(@"%@",NSHomeDirectory());
    
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"exporter%@",exporter.error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(YES,mergeFileURL);
            }
        });
    }];
    
}



@end
