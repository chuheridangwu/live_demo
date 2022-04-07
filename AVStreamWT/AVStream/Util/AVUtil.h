//
//  AVUtil.h
//  AVStream
//
//  Created by gaoshuang  on 2018/5/2.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNMHelperProtocol.h"

typedef void (^NetObjLCallBackBlock)(BOOL rs, NSObject *obj);

@interface AVUtil : NSObject <CNMHelperProtocol>
- (NSString *)getVideoMergeFilePathString;
- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray callBack:(NetObjLCallBackBlock)callBack;

@end
