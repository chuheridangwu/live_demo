//
//  AVProgressView.m
//  AVStream
//
//  Created by R on 2018/5/2.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import "AVProgressView.h"

@interface AVProgressView ()
{
    CGFloat _lastProgress;
}
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIColor *strokeColor;

@end

@implementation AVProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.strokeColor = kColorWithHex(@"e8e8e8");
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = self.strokeColor;
    [self addSubview:self.bgView];
    
    _lastProgress = 0;
}

- (void)setProgress:(CGFloat)progress {
    if (progress >= 1.0) {
        progress = 1.0;
    }
    _progress = progress;
    self.strokeColor = kColorWithHex(@"fcb847");
    [self setLastProgress:_lastProgress progress:progress];

    _lastProgress = progress;
}

- (void)setInterval:(CGFloat)interval {
    _interval = interval;
    self.strokeColor = kWhiteColor;
    [self setLastProgress:_lastProgress - interval/self.bgView.frameWidth progress:_lastProgress];
}

- (void)deleteLastProgress:(CGFloat)progress {
    self.strokeColor = kColorWithHex(@"e8e8e8");
    [self setLastProgress:_progress progress:progress];
    _progress = progress;
    _lastProgress = progress;
}

- (void)setLastProgress:(CGFloat)lastProgress progress:(CGFloat)progress {
    CAShapeLayer *solidShapeLayer = [CAShapeLayer layer];
    CGMutablePathRef solidShapePath =  CGPathCreateMutable();
    [solidShapeLayer setStrokeColor:self.strokeColor.CGColor];
    solidShapeLayer.lineWidth = 10.0f ;
    CGPathMoveToPoint(solidShapePath, NULL, self.bgView.frameWidth * lastProgress, 5);
    CGPathAddLineToPoint(solidShapePath, NULL, self.bgView.frameWidth * progress,5);
    [solidShapeLayer setPath:solidShapePath];
    CGPathRelease(solidShapePath);
    [self.bgView.layer addSublayer:solidShapeLayer];
}

@end
