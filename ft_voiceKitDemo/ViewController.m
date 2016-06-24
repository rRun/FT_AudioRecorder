//
//  ViewController.m
//  ft_voiceKitDemo
//
//  Created by 成都富顿科技－向乾操 on 16/6/17.
//  Copyright © 2016年 yxiang. All rights reserved.
//

#import "ViewController.h"
#import "VoiceController.h"

@interface ViewController () {
    NSMutableArray *_dataSource;
}

@property (weak, nonatomic) IBOutlet UIProgressView *pro;
@property (nonatomic, strong) VoiceController *voice;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation ViewController
- (VoiceController *)voice {
    if (!_voice) {
        _voice = [[VoiceController alloc] init];
        _voice.needListenDistance = YES;
    }
    return _voice;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    _dataSource = [NSMutableArray array];
    [VoiceController getFileFromDocument:^(NSArray *arr) {
        _dataSource = [arr mutableCopy];
        [weakSelf.mainTableView reloadData];
    }];
}
- (IBAction)start:(id)sender {
    __weak typeof(self)weakSelf = self;
    [self.voice yx_startRecordingShouldSuccess:^(NSError *error) {
        NSLog(@"%@",error);
    } voicePercent:^(CGFloat percent) {
        [weakSelf.pro setProgress:percent/160];
    }];
}
- (IBAction)end:(id)sender {
    __weak typeof(self)weakSelf = self;
    [self.voice yx_endRecordingWithInfo:^BOOL(NSError *error, NSTimeInterval timeDuration, NSString *keyPath) {
        NSLog(@"error = %@, timeDuration = %f, keyPath = %@",error,timeDuration,keyPath);
        if (!error) {
            [_dataSource addObject:keyPath];
            [weakSelf.mainTableView reloadData];
        }
        return NO;
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _dataSource[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.voice yx_playLocalRecordWithPath:_dataSource[indexPath.row] shouldSuccess:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

@end
