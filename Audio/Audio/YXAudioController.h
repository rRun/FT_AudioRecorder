//
//  AudioController.h
//  Audio
//
//  Created by 成都富顿科技－向乾操 on 16/6/8.
//  Copyright © 2016年 成都富顿科技－向乾操. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "YXAudioModel.h"

typedef NS_ENUM(NSInteger, AudioEndType) {
    AudioEndType_TimeOut,// 超过设定的最大时间限制而终止
    AudioEndType_Interruption,// 意外中断
    AudioEndType_Normal// 正常停止
};

@interface YXAudioController : NSObject

#pragma mark - 属性
/// 当AVAudioRecorder对象初始化错误时，error保持了错误信息。默认为nil
@property (nonatomic, strong, readonly) NSError *error;
/// 最大的录音时间，默认为60s
@property (nonatomic, assign) CGFloat maxDuration;

#pragma mark - Methods
/// 单利初始化方法
+ (instancetype)shareInstance;
/// 开始录音
- (void)startRecording;
/// 结束录音
/// 返回已经存储到本地plist文件中的模型对象
- (YXAudioModel *)endRecording;
/// 当前的录音的音量，0到1之间
- (void)getVoiceProgressWithBlock:(void (^) (double progress))progressHandler;
/// 中止录音时调用
- (void)recordingInterruption:(void (^) (AudioEndType endType, AVAudioRecorder *recorder))handler;
/// 播放本地录音文件
- (void)playLocalRecordWithPath:(NSString *)path;
/// 停止播放录音文件
- (void)playerStop;

@end
