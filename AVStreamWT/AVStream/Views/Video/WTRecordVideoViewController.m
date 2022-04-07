//
//  WTRecordVideoViewController.m
//  AVStream
//
//  Created by gaoshuang  on 2018/7/5.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//
//#import <LFLiveKit/LFLiveKit.h>
#import "LFLiveKit.h"
#import "WTRecordVideoViewController.h"
#import "AVUtil.h"
#define DEFAULT_VIDEO_SIZE (CGSizeMake(576.,1024.))
#import "GPUImageBeautifyFilter.h"
//#import "SSCaptureMedia.h"
#import "LFLivePreview.h"
#define SHORT_VIDEO_FPS (20)
#import "DeerPushViewModel.h"
@interface WTRecordVideoViewController ()<LFLiveSessionDelegate>
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

@end
@implementation WTRecordVideoViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
}

-(void)WTCaptureMedia__LFLiveSessionCustom{
    [self WTCaptureMedia];
}
//wt
-(void)WTCaptureMedia{
    
    [DeerPushViewModel instance].fps = SHORT_VIDEO_FPS;
    [DeerPushViewModel instance].muted = NO;
    [[DeerPushViewModel instance] startCapture];
    [DeerPushViewModel instance].preView = [[UIView alloc] init];
    
    [[DeerPushViewModel instance] setCurrentWithType:beauty_type_Whiten current:0.6];
    [DeerPushViewModel instance].daYan = 0.5;
    [DeerPushViewModel instance].shouBi = 0.5;
    [DeerPushViewModel instance].shouLian = 0.5;
    [DeerPushViewModel instance].xiaBa = 0.5;
    [DeerPushViewModel instance].zuiXing = 0.5;
    [DeerPushViewModel instance].xiaoLian = 0.5;
    [DeerPushViewModel instance].moPi = 0.5;
    
    [_videoView addSubview:[DeerPushViewModel instance].preView];
    [DeerPushViewModel instance].preView.frame = _videoView.bounds;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _videoView = [[UIView alloc] init];
    _videoView.backgroundColor = kOrangeColor;
    _videoView.frame = self.view.frame;
    [self.view addSubview:_videoView];
    
    [self WTCaptureMedia__LFLiveSessionCustom];
    
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
            button.butNormalImageName(array[i][@"IMAGE"]);
            button.butNormalTitle(@"直播");
        } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.right.equalTo(_buttonSwitch);
            make.top.equalTo(self.view).offset(top);
        } withButtonBlock:^(CNMButton *button) {            
//            [[DeerPushViewModel instance] startLive:@"rtmp://192.168.157.166:1935/rtmplive/room"];
            [[DeerPushViewModel instance] startLive:@"rtmp://192.168.160.136:1935/rtmplive/room"];

        
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
    
    [[DeerPushViewModel instance] stopCaptue];
    [[DeerPushViewModel instance] stopLive];
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

