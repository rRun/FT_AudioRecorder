//
//  VoiceRecorder.h
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/17.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface VoiceRecorder : NSObject

/// 是否在录音状态
@property (nonatomic, assign, readonly) BOOL isRecording;
/// 设置录音文件的绝对地址
/// 每次开始录音前，需要先设置它的文件位置
- (void)setRecordeFilePath:(NSString *)recordeFilePath;

/// 开始录音
/// success：监测录音功能是否开启成功的回调，如果开启失败，回调中的error不为nil，否则为nil
/// voice：监测录音开始后，音量大小的回调，如果开启失败，该回调并不会调用
- (void)startRecordingShouldSuccess:(void (^) (NSError *error))success voicePercent:(void (^) (CGFloat percent))voice;

/// 录音意外中断
/// interruption：中断后的回调
- (void)recodingStopWithInterruption:(void (^) (NSError *error, BOOL isBegin))interruption;

/// 结束录音
/// info：返回值表示是否删除录音文件，yes就删除
- (void)endRecordingWithInfo:(BOOL (^) (NSError *error,NSTimeInterval timeDuration, NSString *keyPath))info;

@end
