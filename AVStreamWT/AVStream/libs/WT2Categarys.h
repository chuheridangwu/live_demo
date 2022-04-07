//
//  DeerCategarys.h
//  DeerLive
//
//  Created by 鹿容 on 2019/7/20.
//  Copyright © 2019 Deer. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface UIColor (Deer)
//
//+ (UIColor *)colorWithHexString:(NSString *)color;
//+ (UIColor *)colorWithHexString:(NSString *)stringToConvert Alpha:(CGFloat)alpha;
//+ (UIColor *)colorWithRGBHex:(UInt32)hex Alpha:(CGFloat)alpha;
//@end
//
//@interface NSString (Deer)
//
//- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width;
//- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height;
//
////替换字符串
//- (NSString *)replaceAllString:(NSString*)aBeReplacedString
//                    WithString:(NSString *)aReplacedString;
//
//-(int)finalLength;
//
//-(int)getFinalStringLength:(NSString*)inputString characterCount:(int)allCount;
//
//// 判断字符串是否为空
//+ (BOOL)isBlankString:(NSString *)aStr;
//
//@end
//
//@interface UIView (Deer)
//@property (nonatomic, assign) CGFloat x;
//@property (nonatomic, assign) CGFloat y;
//@property (nonatomic, assign) CGFloat centerX;
//@property (nonatomic, assign) CGFloat centerY;
//@property (nonatomic, assign) CGFloat width;
//@property (nonatomic, assign) CGFloat height;
//@property (nonatomic, assign) CGSize size;
//@property (nonatomic, assign) CGPoint origin;
//
//@property (assign, nonatomic) CGFloat mj_maxY;
//@property (assign, nonatomic) CGFloat mj_maxX;
//
//@property (nonatomic, assign) CGFloat mj_bottom;
//
//@property(nonatomic) CGFloat left;
//@property(nonatomic) CGFloat top;
//@property(nonatomic) CGFloat right;
//@property(nonatomic) CGFloat bottom;
//
//@end

@interface NSBundle (Deer)

-(NSString *)WT_Bundle;

-(NSDictionary<NSString *,id> *)WT_infoDictionary;

@end

@interface NSDate (Deer)

+(instancetype)dateA;

-(NSTimeInterval)timeIntervalSince1970A;

@end

@interface NSObject (Deer)
// 获取当前显示的控制器
- (UIViewController *)getCurrentVc;

@end

@interface NSString (WT)
- (NSString *)getAgeString;
@end


