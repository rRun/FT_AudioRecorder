//
//  ProximitySensor.m
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/21.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import "ProximitySensor.h"
#import <UIKit/UIKit.h>

@interface ProximitySensor () {
    void (^_state) (BOOL);
}

@end

@implementation ProximitySensor

- (void)yx_listeningProSenWithState:(void (^)(BOOL))stateHandler {
    // 开启距离感应功能
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    if ([UIDevice currentDevice].isProximityMonitoringEnabled) {
        _state = stateHandler;
        // 监听距离感应的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(proximityChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }else {
        NSLog(@"当前设备不支持距离感应");
    }
}
- (void)yx_stopProSen {
    if ([UIDevice currentDevice].isProximityMonitoringEnabled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}
/// 监听方法
- (void)proximityChange:(NSNotification *)aNotice {
    if (_state) {
        _state([UIDevice currentDevice].proximityState);
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
