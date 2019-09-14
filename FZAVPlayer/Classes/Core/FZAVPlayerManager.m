//
//  FZAVPlayerManager.m
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

/*
 * 在AVPlayer中时间的表示有一个专门的结构体CMTime
 * typedef struct{
 *     CMTimeValue value;     // 帧数
 *     CMTimeScale timescale; // 帧率(影片每秒有几帧)
 *     CMTimeFlags flags;
 *     CMTimeEpoch epoch;
 * } CMTime;
 * CMTime是以分数的形式表示时间,value表示分子,timescale表示分母,flags是位掩码,表示时间的指定状态。
 */


#import "FZAVPlayerManager.h"
#import <MediaPlayer/MediaPlayer.h>
@interface FZAVPlayerManager ()
<
FZAVPlayerItemDelegate
>

/** 播放对象定期观察者 */
@property (nonatomic,strong) id playerObserver;
/** 设置播放源 */
@property (nonatomic,strong,nullable) FZAVPlayerItemHandler *itemHandler;
/** 重试次数 */
@property (nonatomic,assign) NSInteger retryCount;
@end

@implementation FZAVPlayerManager

#pragma mark -- Life Cycle Func --
/** 单利 */
+ (FZAVPlayerManager *)sharedPlayer{
    static FZAVPlayerManager *sharedPlayer = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedPlayer = [[self alloc] init];
        //AVAudioSession是音频会话的一个单例，将指定该APP在与系统之间的通信中如何使用音频。不加没有声音。
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:nil];
    });
    return sharedPlayer;
}


/** 播放速度 */
- (void)playWithRate:(CGFloat)rate{
    self.player.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    self.player.rate = rate;
    [self.player play];
    self.playerStatus = FZAVPlayerStatusPlaying;
    if (self.isUsingRemoteCommand) {
        [self updateRemoteInfoCenter];
    }
}
/** 移动指定时间 */
- (void)seekToTimestamp:(NSTimeInterval)timestamp {
    self.playerStatus = FZAVPlayerStatusSeeking;
    CGFloat fps = [FZAVPlayerItemHandler framesPerSecond:self.player.currentItem];
    CMTime startTime = CMTimeMakeWithSeconds(timestamp, fps);
    __weak __typeof(self) weakSelf = self;
    [self.player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            if (!weakSelf.isSliding) {
                weakSelf.playerStatus = FZAVPlayerStatusPlaying;
                if ([weakSelf.delegate respondsToSelector:@selector(manager:playItem:progressIntervalChanged:)]) {
                    [weakSelf.delegate manager:self  playItem:self.player.currentItem progressIntervalChanged:timestamp];
                }
            }
        }
    }];
}

/** 重试 */
- (void)retryPlay{
    if (self.currentAsset == nil) return;
    if (self.retryCount < 3) {
        self.retryCount++;
        [self replaceItemWithAsset:self.currentAsset];
    }
}

/** 替换 */
- (void)replaceItemWithAsset:(AVAsset *)asset{
    FZAVPlayerItemHandler *itemHandler = [FZAVPlayerItemHandler new];
    itemHandler.delegate = self;
    [itemHandler replaceItemWihtAsset:asset];
    self.itemHandler = itemHandler;
    //放置播放源
    [self.player replaceCurrentItemWithPlayerItem:itemHandler.playerItem];
    [self addObserver];
    //[self play];
}

- (void)play{
    self.player.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    [self.player play];
    self.playerStatus = FZAVPlayerStatusPlaying;
    if (self.isUsingRemoteCommand) {
        [self updateRemoteInfoCenter];
    }
}

- (void)pause{
    [self.player pause];
    self.playerStatus = FZAVPlayerStatusPaused;
    if (self.isUsingRemoteCommand) {
        [self updateRemoteInfoCenter];
    }
}

