//
//  VoiceController.m
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/17.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import "VoiceController.h"
#import <AVFoundation/AVFoundation.h>

#import "VoiceRecorder.h"
#import "VoicePlayer.h"

@interface VoiceController ()

@property (nonatomic, strong) VoiceRecorder *recorder;
@property (nonatomic, strong) VoicePlayer *player;

@end

@implementation VoiceController

/// 创建文件夹
+ (void)load {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Audio"];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - VoiceRecorder
- (void)yx_startRecordingShouldSuccess:(void (^)(NSError *))success voicePercent:(void (^)(CGFloat))voice {
    if (!self.recorder.isRecording) {
        [self.recorder setRecordeFilePath:kPath];
        [self yx_playerStop];
    }
    [self.recorder startRecordingShouldSuccess:success voicePercent:voice];
}
- (void)yx_recodingStopWithInterruption:(void (^)(NSError *, BOOL))interruption {
    [self.recorder recodingStopWithInterruption:interruption];
}
- (void)yx_endRecordingWithInfo:(BOOL (^)(NSError *, NSTimeInterval, NSString *keyPath))info {
    [self.recorder endRecordingWithInfo:info];
}

#pragma mark - VoicePlayer
- (void)yx_playLocalRecordWithPath:(NSString *)path shouldSuccess:(void (^)(NSError *))success {
    [self.player playLocalRecordWithPath:path shouldSuccess:success];
}
- (void)yx_playerStop {
    [self.player playerStop];
}

#pragma mark - 数据处理
+ (void)getFileFromDocument:(void (^)(NSArray *))filesHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *string = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Audio"];
        NSMutableArray *arr = [NSMutableArray array];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:string error:nil]];
        for (NSString *path in tempFileList) {
            if ([[path substringWithRange:NSMakeRange(path.length-3, 3)] isEqualToString:@"aac"]) {
                [arr addObject:[string stringByAppendingPathComponent:path]];
            }
        }
        if (filesHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                filesHandler(arr);
            });
        }
    });
}
+ (void)deleteFileFromDocument {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *string = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Audio"];
        NSMutableArray *arr = [NSMutableArray array];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:string error:nil]];
        for (NSString *path in tempFileList) {
            if ([[path substringWithRange:NSMakeRange(path.length-3, 3)] isEqualToString:@"aac"]) {
                [arr addObject:[string stringByAppendingPathComponent:path]];
            }
        }
        for (NSString *fileName in arr) {
            [[NSFileManager defaultManager] removeItemAtPath:[string stringByAppendingPathComponent:fileName] error:nil];
        }
    });
}

#pragma mark - Getter&Setter
- (VoiceRecorder *)recorder {
    if (!_recorder) {
        _recorder = [VoiceRecorder new];
    }
    return _recorder;
}
- (VoicePlayer *)player {
    if (!_player) {
        _player = [VoicePlayer new];
        _player.needListenDistance = _needListenDistance;
    }
    return _player;
}

@end

