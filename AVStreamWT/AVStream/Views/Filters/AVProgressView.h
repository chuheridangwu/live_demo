//
//  AVProgressView.h
//  AVStream
//
//  Created by R on 2018/5/2.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVProgressView : UIView
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat interval;

- (void)deleteLastProgress:(CGFloat)progress;

@end
