//
//  FZAVPlayerManager.h
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FZAVPlayerItemHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class FZAVPlayerManager;

@protocol FZPlayManagerDelegate <NSObject>

/** 播放状态改变 */
- (void)manager:(FZAVPlayerManager *)manager playerStatusChanged:(FZAVPlayerStatus)playerStatus;
/** 播放总时长改变 */
- (void)manager:(FZAVPlayerManager *)manager playItem:(AVPlayerItem *)playItem totalIntervalChanged:(NSTimeInterval)totalInterval;
/** 播放进度改变 */
- (void)manager:(FZAVPlayerManager *)manager playItem:(AVPlayerItem *)playItem progressIntervalChanged:(NSTimeInterval)progressInterval;
/** 缓存进度改变 */
- (void)manager:(FZAVPlayerManager *)manager playItem:(AVPlayerItem *)playItem bufferIntervalChanged:(NSTimeInterval)bufferInterval;

@end

@interface FZAVPlayerManager : NSObject

@property (nonatomic,weak) id<FZPlayManagerDelegate> delegate;
/** 播放对象 (控制 开始，跳转，暂停，停止)*/
@property (nonatomic,strong) AVPlayer *player;
/** 播放图层 (负责显示视频，如果没有添加该类，只有声音没有画面)*/
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
/** 媒体队列 */
@property (nonatomic,strong) NSArray<AVAsset *>* videoQueue;
/** 当前媒体 */
@property (nonatomic,strong,readonly) AVAsset* currentAsset;
/** 当前媒体索引 */
@property (nonatomic,assign,readonly) NSInteger currentItemIndex;
/** 播放状态 */
@property (nonatomic,assign) FZAVPlayerStatus playerStatus;
/** 进度条正在被拖拽 */
@property (nonatomic,assign) BOOL isSliding; 
/** 是否使用遥控器 */
@property (nonatomic, assign) BOOL isUsingRemoteCommand;

/** 单利 */
+ (FZAVPlayerManager *)sharedPlayer;

- (void)play;
- (void)retryPlay;
- (void)pause;
- (void)destroy;

- (void)playNext;
- (void)playPrevious;
/** 移动指定时间 */
- (void)seekToTimestamp:(NSTimeInterval)timestamp; 
/** 播放速度 */
- (void)playWithRate:(CGFloat)rate;
@end


NS_ASSUME_NONNULL_END
