//
//  DeerTools.m
//  DeerLive
//
//  Created by 鹿容 on 2019/6/20.
//  Copyright © 2019 Deer. All rights reserved.
//

#import "WT2Tools.h"

#import <objc/runtime.h>

#import <sys/utsname.h>

#import <AdSupport/AdSupport.h>


#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <arpa/inet.h>




@implementation WT2Tools

+(instancetype)instance
{
    static WT2Tools *tools;
    if (!tools) {
        tools = [[WT2Tools alloc] init];
    }
    return tools;
}

- (int)networkType{
    if (self.localIPInfo[@"isp_nu"]){
        return [self.localIPInfo[@"isp_nu"] intValue];
    }
    if(self.localIPInfo[@"isp_id"]){
        return [self.localIPInfo[@"isp_id"] intValue];
    }
    return 3;// 默认电信
}

+(BOOL)iPhoneX
{
    NSString *deviceName = [WT2Tools deviceName];
    return [deviceName isEqualToString:@"iPhone X"] || [deviceName isEqualToString:@"iPhone XS"]
    || [deviceName isEqualToString:@"iPhone XS Max"]
    || [deviceName isEqualToString:@"iPhone XR"];
    
    // return YES;
}

// 获取设备型号然后手动转化为对应名称
+(NSString*)deviceName
{
    
    // return @"国行(A1864)、日行(A1898)iPhone 8";
    
    // 需要#import "sys/utsname.h"
    //#warning 题主呕心沥血总结！！最全面！亲测！全网独此一份！！
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])    return @"iPad 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad6,12"])    return @"iPad 5 (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,1"])     return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])     return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])     return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])     return @"iPad Pro 10.5 inch (Cellular)";
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    
    
    return deviceString;
}

+(NSString *)languageCode
{
    NSDictionary *data = @{
                           @"en":@"en",
                           @"zh-Hans":@"zh-CN",
                           @"zh-Hant":@"zh-TW",
                           @"zh-HK":@"zh-HK",
                           };
    
    NSString *localeLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if (localeLanguageCode){
        NSString *code = data[localeLanguageCode.lowercaseString];
        return code ? code : localeLanguageCode;
    }
    return @"";
}

+(NSString *)countryCode
{
    // 优先使用用户注册时的countrycode
//    if ([SSWebClientManager defaultWebClient].currentUserItem.countyCode
//        && [SSWebClientManager defaultWebClient].currentUserItem.countyCode.length > 0){
//        return [SSWebClientManager defaultWebClient].currentUserItem.countyCode;
//    }
    NSString *localeCountryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (localeCountryCode){
        return localeCountryCode;
    }
    return  @"";
}

+(id)jsonStringToObject:(NSString *)string
{
    return [WT2Tools jsonDataToObject:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

static id jsonDeleteNullValues(id JSONObject, NSJSONReadingOptions readingOptions)
{
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)JSONObject count]];
        for (id value in (NSArray *)JSONObject) {
            [mutableArray addObject:jsonDeleteNullValues(value, readingOptions)];
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:JSONObject];
        for (id <NSCopying> key in [(NSDictionary *)JSONObject allKeys]) {
            id value = [(NSDictionary *)JSONObject objectForKey:key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                [mutableDictionary setObject:jsonDeleteNullValues(value, readingOptions) forKey:key];
            }
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    
    return JSONObject;
}

+(id)jsonDataToObject:(NSData *)data
{
    NSError *error = nil;
    NSJSONReadingOptions options = NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if (error) {
        return nil;
    }
    return jsonDeleteNullValues(jsonObject,options);
}

