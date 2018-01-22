//
//  ZBRemoteAudioPlayer.m
//  ZBRemotePlayerLib
//
//  Created by Mzhangzb on 20/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ZBRemoteAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface ZBRemoteAudioPlayer ()
@property (nonatomic,strong) AVPlayer *player ;
@end

@implementation ZBRemoteAudioPlayer
static ZBRemoteAudioPlayer * _shareInstance;

+ (instancetype)shareInstance{
    if (!_shareInstance) {
        _shareInstance = [[ZBRemoteAudioPlayer alloc]init];
    }
    return _shareInstance;
    
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_shareInstance) {
        static dispatch_once_t onceToke;
        dispatch_once(&onceToke, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (void)playAudioWithURL:(NSURL *)url{
    
    // 创建一个播放器对象
    // 1. 资源的请求
    // 2. 资源的组织
    // 3. 给播放器, 资源的播放
    // 如果资源加载比较慢, 有可能, 会造成调用了play方法, 但是当前并没有播放音频 playerWithURL
    
    // 1. 资源的请求
    AVURLAsset * asset = [AVURLAsset assetWithURL:url];
    // 2. 资源的组织
    AVPlayerItem * item = [AVPlayerItem playerItemWithAsset:asset];
    // 当资源的组织者, 告诉我们资源准备好了之后, 我们再播放  : AVPlayerItemStatus
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 3. 资源的播放
    self.player = [AVPlayer playerWithPlayerItem:item];
    
//    [player play];
}



// 继续
- (void)resume{
    [self.player play];
}

// 暂停
- (void)pause{
    [self.player pause];
}

/**
 根据时间差, 完成快进10秒, 或者快退10秒的操作
 
 @param timeDiffer 时间差(正负)
 */
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer{
    //当前音频的总时长，已经播放的时长
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);
    //当前播放时长
    CMTime playTime  = self.player.currentItem.currentTime;
    
    NSTimeInterval playeTimeSec = CMTimeGetSeconds(playTime);
    playeTimeSec += timeDiffer;
    [self seekWithProgress: playeTimeSec / totalTimeSec ];
    
}

/**
 改变当前播放的速率
 
 @param rate 速率(0.5 半速, 1.0 正常, 2.0两倍速)
 */
- (void)setRate:(float)rate{
    [self.player setRate:rate];
    
}

- (void)seekWithProgress:(float)progress{
    if (progress <= 0 || progress >1) {
        return;
    }
    //指定事件节点去播放
    //CMTime :影片时间
    //CMTime - s - CMTime
    //当前音频的总时长，已经播放的时长
    CMTime totalTime = self.player.currentItem.duration;
    //当前播放时长
//    self.player.currentItem.currentTime;
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);
    NSTimeInterval playTimeSec = totalSec * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间点的音频资源");
        }else{
            NSLog(@"取消加载这个时间点的音频资源");
        }
    }];
    
}

- (void)setMuted:(BOOL)muted{
    self.player.muted = muted;
}

- (void)setVolume:(float)volume{
    
    if (volume < 0 || volume >1) {
        return;
    }
    if (volume > 0 ) {
        self.player.muted = NO;
    }
    self.player.volume = volume;
}




-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus  status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了，可以播放");
            [self.player play];
        }
    }
    
    
}

@end
