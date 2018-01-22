//
//  ZBRemoteAudioPlayer.h
//  ZBRemotePlayerLib
//
//  Created by Mzhangzb on 20/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPlayerURLOrStateChangeNotification @"playerURLOrStateChangeNotification"

/**
 * 播放器的状态
 * 因为UI界面需要加载状态显示, 所以需要提供加载状态
 - XMGRemoteAudioPlayerStateUnknown: 未知(比如都没有开始播放音乐)
 - XMGAudioPlayerStateLoading: 正在加载()
 - XMGAudioPlayerStatePlaying: 正在播放
 - XMGAudioPlayerStateStopped: 停止
 - XMGAudioPlayerStatePause:   暂停
 - XMGRemoteAudioPlayerFailed:  失败(比如没有网络缓存失败, 地址找不到)
 */
typedef NS_ENUM(NSInteger, ZBRemoteAudioPlayerState) {
    ZBRemoteAudioPlayerStateUnknown   = 0,
    ZBRemoteAudioPlayerStateLoading   = 1,
    ZBRemoteAudioPlayerPlaying        = 2,
    ZBRemoteAudioPlayerStopped        = 3,
    ZBRemoteAudioPlayerPause          = 4,
    ZBRemoteAudioPlayerFailed         = 5
};
@interface ZBRemoteAudioPlayer : NSObject

+ (instancetype)shareInstance;

#pragma mark - 播放提供给外界的数据
/** 音频总时长 */
@property (nonatomic,assign,readonly)NSTimeInterval duration;
/** 音频当前播放时长 */
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
/** 播放进度, 可以反向设置 */
@property (nonatomic, assign) float progress;
/** 缓冲进度 */
@property (nonatomic, assign) float loadProgress;
/** 音频URL地址 */
@property (nonatomic, strong) NSURL *url;
/** 是否静音 */
@property (nonatomic, assign) BOOL muted;
/** 音量大小 */
@property (nonatomic, assign) float volume;
/** 当前播放状态 */
@property (nonatomic, assign, readonly) ZBRemoteAudioPlayerState state;

#pragma mark - 播放控制

// 播放
- (void)playAudioWithURL:(NSURL *)url;

// 继续
- (void)resume;

// 暂停
- (void)pause;

/**
 根据时间差, 完成快进10秒, 或者快退10秒的操作
 
 @param timeDiffer 时间差(正负)
 */
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;

/**
 改变当前播放的速率
 
 @param rate 速率(0.5 半速, 1.0 正常, 2.0两倍速)
 */
- (void)setRate:(float)rate;

@end
