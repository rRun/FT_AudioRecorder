//
//  VoiceController.h
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/17.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

//typedef enum {
//    
//};

#define kPath [NSString stringWithFormat:@"%@/Audio/%@.aac",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],[NSDate date]]// 存放地址

@interface VoiceController : NSObject

/// 是否需要监听距离，如果是，当有东西靠近屏幕时会变成听筒播放，否则扬声器播放
/// 默认为NO
@property (nonatomic, assign) BOOL needListenDistance;
#pragma mark - recorder
/// 开始录音
/// success：监测录音功能是否开启成功的回调，如果开启失败，回调中的error不为nil，否则为nil
/// voice：监测录音开始后，音量大小的回调，如果开启失败，该回调并不会调用
- (void)yx_startRecordingShouldSuccess:(void (^) (NSError *error))success voicePercent:(void (^) (CGFloat percent))voice;

/// 录音意外中断
/// interruption：中断后的回调
- (void)yx_recodingStopWithInterruption:(void (^) (NSError *error, BOOL isBegin))interruption;

/// 结束录音
/// info：返回值表示是否删除录音文件，yes就删除
- (void)yx_endRecordingWithInfo:(BOOL (^) (NSError *error,NSTimeInterval timeDuration, NSString *keyPath))info;

#pragma mark - player
/// 播放本地路径的音频文件
/// path：本地路径
/// success：是否可以成功播放的回调，如果能够成功播放，error为nil
- (void)yx_playLocalRecordWithPath:(NSString *)path shouldSuccess:(void (^) (NSError *error))success;
/// 停止播放
- (void)yx_playerStop;

#pragma mark - 数据处理
/// 获取存放在录音文件夹的所有录音
+ (void)getFileFromDocument:(void (^) (NSArray *))filesHandler;
/// 删除所有录音文件
+ (void)deleteFileFromDocument;

@end
