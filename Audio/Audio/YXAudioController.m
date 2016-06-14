//
//  AudioController.m
//  Audio
//
//  Created by 成都富顿科技－向乾操 on 16/6/8.
//  Copyright © 2016年 成都富顿科技－向乾操. All rights reserved.
//

#import "YXAudioController.h"
#import <CoreMedia/CoreMedia.h>

typedef NS_ENUM(NSInteger, AudioState) {
    AudioState_Recording,// 正在录音
    AudioState_Ending,// 录音停止状态
    AudioState_Playing// 正常播放
};

#define kRecordAudioFile [NSString stringWithFormat:@"%@.aac",[NSDate date]]

@interface YXAudioController () <AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;// 音频录音机
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSString *recordFilePath;
@property (nonatomic, copy) void (^voiceProgressHandler) (CGFloat progress);
@property (nonatomic, copy) void (^recordInterruptionHandler) (AudioEndType endType ,AVAudioRecorder *record);
@property (nonatomic, strong) NSTimer *timer;// 定时器，用于刷新音量，没0.1秒刷新一次
@property (nonatomic, assign) NSInteger recordTimeInterval;// 用于判断当前录音是否达到最大限制
@property (nonatomic, assign) AudioEndType endType;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;// 用于播放录音文件
@property (nonatomic, assign) AudioState state;// 音频状态，默认为Ending

@end

@implementation YXAudioController

+ (void)load {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *createPath = [NSString stringWithFormat:@"%@/AudioRecord", pathDocuments];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![fileManager fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"FileDir is exists.");
    }
}

#pragma mark - Instance Methods
static YXAudioController *instance = nil;
+ (instancetype)shareInstance {
    return [[self alloc] init];
}

#pragma mark - init
- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance         = [super init];
            instance.state   = AudioState_Ending;
            instance.endType = AudioEndType_Normal;
        }
    });
    return instance;
}

#pragma mark - Public Methods
- (void)startRecording {
    if (self.state == AudioState_Recording) {
        NSLog(@"正在录音中，请勿重复操作");
        return;
    }
    if (self.state == AudioState_Playing) {
        [self playerStop];
    }
    self.state = AudioState_Recording;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError * sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder record];
    self.recordTimeInterval = 0;
    self.timer              = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(audioPowerChange)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer
                              forMode:NSRunLoopCommonModes];
}
- (YXAudioModel *)endRecording {
    if (self.state != AudioState_Recording) {
        NSAssert(NO, @"当前并没有录音，请录音开始后再停止");
        return nil;
    }
    self.state = AudioState_Ending;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError * sessionError;
    [session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    [self.audioRecorder stop];
    [self.timer invalidate];
    
    YXAudioModel *model  = [YXAudioModel new];
    model.localPath      = self.recordFilePath;
    model.timeDuration   = self.recordTimeInterval/10;
    [model saveToPlistComplete:^(NSString *errorInfo) {
        NSLog(@"%@",errorInfo);
    }];
    if (self.recordInterruptionHandler) {
        self.recordInterruptionHandler(_endType,self.audioRecorder);
    }
    self.audioRecorder = nil;
    self.timer         = nil;
    return model;
}
- (void)playLocalRecordWithPath:(NSString *)path {
    NSString *urlStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"AudioRecord/%@",path]];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.state = AudioState_Playing;
            });
            self.audioPlayer.numberOfLoops = 0;
            self.audioPlayer.volume = 1;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }else {
            NSLog(@"__%s:%@",__func__,error.localizedDescription);
        }
    });
}
- (void)playerStop {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}
- (void)getVoiceProgressWithBlock:(void (^)(double))progressHandler {
    self.voiceProgressHandler = progressHandler;
}
- (void)recordingInterruption:(void (^)(AudioEndType endType ,AVAudioRecorder *))handler {
    self.recordInterruptionHandler = handler;
}

#pragma mark - Private Methods
/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
- (NSURL *)getSavePath{
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr           = [urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"AudioRecord/%@",self.recordFilePath]];
    NSURL *url       = [NSURL fileURLWithPath:urlStr];
    return url;
}
/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
//    kAudioFormatLinearPCM
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
/**
 *  录音声波状态设置
 */
- (void)audioPowerChange {
    [self.audioRecorder updateMeters];//更新测量值
    if (self.recordTimeInterval > 10 * self.maxDuration) {
        _endType = AudioEndType_TimeOut;
        [self endRecording];
    }else ++ self.recordTimeInterval;
    float power      = [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress = (1.0/160.0)*(power+160.0);
    if (self.voiceProgressHandler) {
        self.voiceProgressHandler(progress);
    }
}

#pragma mark - AVAudioRecorderDelegate
// 录音正常完成时调用
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"%s:录音成功保存，保存路径为：%@",__func__,self.recordFilePath);
}

// 录音被干扰中断时调用
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    NSLog(@"%s",__func__);
    _endType = AudioEndType_Interruption;
    if (self.recordInterruptionHandler) {
        self.recordInterruptionHandler(_endType,recorder);
    }
}

#pragma mark - Getter&Setter
- (CGFloat)maxDuration {
    if (!_maxDuration) _maxDuration = 60;
    return _maxDuration;
}
- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        self.recordFilePath            = kRecordAudioFile;
        self.error                     = nil;
        NSError *error                 = nil;
        _audioRecorder                 = [[AVAudioRecorder alloc] initWithURL:[self getSavePath] settings:[self getAudioSetting] error:&error];
        _audioRecorder.meteringEnabled = YES;// 监测声波
        _audioRecorder.delegate        = self;
        self.error                     = error;
        if (self.error) {
            return nil;
        }
    }
    return _audioRecorder;
}

@end
