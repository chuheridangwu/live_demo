//
//  FilterTypeView.h
//  AVStream
//
//  Created by R on 2018/4/27.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FilterBlock)(NSString *);

@interface FilterTypeView : UIView

@property (nonatomic, copy) FilterBlock filterBlock;


@end
