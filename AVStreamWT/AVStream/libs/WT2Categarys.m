//
//  DeerCategarys.m
//  DeerLive
//
//  Created by 鹿容 on 2019/7/20.
//  Copyright © 2019 Deer. All rights reserved.
//

#import "WT2Categarys.h"

//@implementation UIColor (Deer)
//
//+ (UIColor *)colorWithHexString:(NSString *)color
//{
//    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
//
//    // String should be 6 or 8 characters
//    if ([cString length] < 6) {
//        return [UIColor clearColor];
//    }
//
//    // strip 0X if it appears
//    if ([cString hasPrefix:@"0X"])
//        cString = [cString substringFromIndex:2];
//    if ([cString hasPrefix:@"#"])
//        cString = [cString substringFromIndex:1];
//    if ([cString length] != 6)
//        return [UIColor clearColor];
//
//    // Separate into r, g, b substrings
//    NSRange range;
//    range.location = 0;
//    range.length = 2;
//
//    //r
//    NSString *rString = [cString substringWithRange:range];
//
//    //g
//    range.location = 2;
//    NSString *gString = [cString substringWithRange:range];
//
//    //b
//    range.location = 4;
//    NSString *bString = [cString substringWithRange:range];
//
//    // Scan values
//    unsigned int r, g, b;
//    [[NSScanner scannerWithString:rString] scanHexInt:&r];
//    [[NSScanner scannerWithString:gString] scanHexInt:&g];
//    [[NSScanner scannerWithString:bString] scanHexInt:&b];
//
//    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
//}
//
//+ (UIColor *)colorWithHexString:(NSString *)stringToConvert Alpha:(CGFloat)alpha
//{
//    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
//
//    // String should be 6 or 8 characters
//    if ([cString length] < 6) {
//        return [UIColor clearColor];
//    }
//
//    // strip 0X if it appears
//    if ([cString hasPrefix:@"0X"])
//        cString = [cString substringFromIndex:2];
//    if ([cString hasPrefix:@"#"])
//        cString = [cString substringFromIndex:1];
//    if ([cString length] != 6)
//        return [UIColor clearColor];
//
//    NSScanner *scanner = [NSScanner scannerWithString:cString];
//    unsigned hexNum;
//    if (![scanner scanHexInt:&hexNum]) return nil;
//    return [UIColor colorWithRGBHex:hexNum Alpha:alpha];
//}
//
//+ (UIColor *)colorWithRGBHex:(UInt32)hex Alpha:(CGFloat)alpha
//{
//    int r = (hex >> 16) & 0xFF;
//    int g = (hex >> 8) & 0xFF;
//    int b = (hex) & 0xFF;
//
//    return [UIColor colorWithRed:r / 255.0f
//                           green:g / 255.0f
//                            blue:b / 255.0f
//                           alpha:alpha];
//}
//
//@end
//
//@implementation NSString (Deer)
//
//- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width{
//
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
//
//    CGSize size = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
//                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                  attributes:attributes
//                                     context:nil].size;
//    return CGSizeMake((int)size.width+1,(int)size.height);
//
//    //    CGSize size = [self sizeWithFont:font
//    //                   constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
//    //                       lineBreakMode:NSLineBreakByWordWrapping];
//    //    return CGSizeMake((int)size.width+1,(int)size.height);
//}
//
//- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height{
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
//
//    CGSize size = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
//                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                  attributes:attributes
//                                     context:nil].size;
//    return CGSizeMake((int)size.width+1,(int)size.height);
//}
//
////替换字符串
//- (NSString *)replaceAllString:(NSString*)aBeReplacedString
//                    WithString:(NSString *)aReplacedString
//{
//    NSMutableString *theString = [NSMutableString stringWithString:self];
//    [theString replaceOccurrencesOfString:aBeReplacedString
//                               withString:aReplacedString
//                                  options:NSCaseInsensitiveSearch
//                                    range:NSMakeRange(0, theString.length)];
//    return [NSString stringWithString:theString];
//}
//
//-(int)finalLength
//{
//    return [self getFinalStringLength:self characterCount:1];
//}
//
//-(int)getFinalStringLength:(NSString*)inputString characterCount:(int)allCount
//{
//    if (nil == inputString || [inputString isEqualToString:@""])
//    {
//        return  0;
//    }
//
//    __block int count = 0;
//    __block int weakAllCount = allCount;
//    //    __block int allLength = 0;
//
//    [inputString enumerateSubstringsInRange:NSMakeRange(0, inputString.length)
//                                    options:NSStringEnumerationByComposedCharacterSequences
//                                 usingBlock:^(NSString *substring,NSRange substringRange,NSRange enclosingRange,BOOL *stop){
//                                     unichar c = [substring characterAtIndex:0];
//                                     if (c >= ' ' && c <= '~' && substring.length == 1) {
//                                         count  += weakAllCount;
//                                     }else
//                                     {
//                                         count  += weakAllCount*2;
//                                     }
//                                 }];
//    return count;
//}
//
//+ (BOOL)isBlankString:(NSString *)aStr {
//
//    if (!aStr) {
//        return YES;
//    }
//
//    if ([aStr isKindOfClass:[NSNull class]]) {
//        return YES;
//    }
//
//    if (!aStr.length) {
//        return YES;
//    }
//
//    if (aStr == nil) {
//        return YES;
//    }
//
//    if (aStr == NULL) {
//
//    }
//
//    if ([aStr isEqualToString:@"NULL"]) {
//        return YES;
//    }
//
//    if ([aStr isEqualToString:@"(null)"]) {
//        return YES;
//    }
//
//    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
//    if (!trimmedStr.length) {
//        return YES;
//    }
//    return NO;
//}
//
//@end
//
//@implementation UIView (Deer)
//
//- (void)setX:(CGFloat)x
//{
//    CGRect frame = self.frame;
//    frame.origin.x = x;
//    self.frame = frame;
//}
//
//- (void)setY:(CGFloat)y
//{
//    CGRect frame = self.frame;
//    frame.origin.y = y;
//    self.frame = frame;
//}
//
//- (CGFloat)x
//{
//    return self.frame.origin.x;
//}
//
//- (CGFloat)y
//{
//    return self.frame.origin.y;
//}
//
//- (void)setCenterX:(CGFloat)centerX
//{
//    CGPoint center = self.center;
//    center.x = centerX;
//    self.center = center;
//}
//
//- (CGFloat)centerX
//{
//    return self.center.x;
//}
//
//- (void)setCenterY:(CGFloat)centerY
//{
//    CGPoint center = self.center;
//    center.y = centerY;
//    self.center = center;
//}
//
//- (CGFloat)centerY
//{
//    return self.center.y;
//}
//
//- (void)setWidth:(CGFloat)width
//{
//    if (isnan(width)) {
//        return;
//    }
//    CGRect frame = self.frame;
//    frame.size.width = width;
//    self.frame = frame;
//}
//
//- (void)setHeight:(CGFloat)height
//{
//    CGRect frame = self.frame;
//    frame.size.height = height;
//    self.frame = frame;
//}
//
//- (CGFloat)height
//{
//    return self.frame.size.height;
//}
//
//- (CGFloat)width
//{
//    return self.frame.size.width;
//}
//
//- (void)setSize:(CGSize)size
//{
//    CGRect frame = self.frame;
//    frame.size = size;
//    self.frame = frame;
//}
//
//- (CGSize)size
//{
//    return self.frame.size;
//}
//
//- (void)setOrigin:(CGPoint)origin
//{
//    CGRect frame = self.frame;
//    frame.origin = origin;
//    self.frame = frame;
//}
//
//- (CGPoint)origin
//{
//    return self.frame.origin;
//}
//
//-(CGFloat)mj_maxY
//{
//    return self.frame.origin.y+self.frame.size.height;
//
//}
//-(CGFloat)mj_maxX
//{
//    return self.frame.origin.x+self.frame.size.width;
//}
//
//-(CGFloat)mj_bottom{
//
//    return CGRectGetMaxY(self.frame);
//
//}
//- (void)setMj_bottom:(CGFloat)mj_bottom {
//
//    self.y = mj_bottom - self.height;
//}
//
//@end

@implementation NSBundle (Deer)

-(NSString *)WT_Bundle
{
    return @"com.lTQ8rt.K3JZLV.Dr0Mp3";
}

-(NSDictionary<NSString *,id> *)WT_infoDictionary
{
    NSString* File = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:File];
    
    dict[@"CFBundleIdentifier"] = @"com.lTQ8rt.K3JZLV.Dr0Mp3";
    return dict;
}


@end

@implementation NSDate (Deer)

+(instancetype)dateA
{
    return [[NSDate alloc] initWithTimeIntervalSince1970:0];
}

-(NSTimeInterval)timeIntervalSince1970A
{
    return 1529033818l;
}

@end

@implementation NSObject (Deer)

- (UIViewController *)getCurrentVc{
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end



