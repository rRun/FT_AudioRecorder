//
//  ProximitySensor.h
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/21.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProximitySensor : NSObject

- (void)yx_listeningProSenWithState:(void (^) (BOOL proximityState))stateHandler;
- (void)yx_stopProSen;

@end
