//
//  ViewController.m
//  ZBRemotePlayerLib
//
//  Created by Mzhangzb on 20/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ViewController.h"
#import "ZBRemoteAudioPlayer.h"
@interface ViewController ()
//播放时长
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
//总时长
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
//缓存加载进度
@property (weak, nonatomic) IBOutlet UIProgressView *LoadingSchedule;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}




#pragma mark — 交互点击事件
//播放
- (IBAction)play:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
    [[ZBRemoteAudioPlayer shareInstance] playAudioWithURL:url];
}
//暂停
- (IBAction)pause:(id)sender {
    [[ZBRemoteAudioPlayer shareInstance] pause];
}
//继续播放
- (IBAction)resume:(id)sender {
    [[ZBRemoteAudioPlayer shareInstance] resume];
}
//快进、快退
- (IBAction)fastForward:(id)sender {
    [[ZBRemoteAudioPlayer shareInstance] seekWithTimeDiffer:15];
}
//播放进度
- (IBAction)setProgress:(UISlider *)sender {
     [[ZBRemoteAudioPlayer shareInstance] seekWithProgress:sender.value];
}
//播放速率
- (IBAction)setRate:(id)sender {
     [[ZBRemoteAudioPlayer shareInstance] setRate:2];
}
//静音
- (IBAction)setMuted:(UIButton *)sender {
    sender.selected = !sender.selected;
     [[ZBRemoteAudioPlayer shareInstance] setMuted: sender.selected];
}


- (IBAction)setVolume:(UISlider *)sender {
   [[ZBRemoteAudioPlayer shareInstance] setVolume:sender.value];
}






@end
