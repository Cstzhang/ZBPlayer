//
//  ZBRemoteAudioPlayer.m
//  ZBRemotePlayerLib
//
//  Created by Mzhangzb on 20/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ZBRemoteAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface ZBRemoteAudioPlayer (){
    // 记录是否是用户手动暂停
    BOOL _isUserPause;
}
@property (nonatomic,strong) AVPlayer *player;


@end

@implementation ZBRemoteAudioPlayer
static ZBRemoteAudioPlayer * _shareInstance;

+ (instancetype)shareInstance{
    if (_shareInstance == nil) {
        _shareInstance = [[ZBRemoteAudioPlayer alloc]init];
    }
    return _shareInstance;
    
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (_shareInstance == nil) {
        static dispatch_once_t onceToke;
        dispatch_once(&onceToke, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (void)setState:(ZBRemoteAudioPlayerState)state {
    _state = state;
    if (self.url == nil) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerURLOrStateChangeNotification object:nil userInfo:@{@"state": @(self.state), @"url": self.url}];
}
- (void)setUrl:(NSURL *)url {
    _url = url;
    
    if (self.url == nil) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerURLOrStateChangeNotification object:nil userInfo:@{@"state": @(self.state), @"url": self.url}];
}


#pragma mark - 提供数据

- (NSTimeInterval)currentTime {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    if (isnan(currentTime)) {
        return 0;
    }
    return currentTime;
    
}

- (NSTimeInterval)duration {
    
    NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
    if (isnan(duration)) {
        return 0;
    }
    return duration;
}

- (float)progress {
    if (self.duration == 0) {
        return 0;
    }
    return self.currentTime / self.duration;
}


// 注意: 播放器, 本身就附带, 边播放, 边下载的功能, 但是, 缓存到的是内存中, 没有磁盘缓存
- (float)loadProgress {
    CMTimeRange range = [[self.player.currentItem loadedTimeRanges].firstObject CMTimeRangeValue];
    
    NSTimeInterval start = CMTimeGetSeconds(range.start);
    NSTimeInterval duration = CMTimeGetSeconds(range.duration);
    
    NSTimeInterval total = self.duration;
    
    if (total == 0) {
        return 0;
    }
    
    return (start + duration) / total;
    
}
- (BOOL)muted  {
    return self.player.muted;
}

- (float)volume {
    return self.player.volume;
}

#pragma mark - 播放控制

- (void)playAudioWithURL: (NSURL *)url {
    
    _url = url;
    // 1. 资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    // 2. 资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    // 当资源的组织者, 告诉我们资源准备好了之后, 我们再播放
    // AVPlayerItemStatus status
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 3. 资源的播放
    self.player = [AVPlayer playerWithPlayerItem:item];
//    if ([self.url isEqual:url]) {
//        if (self.state == ZBRemoteAudioPlayerPause) {
//            [self resume];
//            return;
//        }else if (self.state == ZBRemoteAudioPlayerStateLoading || self.state == ZBRemoteAudioPlayerPlaying)
//        {
//            return;
//        }
//    }
    
//    self.url = url;;
//
//    // 1. 负责根据URL地址, 请求播放资源
//    // 修改URL地址, 为streaming的协议, 这样可以将连续的多媒体数据分段处理
//
//    NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];
//    [components setScheme:@"streaming"];
//    NSURL *streamURL = [components URL];
//
//    AVURLAsset *asset = [AVURLAsset assetWithURL:streamURL];
////    self.resourceLoaderM = [[XMGReourceLoaderManager alloc] init];
////    [asset.resourceLoader setDelegate:self.resourceLoaderM queue:dispatch_get_main_queue()];
//
//
//    // 2. 负责资源管理, 准备播放资源
//    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
//
//    //  注意: 如果要开始播放资源, 最好, 直接监听资源管理者的状态, 如果准备好了, 再播放
//    [self clearObserver];
//    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//
//    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
//
//    [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//
//    // 监听通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayInterrupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
//
//    // 3. 负责播放准备好的资源, 播放器
//    self.player = [AVPlayer playerWithPlayerItem:item];
//
}




// 继续
- (void)resume {
    _isUserPause = NO;
    [self.player play];
    if (self.player.currentItem.playbackLikelyToKeepUp) {
        self.state = ZBRemoteAudioPlayerPlaying;
    }else {
        if (self.player) {
            self.state = ZBRemoteAudioPlayerStateLoading;
        }else {
            self.state = ZBRemoteAudioPlayerStateUnknown;
        }
    }
}

// 暂停
- (void)pause {
    _isUserPause = YES;
    [self.player pause];
    if (self.player) {
        self.state = ZBRemoteAudioPlayerPause;
    }
    
}



/**
 根据进度播放指定时间音频
 
 @param progress 进度(0.0----1.0)
 */
- (void)setProgress:(float)progress {
    
    double timeInterval = CMTimeGetSeconds(self.player.currentItem.duration) * progress;
    
    [self.player seekToTime:CMTimeMakeWithSeconds(timeInterval, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"缓冲完毕, 开始播放");
        }else {
            NSLog(@"缓冲错误");
        }
    }];
}



/**
 根据时间差, 完成快进10秒, 或者快退10秒的操作
 
 @param timeDiffer 时间差(正负)
 */
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    double currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime) + timeDiffer;
    
    double totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    
    [self setProgress:currentTime / totalTime];
    
}



/**
 改变当前播放的速率
 
 @param rate 速率(0.5 半速, 1.0 正常, 2.0两倍速)
 */
- (void)setRate:(float)rate {
    [self.player setRate:rate];
}


/**
 设置静音
 
 @param muted 静音
 */
- (void)setMuted:(BOOL)muted
{
    self.player.muted = muted;
}


/**
 设置音量
 
 @param volume 音量
 */
- (void)setVolume:(float)volume {
    if (volume > 0) {
        self.muted = NO;
    }
    self.player.volume = volume;
}


// 清楚所有的KVO
- (void)clearObserver {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"开始播放");
                [self resume];
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"失败");
                self.state = ZBRemoteAudioPlayerFailed;
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL isCanPlay = self.player.currentItem.playbackLikelyToKeepUp;
        if (isCanPlay) {
            NSLog(@"数据加载的可以播放了");
            
            // 注意, 这时候, 不要手动的开始播放
            // 因为, 有可能用户已经手动的暂停了播放
            if (!_isUserPause) {
                [self resume];
            }
            
        }
        
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        BOOL isBufferEmpty = self.player.currentItem.playbackBufferEmpty;
        if (isBufferEmpty) {
            NSLog(@"缓冲区空了, 正在加载");
            self.state =ZBRemoteAudioPlayerStateLoading;
        }
        
    }
    
}

- (void)playEnd {
    
    NSLog(@"播放完毕");
    self.state = ZBRemoteAudioPlayerStopped;
    
}

- (void)audioPlayInterrupt {
    
    NSLog(@"播放被打断");
    self.state = ZBRemoteAudioPlayerFailed;
    
}

- (void)dealloc {
    [self clearObserver];
}

@end
