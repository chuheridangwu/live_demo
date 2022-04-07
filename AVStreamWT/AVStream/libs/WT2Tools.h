//
//  DeerTools.h
//  DeerLive
//
//  Created by 鹿容 on 2019/6/20.
//  Copyright © 2019 Deer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static id jsonDeleteNullValues(id JSONObject, NSJSONReadingOptions readingOptions);

typedef NS_ENUM(NSInteger, NetWorkStatusType)
{
    NetWorkStatusType_no = 0,                //无网络
    NetWorkStatusType_wifi = 1,                //wifi
    NetWorkStatusType_other//2g 3g
};

@interface WT2Tools : NSObject

@property (nonatomic, strong)NSDictionary *localIPInfo;
@property (nonatomic, assign)int networkType;

+(instancetype)instance;

// 获取设备型号然后手动转化为对应名称
+(NSString*)deviceName;

+(BOOL)iPhoneX;

+(NSString *)languageCode;

+(NSString *)countryCode;

+(id)jsonStringToObject:(NSString *)string;

+(id)jsonDataToObject:(NSData *)data;

+(NSData *)jsonDataFromObject:(NSObject *)object;
+(NSString *)jsonStringFromObject:(NSObject *)object;

+ (NSString *)appVersion;

+(char*)NSString2Char:(NSString *)aString;

+(NSString*)char2NSString:(char *)aChar;

+ (BOOL)exchagebool2BOOL:(bool)abool;

+(void)changeMethodWithModel:(Class)c sel:(SEL)origSEL newSel:(SEL)newSEL;

+(void)changeStaticMethodWithModel:(Class) clazz sel:(SEL) origSEL newSel:(SEL) newSEL;

+(NSString*)stringTrimAlabo:(NSString *)string;

+(NSString *)getLocalPathWithName:(NSString *)name;

+(NSString *)filePathWithUrl:(NSString *)url pathName:(NSString *)name;

+ (long)timestamp;

+ (NSData *)compressImage:(NSString *)path
             scaledToSize:(CGSize)newSize
       compressionQuality:(CGFloat)compressionQuality;

+ (BOOL)compressImage:(NSString *)path
         scaledToSize:(CGSize)newSize
   compressionQuality:(CGFloat)compressionQuality
    outputMaxFileSize:(NSUInteger)fileSize;

// 获取当前时间戳(以秒为单位)
+ (NSNumber *)getNowTimeTimestamp;

// 根据出生日期返回年龄
+ (NSString *)dateToOld:(NSDate *)bornDate;

// 字符串转时间date
+ (NSDate *)strToDateWithDateStr:(NSString *)dateStr;



@end

NS_ASSUME_NONNULL_END
