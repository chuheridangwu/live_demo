//
//  AVPlayerViewController.m
//  AVStream
//
//  Created by R on 2018/5/3.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import "AVPlayerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AVPlayerViewController ()
{
    AVPlayer *_player;
}
@end

@implementation AVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"视频";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveVideoToAssetsLibrary)];
    self.view.backgroundColor = kBlackColor;
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:self.videoUrl];
    _player = [[AVPlayer alloc] initWithPlayerItem:item];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    layer.frame = self.view.bounds;
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:layer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_player play];
}

- (void)playFinish:(NSNotification *)not {
    //AVPlayerItem *item = [not object];
    [_player seekToTime:kCMTimeZero];
    [_player play];

}

- (void)saveVideoToAssetsLibrary {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:self.videoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
        NSString *message = nil;
        if (error) {
            NSLog(@"error");
            message = @"保存失败";
        } else {
            NSLog(@"success");
            message = @"已存入相册";
            
        }
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertCtl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertCtl animated:YES completion:nil];
    }];
}

- (void)dealloc {
    NSLog(@"%@------dealloc",[self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
