//
//  VoicePlayer.m
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/17.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import "VoicePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "ProximitySensor.h"

@interface VoicePlayer () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;// 用于播放录音文件
@property (nonatomic, strong) ProximitySensor *proSen;// 监听距离
@property (nonatomic, assign) BOOL shouldDistance;

@end

@implementation VoicePlayer

- (void)playLocalRecordWithPath:(NSString *)path shouldSuccess:(void (^) (NSError *error))success {
    NSURL *url = [NSURL fileURLWithPath:path];
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(outputDeviceChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.delegate = self;
        if (!error) {
            if (self.needListenDistance && ![self isHeadsetPluggedIn]) {
                [self.proSen yx_listeningProSenWithState:^(BOOL proximityState) {
                    if (proximityState) {
                        // 黑屏时，用听筒播放
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
                        [[AVAudioSession sharedInstance] setActive:YES error:nil];
                    }else {
                        // 不为黑屏时，用扬声器播放
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                        [[AVAudioSession sharedInstance] setActive:YES error:nil];
                    }
                }];
            }
            self.audioPlayer.numberOfLoops = 0;
            self.audioPlayer.volume = 1;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(error);
            }
        });
    });
}
- (void)playerStop {
    if (self.audioPlayer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (self.needListenDistance) {
            [self.proSen yx_stopProSen];
        }
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}

#pragma mark - 通知方法
- (void)outputDeviceChanged:(NSNotification *)aNotification {
    NSInteger type = [aNotification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];// 1.插耳机 2.拔耳机
    if (type == 1) {
        if (self.needListenDistance) {
            [self.proSen yx_stopProSen];
        }
    }else if (type == 2) {
        if (self.needListenDistance) {
            [self.proSen yx_listeningProSenWithState:^(BOOL proximityState) {
                if (proximityState) {
                    // 黑屏时，用听筒播放
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
                    [[AVAudioSession sharedInstance] setActive:YES error:nil];
                }else {
                    // 不为黑屏时，用扬声器播放
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                    [[AVAudioSession sharedInstance] setActive:YES error:nil];
                }
            }];
        }
    }
}
/// 监测当前耳机状态，YES为插入耳机
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self playerStop];
}

#pragma mark - Setter&Getter
- (ProximitySensor *)proSen {
    if (!_proSen) {
        _proSen = [ProximitySensor new];
    }
    return _proSen;
}


- (void)dealloc {
    [self playerStop];
}

@end