+(NSData *)jsonDataFromObject:(NSObject *)object
{
    if (![NSJSONSerialization isValidJSONObject:object]) {
        NSLog(@"JSON序列化出错--->error:存在非法数据类型");return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {
        NSLog(@"JSON序列化出错--->error:%@",error);
    }
    return jsonData;
}
+(NSString *)jsonStringFromObject:(NSObject *)object
{
    return [[NSString alloc] initWithData:[WT2Tools jsonDataFromObject:object] encoding:NSUTF8StringEncoding];
}

+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+(long)timestamp
{
    NSDate *dateNow = [NSDate date];
    long timestamp = (long)[dateNow timeIntervalSince1970];
    return timestamp;
}

+(char*)NSString2Char:(NSString *)aString{
    if (!aString){
        aString = @"";
    }
    char *charString = (char*)[aString UTF8String];
    return charString;
}

+(NSString*)char2NSString:(char *)aChar{
    NSString *theString = [NSString stringWithUTF8String:aChar];
    if (!theString)
    {
        return @"";
    }
    return theString;
}

+(void)changeMethodWithModel:(Class)c sel:(SEL)origSEL newSel:(SEL)newSEL
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = class_getInstanceMethod(c, newSEL);
    
    if(class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

+(void)changeStaticMethodWithModel:(Class) clazz sel:(SEL) origSEL newSel:(SEL) newSEL
{
    //获取替换前的类方法
    Method instance_eat =
    class_getClassMethod(clazz, origSEL);
    //获取替换后的类方法
    Method instance_notEat =
    class_getClassMethod(clazz, newSEL);
    
    //然后交换类方法
    method_exchangeImplementations(instance_eat, instance_notEat);
}

+(NSString*)stringTrimAlabo:(NSString *)string
{
    __block NSMutableString *retString = [[NSMutableString alloc] init];
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if((hs>=0x0600 && hs<=0x06FF) ||(hs>=0x0750 && hs<=0x077F) || (hs>=0xFB50 && hs<=0xFDFF) || (hs>=0xFE70 && hs<=0xFEFF)||hs == 8206) // 8206 是空格还是空字符啊，反正显示不出来，去掉 lm 16.11.24
                                {
                                    //returnValue = YES;
                                }
                                else
                                {
                                    [retString appendString:substring];
                                }
                            }];
    
    [retString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return retString;
}

+(NSString *)getLocalPathWithName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    docDir = [docDir stringByAppendingFormat:@"/%@/",name];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return docDir;
}

+(NSString *)filePathWithUrl:(NSString *)url pathName:(NSString *)name
{
    
    return @"";
//    NSString* strPath = [self getLocalPathWithName:name];
//    NSString *fileName = [NSString stringWithFormat:@"%@.%@",[WT2Encryption MD5FromString:url],[[NSURL URLWithString:url].path pathExtension]];
//
//    fileName = [NSString stringWithFormat:@"%@%@",strPath,fileName];
//
//    return fileName;
}

+ (BOOL)exchagebool2BOOL:(bool)abool
{
    BOOL theBool = YES;
    if (abool == 0)
    {
        theBool = NO;
    }
    return theBool;
}

+ (NSData *)compressImage:(NSString *)path
            scaledToSize:(CGSize)newSize
      compressionQuality:(CGFloat)compressionQuality
{
    return nil;
//    @autoreleasepool{
//        UIImage *oldImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:path];
//        UIGraphicsBeginImageContext(newSize);
//        [oldImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        NSData * imageData = UIImageJPEGRepresentation(newImage, compressionQuality);
//        newImage = nil;
//        oldImage = nil;
//        return imageData;
//    }
}

+ (BOOL)compressImage:(NSString *)path
         scaledToSize:(CGSize)newSize
   compressionQuality:(CGFloat)compressionQuality
    outputMaxFileSize:(NSUInteger)fileSize
{
    return NO;
//    @autoreleasepool{
//        UIImage *oldImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:path];
//        UIGraphicsBeginImageContext(newSize);
//        [oldImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        NSData * imageData = UIImageJPEGRepresentation(newImage, compressionQuality);
//        newImage = nil;
//        oldImage = nil;
//        return imageData.length < fileSize;
//
//    }
}

// 获取当前时间戳(以秒为单位)
+ (NSNumber *)getNowTimeTimestamp {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return [NSNumber numberWithInteger:[timeSp integerValue]];
}

// 根据出生日期返回年龄
+ (NSString *)dateToOld:(NSDate *)bornDate{
    //获得当前系统时间
    NSDate *currentDate = [NSDate date];
    //获得当前系统时间与出生日期之间的时间间隔
    NSTimeInterval time = [currentDate timeIntervalSinceDate:bornDate];
    //时间间隔以秒作为单位,求年的话除以60*60*24*356
    int age = ((int)time)/(3600*24*365);
    return [NSString stringWithFormat:@"%d",age];
}

// 字符串转时间date
+ (NSDate *)strToDateWithDateStr:(NSString *)dateStr {
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [inputFormatter dateFromString:dateStr];
    return date;
}

@end
