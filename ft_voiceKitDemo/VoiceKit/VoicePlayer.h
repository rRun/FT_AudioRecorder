//
//  VoicePlayer.h
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/17.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoicePlayer : NSObject

@property (nonatomic, assign) BOOL needListenDistance;
/// 播放本地路径的音频文件
/// path：本地路径
/// success：是否可以成功播放的回调，如果能够成功播放，error为nil
- (void)playLocalRecordWithPath:(NSString *)path shouldSuccess:(void (^) (NSError *error))success;
/// 停止播放
- (void)playerStop;

@end