- (void)destroy{
    [self pause];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.itemHandler removeItem];
    _player = nil;
    _itemHandler = nil;
    _playerLayer = nil;
    _playerObserver = nil;
    if (self.isUsingRemoteCommand) {
        [self removeMediaPlayerRemoteCommands];
    }
}
- (void)playNext{
    if (!self.videoQueue.count) {
        return;
    }
    ++_currentItemIndex >= self.videoQueue.count ? _currentItemIndex = 0 : 1;
    AVAsset* nextAsset = self.videoQueue[_currentItemIndex];
    [self replaceItemWithAsset:nextAsset];
}

- (void)playPrevious{
    if (!self.videoQueue.count) {
        return;
    }
    --_currentItemIndex < 0 ? _currentItemIndex = self.videoQueue.count - 1 : 1;
    AVAsset* preAsset = self.videoQueue[_currentItemIndex];;
    [self replaceItemWithAsset:preAsset];
}

#pragma mark -- MPRemoteCommandCenter --
/** 添加媒体播放遥控器命令 */
- (void)addMediaPlayerRemoteCommands{
    MPRemoteCommandCenter* commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPRemoteCommand* pauseCommand = [commandCenter pauseCommand];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand* playCommand = [commandCenter playCommand];
    [playCommand setEnabled:YES];
    [playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand* playNextCommand = [commandCenter nextTrackCommand];
    [playNextCommand setEnabled:YES];
    [playNextCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self playNext];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand* playPreCommand = [commandCenter previousTrackCommand];
    [playPreCommand setEnabled:YES];
    [playPreCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self playPrevious];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    if (@available(ios 9.1, *)) {
        MPRemoteCommand* changeProgressCommand = [commandCenter changePlaybackPositionCommand];
        [changeProgressCommand setEnabled:YES];
        [changeProgressCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
            //CMTime time = CMTimeMakeWithSeconds(playbackPositionEvent.positionTime, self.player.currentItem.duration.timescale);
            [self seekToTimestamp:playbackPositionEvent.positionTime];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
}

- (void)removeMediaPlayerRemoteCommands{
    MPRemoteCommandCenter* commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [[commandCenter playCommand] removeTarget:self];
    [[commandCenter pauseCommand] removeTarget:self];
    [[commandCenter nextTrackCommand] removeTarget:self];
    [[commandCenter previousTrackCommand] removeTarget:self];
    if (@available(iOS 9.1, *)) {
        [[commandCenter changePlaybackPositionCommand] removeTarget:self];
    }
}

- (void)updateRemoteInfoCenter{
    if (!self.player) {
        return;
    }
    MPNowPlayingInfoCenter* infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    // title
    
    [info setObject:[NSString stringWithFormat:@"歌曲%ld",(long)_currentItemIndex] forKey:MPMediaItemPropertyTitle];
    [info setObject:[NSString stringWithFormat:@"专辑%ld",(long)_currentItemIndex] forKey:MPMediaItemPropertyAlbumTitle];
    // cover image
    if (@available(iOS 10.0, *)) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(250, 250) requestHandler:^UIImage * _Nonnull(CGSize size) {
            UIImage* image = [UIImage imageNamed:@"cover.jpg"];
            return image;
        }];
        [info setObject:artwork forKey:MPMediaItemPropertyArtwork];
    } else {
        // Fallback on earlier versions
    }
    // set screen progress
    NSNumber* duration = @(CMTimeGetSeconds(self.player.currentItem.duration));
    NSNumber* currentTime = @(CMTimeGetSeconds(self.player.currentItem.currentTime));
    [info setObject:duration forKey:MPMediaItemPropertyPlaybackDuration];
    [info setObject:currentTime forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [info setObject:@(self.player.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    infoCenter.nowPlayingInfo = info;
}

#pragma mark –- Observer Func  --

-(void)addObserver{
    if (self.playerObserver) {
        [self removeObserver];
    }
    /*
     * “添加周期时间观察者” ,
     * 参数1 interal 为CMTime 类型的,
     * 参数2 queue为串行队列,如果传入NULL就是默认主线程,
     * 参数3 为CMTime 的block类型。
     *
     * 简而言之就是,每隔一段时间后执行 block。
     * 比如:我们把interval设置成CMTimeMake(1, 10),在block里面刷新label,就是一秒钟刷新10次。
     * 这个方法就是每隔多久调用一次block，函数返回的id类型的对象在不使用时用-removeTimeObserver:释放
     */
    __weak __typeof(self) weakSelf = self;
    //对于1分钟以内的视频就每1/30秒刷新一次页面，
    //大于1分钟的每秒一次就行 (总时间，时间刻度)：每段=总时间/时间刻度
    //NSTimeInterval duration = [FZAVPlayerItemHandler playableDuration:self.itemHandler.playerItem];
    //CMTime interval = duration > 60 ? CMTimeMake(1, 1) : CMTimeMake(1, 30);
    self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, NSEC_PER_SEC)
                                                           queue:dispatch_get_main_queue()
                                                      usingBlock:^(CMTime time) {
          NSTimeInterval currentTimeInterval = CMTimeGetSeconds(time);
          if ([weakSelf.delegate respondsToSelector:@selector(manager:playItem:progressIntervalChanged:)]) {
              [weakSelf.delegate manager:weakSelf  playItem:weakSelf.player.currentItem progressIntervalChanged:currentTimeInterval];
          }
      }];
}

-(void)removeObserver{
    [self.player removeTimeObserver:self.playerObserver];
    self.playerObserver = nil;
}

#pragma mark -- FZAVPlayerItemDelegate --
/** 状态回调 */
-(void)item:(FZAVPlayerItemHandler *)item statusChanged:(FZAVPlayerStatus)status{
    self.playerStatus = status;
    switch (status) {
        case FZAVPlayerStatusPrepare:{
            [self.player seekToTime:kCMTimeZero];
            // 获取总时间
            NSTimeInterval duration = [FZAVPlayerItemHandler playableDuration:self.player.currentItem];
            if ([self.delegate respondsToSelector:@selector(manager:playItem:totalIntervalChanged:)]) {
                [self.delegate manager:self playItem:item.playerItem totalIntervalChanged:duration];
            }
            [self play];
        }break;
        case FZAVPlayerStatusPlaying:{
            self.retryCount = 0;
        }break;
        case FZAVPlayerStatusFinished:{
            [self.player seekToTime:kCMTimeZero];
        }break;
        default: break;
    }
}
/** 缓存回调 */
-(void)item:(FZAVPlayerItemHandler *)item bufferUpdated:(NSTimeInterval)timeInteval{
    if ([self.delegate respondsToSelector:@selector(manager:playItem:bufferIntervalChanged:)]) {
        [self.delegate manager:self playItem:item.playerItem bufferIntervalChanged:timeInteval];
    }
}

#pragma mark -- Set,Get Func ---

-(void)setPlayerStatus:(FZAVPlayerStatus)playerStatus{
    _playerStatus = playerStatus;
    if ([self.delegate respondsToSelector:@selector(manager:playerStatusChanged:)]) {
        [self.delegate manager:self playerStatusChanged:playerStatus];
    }
}

-(void)setVideoQueue:(NSArray<AVAsset *> *)videoQueue{
    _videoQueue = videoQueue;
    if ([[videoQueue firstObject] isKindOfClass:[AVAsset class]]) {
        _currentAsset = videoQueue.firstObject;
        [self replaceItemWithAsset:_currentAsset];
    }
    
}
- (void)setIsUsingRemoteCommand:(BOOL)isUsingRemoteCommand{
    _isUsingRemoteCommand = isUsingRemoteCommand;
    if (isUsingRemoteCommand) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self addMediaPlayerRemoteCommands];
    }
}

#pragma mark -- Lazy Func --

-(AVPlayer *)player{
    if (_player == nil) {
        _player = [AVPlayer new];
    }
    return _player;
}

-(AVPlayerLayer *)playerLayer{
    if (_playerLayer == nil) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    }
    return _playerLayer;
}



-(void)dealloc{
    [self removeObserver];
    if (self.isUsingRemoteCommand) {
        [self removeMediaPlayerRemoteCommands];
    }
     [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

@end
