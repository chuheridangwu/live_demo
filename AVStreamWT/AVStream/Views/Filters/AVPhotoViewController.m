//
//  AVPhotoViewController.m
//  AVStream
//
//  Created by R on 2018/5/3.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import "AVPhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AVPhotoViewController ()

@end

@implementation AVPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CNMImageView cnm_ImageViewInitwithSuperView:self.view withBlock:^(CNMImageView *cnm) {
        cnm.image = [UIImage imageWithData:self.imageData];
    } withMasonryMake:^(MASConstraintMaker *make, CNMImageView *cnm) {
        make.top.right.left.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-100);
    }];
    
    [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalTitle(@"放弃");
        button.butNormalTitleColor(kBlackColor);
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.bottom.equalTo(self.view).offset(-30);
        make.centerX.equalTo(self.view.mas_centerX).offset(-50);
    } withButtonBlock:^(CNMButton *button) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [CNMButton cnm_ButonInitwithSuperView:self.view with:^(CNMButton *button) {
        button.butNormalTitle(@"保存");
        button.butNormalTitleColor(kBlackColor);
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.bottom.equalTo(self.view).offset(-30);
        make.centerX.equalTo(self.view.mas_centerX).offset(50);
    } withButtonBlock:^(CNMButton *button) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:self.imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
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
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alertCtl animated:YES completion:nil];
        }];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
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
