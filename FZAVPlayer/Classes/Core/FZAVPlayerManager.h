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
- (void)manager:(FZAVPlayerManager *)manager playItem:(FZAVPlayerItemHandler *)playItem totalIntervalChanged:(NSTimeInterval)totalInterval;
/** 播放进度改变 */
- (void)manager:(FZAVPlayerManager *)manager playItem:(FZAVPlayerItemHandler *)playItem progressIntervalChanged:(NSTimeInterval)progressInterval;
/** 缓存进度改变 */
- (void)manager:(FZAVPlayerManager *)manager playItem:(FZAVPlayerItemHandler *)playItem bufferIntervalChanged:(NSTimeInterval)bufferInterval;

@end

@interface FZAVPlayerManager : NSObject

@property (nonatomic,weak) id<FZPlayManagerDelegate> delegate;

/** 播放图层 (负责显示视频，如果没有添加该类，只有声音没有画面)*/
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
/** 设置播放源 */
@property (nonatomic,strong,nullable) FZAVPlayerItemHandler *itemHandler;
/** 播放状态 */
@property (nonatomic,assign) FZAVPlayerStatus playerStatus;
/** 进度条正在被拖拽 */
@property (nonatomic,assign) BOOL isSliding;
/** 自动重新播放 */
@property (nonatomic,assign) BOOL autoReplay;

/** 单利 */
+ (FZAVPlayerManager *)sharedPlayer;

/** 跳转进度播放
 @param timeinterval  位置
 */
- (void) playFromTimeInterval:(NSTimeInterval)timeinterval;

@end


NS_ASSUME_NONNULL_END
