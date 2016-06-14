//
//  AudioModel.h
//  Audio
//
//  Created by 成都富顿科技－向乾操 on 16/6/12.
//  Copyright © 2016年 成都富顿科技－向乾操. All rights reserved.
//

/*
  @{@"url":self.url,
    @"duration":@(self.timeDuration),
    @"path":self.localPath,
    @"date":self.date
    }
*/

#import <Foundation/Foundation.h>

@interface YXAudioModel : NSObject

/// 如果上传成功，用于保存服务器返回的url
@property (nonatomic, copy) NSString *url;
/// 文件的本地相对路径路径，也就是文件的名字
@property (nonatomic, copy) NSString *localPath;
/// 录制的时间长度
@property (nonatomic, assign) double timeDuration;
/// 存储时间
@property (nonatomic, strong, readonly) NSDate *date;

/// 获取本地的所有录音文件
+ (NSArray <__kindof YXAudioModel *> *)allRecordFile;
#pragma mark - 以下的回调在子线程中执行
/// 保存到plist文件中
- (void)saveToPlistComplete:(void (^) (NSString *errorInfo))comp;
/// 删除某个具体的模型对象
- (void)removeItemComplete:(void (^) (NSString *errorInfo))comp;
/// 根据时间来删除，dayInterval表示多久以后就删除单位为天
+ (void)deleteRecordFileWithTypeInterval:(NSInteger)dayInterval complete:(void (^) (NSString *))comp;
/// 删除所有文件
+ (void)deleteAllFileComplete:(void (^) (NSString *errorInfo))comp;
/// 删除指定文件
+ (void)deleteFileWithLocalPath:(NSString *)path complete:(void (^) (NSString *errorInfo))comp;

@end
