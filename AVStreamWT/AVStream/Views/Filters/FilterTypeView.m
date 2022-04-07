//
//  FilterTypeView.m
//  AVStream
//
//  Created by R on 2018/4/27.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import "FilterTypeView.h"

@interface FilterTypeView ()
{
    UIScrollView *scrollview;
}
@property (nonatomic, strong) NSMutableArray *filterArray;
@property (nonatomic, strong) CNMButton *selectBtn;

@end

@implementation FilterTypeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    [CNMButton cnm_ButonInitwithSuperView:self with:^(CNMButton *button) {
        button.butNormalTitle(@"确认");
        button.backgroundColor = kRedColor;
    } withMasonryMake:^(MASConstraintMaker *make, CNMButton *cnm) {
        make.top.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    } withButtonBlock:^(CNMButton *button) {
        [self setHidden:YES];
    }];
    
    scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 35, self.bounds.size.width, self.bounds.size.height - 35)];    
    [self addSubview:scrollview];
    
    for (int i = 0; i < self.filterArray.count; i ++) {
        NSDictionary *dict = self.filterArray[i];
        [CNMImageView cnm_ImageViewInitwithSuperView:scrollview withBlock:^(CNMImageView *cnm) {
            cnm.imageImage([UIImage imageNamed:dict[@"filter"]]);
        } withMasonryMake:^(MASConstraintMaker *make, CNMImageView *cnm) {
            make.top.equalTo(scrollview);
            make.size.mas_equalTo(CGSizeMake(60, 60));
            make.left.equalTo(scrollview).offset(10 + 70 * i);
        } withImageBlock:^(CNMImageView *imageView) {
            if (self.filterBlock) {
                self.filterBlock(dict[@"filter"]);
            }
        }];
        
        [CNMImageView cnm_ImageViewInitwithSuperView:scrollview withBlock:^(CNMImageView *cnm) {
            cnm.imageImage([UIImage imageNamed:@"filter_name_bg"]);
        } withMasonryMake:^(MASConstraintMaker *make, CNMImageView *cnm) {
            make.top.equalTo(scrollview).offset(40);
            make.size.mas_equalTo(CGSizeMake(60, 20));
            make.left.equalTo(scrollview).offset(10 + 70 * i);
        } withImageBlock:^(CNMImageView *imageView) {
          
        }];
        
        [CNMLabel cnm_LabInitWithSuperView:scrollview withBlock:^(CNMLabel *cnm) {
            cnm.labText(dict[@"title"]).labFont(11).labTextAlignment(NSTextAlignmentCenter);
            cnm.labTextColor(kWhiteColor);
        } withlabWithMas_makeConstraints:^(MASConstraintMaker *make, CNMLabel *cnm) {
            make.top.equalTo(scrollview).offset(40);
            make.size.mas_equalTo(CGSizeMake(60, 20));
            make.left.equalTo(scrollview).offset(10 + 70 * i);
        }];
        
        if (i == self.filterArray.count - 1) {
            scrollview.contentSize = CGSizeMake(10 + 70 * self.filterArray.count, 60);
        }
    }
    
    
}

- (NSMutableArray *)filterArray {
    if (!_filterArray) {
        _filterArray = [NSMutableArray new];
       
        NSArray *array = @[@{@"filter":@"GPUImageFilter",@"title":@"无"},
                           @{@"filter":@"IFSutroFilter",@"title":@"复古"},
                           @{@"filter":@"IFAmaroFilter",@"title":@"锐化"},
                           @{@"filter":@"IFNormalFilter",@"title":@"自然"},
                           @{@"filter":@"IFRiseFilter",@"title":@"日出"},
                           @{@"filter":@"IFHudsonFilter",@"title":@"海洋"},
                           @{@"filter":@"IFXproIIFilter",@"title":@"胶片"},
                           @{@"filter":@"IFSierraFilter",@"title":@"山脉"},
                           @{@"filter":@"IFLomofiFilter",@"title":@"Lomo"},
                           @{@"filter":@"IFEarlybirdFilter",@"title":@"怀旧"},
                           @{@"filter":@"IFToasterFilter",@"title":@"阳光"},
                           @{@"filter":@"IFBrannanFilter",@"title":@"朦胧"},
                           @{@"filter":@"IFInkwellFilter",@"title":@"黑白"},
                           @{@"filter":@"IFWaldenFilter",@"title":@"野外"},
                           @{@"filter":@"IFHefeFilter",@"title":@"光晕"},
                           @{@"filter":@"IFValenciaFilter",@"title":@"褪色"},
                           @{@"filter":@"IFNashvilleFilter",@"title":@"童话"},
                           @{@"filter":@"IF1977Filter",@"title":@"旧时光"},
                           @{@"filter":@"IFLordKelvinFilter",@"title":@"田野"},
                           ];
        for (NSDictionary *dict in array) {
            [_filterArray addObject:dict];
        }
    }
    return _filterArray;
}

@end
