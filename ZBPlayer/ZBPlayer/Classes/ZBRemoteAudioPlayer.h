//
//  ZBRemoteAudioPlayer.h
//  ZBRemotePlayerLib
//
//  Created by Mzhangzb on 20/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBRemoteAudioPlayer : NSObject
+ (instancetype)shareInstance;
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

- (void)seekWithProgress:(float)progress;

- (void)setMuted:(BOOL)muted;

- (void)setVolume:(float)volume;


@end
