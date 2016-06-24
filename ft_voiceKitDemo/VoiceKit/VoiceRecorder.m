//
//  VoiceRecorder.m
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/17.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import "VoiceRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface VoiceRecorder () <AVAudioRecorderDelegate> {
    void (^_startSuccessHanlder) (NSError *error);
    void (^_voiceHandler)(CGFloat);
    BOOL (^_endInfoHandler)(NSError *error,NSTimeInterval timeDuration, NSString *keyPath);
    void (^_recordingInterruption)(NSError *, BOOL isBegin);
    NSTimer *_timer;
    CGFloat _timerDuration;
}

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, copy) NSString *recordeFilePath;// 录音文件存放位置，绝对路径

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;// 音频录音机

@end

@implementation VoiceRecorder

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (_endInfoHandler && flag) {
        if (_endInfoHandler(nil,_timerDuration,_recordeFilePath)) {
            [recorder deleteRecording];
        }
        [self resetToPreparRecord];
    }
}
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    if (_recordingInterruption) {
        NSError *intteruptionError = [NSError errorWithDomain:NSStringFromSelector(_cmd) code:-10002 userInfo:@{NSLocalizedDescriptionKey:@"recorder is begin interruption."}];
        _recordingInterruption(intteruptionError,NO);
    }
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags {
    if (_recordingInterruption) {
        NSError *intteruptionError = [NSError errorWithDomain:NSStringFromSelector(_cmd) code:-10002 userInfo:@{NSLocalizedDescriptionKey:@"recorder is end interruption."}];
        _recordingInterruption(intteruptionError,YES);
    }
}
#pragma mark - Public
- (void)startRecordingShouldSuccess:(void (^) (NSError *error))success voicePercent:(void (^)(CGFloat))voice {
    if (!self.audioRecorder.isRecording) {
        _startSuccessHanlder = success;
        _voiceHandler = voice;
        // 设置为录音模式
        AVAudioSession * session = [AVAudioSession sharedInstance];
        NSError * sessionError;
        [session setCategory:AVAudioSessionCategoryRecord error:&sessionError];
        [session setActive:YES error:nil];
        // 开始录音
        [_audioRecorder prepareToRecord];
        [_audioRecorder record];
        // 开始定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doChangeVoicePower:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else {
        // 如果正在录音，则回调一个自定义错误信息
        NSError *isRecordingError = [NSError errorWithDomain:NSStringFromSelector(_cmd) code:-10000 userInfo:@{NSLocalizedDescriptionKey:@"recorder is recording."}];
        if (success) {
            success(isRecordingError);
        }
    }
}
- (void)recodingStopWithInterruption:(void (^)(NSError *, BOOL isBegin))interruption {
    _recordingInterruption = interruption;
}
- (void)endRecordingWithInfo:(BOOL (^)(NSError *error,NSTimeInterval timeDuration, NSString *keyPath))info {
    if (_audioRecorder.isRecording) {
        _endInfoHandler = info;
        // 设置为播放模式
        AVAudioSession * session = [AVAudioSession sharedInstance];
        NSError * sessionError;
        [session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        [session setActive:YES error:nil];
        // 结束录音
        [_audioRecorder stop];
        // 停止计时器
        [_timer invalidate];
        _timer = nil;
    }else {
        // 如果当前并没有录音
        NSError *infoError = [NSError errorWithDomain:NSStringFromSelector(_cmd) code:-10001 userInfo:@{NSLocalizedDescriptionKey:@"recorder is not start."}];
        if (info) {
            info(infoError,0,nil);
        }
    }
}
#pragma mark - Private
/// 重置所有变量，以便下次录制
- (void)resetToPreparRecord {
    _endInfoHandler      = nil;
    _startSuccessHanlder = nil;
    _voiceHandler        = nil;
    _audioRecorder       = nil;
}
/// 每0.1秒更新一次音量的测量值
- (void)doChangeVoicePower:(NSTimer *)timer {
    [_audioRecorder updateMeters];
    _timerDuration += 0.1;
    CGFloat voice = [_audioRecorder averagePowerForChannel:0]+160;// 分贝从-160到0dB
    if (_voiceHandler) {
        _voiceHandler(voice);
    }
}
/// 取得录音文件设置
- (NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
    //kAudioFormatLinearPCM
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    return dicM;
}
#pragma mark - Getter&Setter
- (AVAudioRecorder *)audioRecorder {
    _timerDuration = 0;
    if (!_recordeFilePath) {
        return nil;
    }
    if (!_audioRecorder) {
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordeFilePath] settings:[self getAudioSetting] error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        if (_startSuccessHanlder) {
            _startSuccessHanlder(error);
        }
        if (error) {
            return nil;
        }
    }
    return _audioRecorder;
}
- (void)setRecordeFilePath:(NSString *)recordeFilePath {
    _recordeFilePath = [recordeFilePath copy];
}
- (BOOL)isRecording {
    return _audioRecorder.isRecording;
}

@end
