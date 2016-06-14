//
//  AudioModel.m
//  Audio
//
//  Created by 成都富顿科技－向乾操 on 16/6/12.
//  Copyright © 2016年 成都富顿科技－向乾操. All rights reserved.
//

#import "YXAudioModel.h"

#define Plist_File_Local_Path [NSString stringWithFormat:@"%@/AudioRecord",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]]// 存放的本地路径
#define PlistFile @"AudioModel.plist"

@interface YXAudioModel ()

@property (nonatomic, copy) NSString *plist;
@property (nonatomic, strong) NSDate *date;

@end

@implementation YXAudioModel

+ (void)initialize {
    NSString *plist = [Plist_File_Local_Path stringByAppendingPathComponent:PlistFile];// plist 的本地路径
    if (![[NSFileManager defaultManager] fileExistsAtPath:plist]) {
        [[NSFileManager defaultManager] createFileAtPath:plist contents:nil attributes:nil];
        NSMutableArray *arr = [NSMutableArray array];
        [arr writeToFile:plist atomically:YES];
    }else {
        NSLog(@"文件已存在");
    }
}
+ (NSArray<YXAudioModel *> *)allRecordFile {
    NSString *plist = [Plist_File_Local_Path stringByAppendingPathComponent:PlistFile];// plist 的本地路径
    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:plist];
    NSMutableArray *retVlaue = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        YXAudioModel *model  = [YXAudioModel new];
        model.url            = dict[@"url"];
        [model setValue:dict[@"date"] forKey:@"date"];
        model.localPath      = dict[@"path"];
        model.timeDuration   = [dict[@"duration"] doubleValue];
        [retVlaue addObject:model];
    }
    return retVlaue;
}
+ (void)deleteRecordFileWithTypeInterval:(NSInteger)dayInterval complete:(void (^) (NSString *))comp {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *plist = [Plist_File_Local_Path stringByAppendingPathComponent:PlistFile];// plist 的本地路径
        __block NSMutableArray *deleteItems = [NSMutableArray array];
        NSDate *currentDate = [NSDate date];// 当前时间的date对象
        NSMutableArray *arr = [[[NSMutableArray alloc] initWithContentsOfFile:plist] mutableCopy];
        for (NSDictionary *dict in arr) {
            NSDate *saveDate = dict[@"date"];// 存储时间
            NSTimeInterval disTime = [currentDate timeIntervalSinceDate:saveDate];
            double day = disTime/(3600*24);
            if (day>=dayInterval) {
                [deleteItems addObject:dict];
            }
        }
        [arr removeObjectsInArray:deleteItems];
        if ([arr writeToFile:plist atomically:YES] && comp) {
            comp([NSString stringWithFormat:@"%s:success",__func__]);
        }else if (comp) {
            comp([NSString stringWithFormat:@"%s:failed",__func__]);
        }
    });
}
+ (void)deleteAllFileComplete:(void (^)(NSString *))comp {
    NSString *plist = [Plist_File_Local_Path stringByAppendingPathComponent:PlistFile];// plist 的本地路径
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *arr = [[[NSMutableArray alloc] initWithContentsOfFile:plist] mutableCopy];
        for (NSDictionary *dict in arr) {
            NSString *localPath = dict[@"localPath"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:localPath error:&error];
                if (error) {
                    NSLog(@"__%s:%@",__func__,error);
                }
            }
        }
        [arr removeAllObjects];
        if ([arr writeToFile:plist atomically:YES] && comp) {
            comp([NSString stringWithFormat:@"%s:success",__func__]);
        }else if (comp) {
            comp([NSString stringWithFormat:@"%s:failed",__func__]);
        }
    });
}
+ (void)deleteFileWithLocalPath:(NSString *)path complete:(void (^)(NSString *))comp {
    NSString *plist = [Plist_File_Local_Path stringByAppendingPathComponent:PlistFile];// plist 的本地路径
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *arr = [[[NSMutableArray alloc] initWithContentsOfFile:plist] mutableCopy];
        __block NSDictionary *findDict = nil;
        for (NSDictionary *dict in arr) {
            NSString *localPath = dict[@"localPath"];
            if (![localPath isEqualToString:path]) continue;
            if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:localPath error:&error];
                if (error) {
                    NSLog(@"__%s:%@",__func__,error);
                }else {
                    findDict = dict;
                }
                break;
            }
        }
        if (findDict) {
            [arr removeObject:findDict];
        }
        if ([arr writeToFile:plist atomically:YES] && comp) {
            comp([NSString stringWithFormat:@"%s:success",__func__]);
        }else if (comp) {
            comp([NSString stringWithFormat:@"%s:failed",__func__]);
        }
    });
}
- (void)saveToPlistComplete:(void (^)(NSString *errorInfo))comp {
    self.date = [NSDate date];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *dict = @{@"url":self.url,
                               @"duration":@(self.timeDuration),
                               @"path":self.localPath,
                               @"date":self.date
                               };
        NSMutableArray *arr = [[[NSMutableArray alloc] initWithContentsOfFile:self.plist] mutableCopy];
        [arr addObject:dict];
        if ([arr writeToFile:self.plist atomically:YES] && comp) {
            comp([NSString stringWithFormat:@"%s:success",__func__]);
        }else if (comp) {
            comp([NSString stringWithFormat:@"%s:failed",__func__]);
        }
    });
}
- (void)removeItemComplete:(void (^)(NSString *))comp {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *arr = [[[NSMutableArray alloc] initWithContentsOfFile:self.plist] mutableCopy];
        BOOL findItem = NO;
        for (NSDictionary *dict in arr) {
            NSString *localPath = dict[@"localPath"];
            if (![self.localPath isEqualToString:localPath]) continue;
            if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:localPath error:&error];
                if (error) {
                    NSLog(@"__%s:%@",__func__,error);
                }else {
                    findItem = YES;
                }
                break;
            }
        }
        if (findItem) {
            [arr removeObject:self];
        }
        if ([arr writeToFile:self.plist atomically:YES] && comp) {
            comp([NSString stringWithFormat:@"%s:success",__func__]);
        }else if (comp) {
            comp([NSString stringWithFormat:@"%s:failed",__func__]);
        }
    });
}
#pragma mark - Getter&Setter
- (NSString *)url {
    if (!_url) _url = @"";
    return _url;
}
- (NSString *)plist {
    if (!_plist) _plist = [Plist_File_Local_Path stringByAppendingPathComponent:PlistFile];
    return _plist;
}

@end
