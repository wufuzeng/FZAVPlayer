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

@interface FZAVPlayerManager ()
<
FZAVPlayerItemDelegate
>
/** 播放对象 (控制 开始，跳转，暂停，停止)*/
@property (nonatomic,strong) AVPlayer *player;
///** 总秒数 */
//@property (nonatomic,assign) NSTimeInterval totalSecond;
///** 视频持续时间 */
//@property (nonatomic,assign) CGFloat duration;
///** 帧率 */
//@property (nonatomic,assign) CGFloat fps;
/** 播放对象定期观察者 */
@property (nonatomic,strong) id playerObserver;

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

-(void)dealloc{
    [self removeObserver];
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
    NSTimeInterval duration = [FZAVPlayerItemHandler playableDuration:self.itemHandler.playerItem];
    CMTime interval = duration > 60 ? CMTimeMake(1, 1) : CMTimeMake(1, 30);
    self.playerObserver = [self.player addPeriodicTimeObserverForInterval:interval
                                                           queue:dispatch_get_main_queue()
                                                      usingBlock:^(CMTime time) {
          NSTimeInterval currentTimeInterval = CMTimeGetSeconds(time);
          if ([weakSelf.delegate respondsToSelector:@selector(manager:playItem:progressIntervalChanged:)]) {
              [weakSelf.delegate manager:weakSelf  playItem:weakSelf.itemHandler progressIntervalChanged:currentTimeInterval];
          }
      }];
}

-(void)removeObserver{
    [self.player removeTimeObserver:self.playerObserver];
    self.playerObserver = nil;
}

#pragma mark –- Custom Func --

/** 指定进度播放 */
- (void)playFromTimeInterval:(NSTimeInterval)timeinterval {
    self.playerStatus = FZAVPlayerStatusSeeking;
    CGFloat fps = [FZAVPlayerItemHandler framesPerSecond:self.player.currentItem];
    CMTime startTime = CMTimeMakeWithSeconds(timeinterval, fps);
    if ([self.delegate respondsToSelector:@selector(manager:playItem:progressIntervalChanged:)]) {
        [self.delegate manager:self  playItem:self.itemHandler progressIntervalChanged:timeinterval];
    }
    __weak __typeof(self) weakSelf = self;
    [self.player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (!weakSelf.isSliding) {
            weakSelf.playerStatus = FZAVPlayerStatusPlaying;
            if ([weakSelf.delegate respondsToSelector:@selector(manager:playerStatusChanged:)]) {
                [weakSelf.delegate manager:weakSelf playerStatusChanged:weakSelf.playerStatus];
            }
        }
    }];
}

#pragma mark -- FZAVPlayerItemDelegate --
/** 状态回调 */
-(void)item:(FZAVPlayerItemHandler *)item statusChanged:(FZAVPlayerStatus)status{
    switch (status) {
        case FZAVPlayerStatusPrepare:
        {
            // 获取总时间
            NSTimeInterval duration = [FZAVPlayerItemHandler playableDuration:self.player.currentItem];
            if ([self.delegate respondsToSelector:@selector(manager:playItem:totalIntervalChanged:)]) {
                [self.delegate manager:self playItem:item totalIntervalChanged:duration];
            }
            //设置播放状态
            self.playerStatus = FZAVPlayerStatusPlaying;
        }break;
        default:
        {
            self.playerStatus = status;
        }break;
    }
}
/** 缓存回调 */
-(void)item:(FZAVPlayerItemHandler *)item bufferUpdated:(NSTimeInterval)timeInteval{
    if ([self.delegate respondsToSelector:@selector(manager:playItem:bufferIntervalChanged:)]) {
        [self.delegate manager:self playItem:item bufferIntervalChanged:timeInteval];
    }
}

#pragma mark -- Set,Get Func ---

/** 设置播放项目 */
- (void)setItemHandler:(FZAVPlayerItemHandler *)itemHandler {
    _itemHandler = itemHandler;
    itemHandler.delegate = self;
    //放置播放源
    [self.player replaceCurrentItemWithPlayerItem:itemHandler.playerItem];
    [self addObserver];
}

/** 设置播放状态 */
-(void)setPlayerStatus:(FZAVPlayerStatus)playerStatus {
    switch (playerStatus) {
        case FZAVPlayerStatusPrepare:
        {
            [self.player seekToTime:kCMTimeZero];
        }break;
        case FZAVPlayerStatusPlaying:
        {
            [self.player play];
        }break;
        case FZAVPlayerStatusPaused:
        case FZAVPlayerStatusSeeking:
        {
            [self.player pause];
        }break;
        case FZAVPlayerStatusStoped:
        {
            //暂停
            [self.player pause];
            //取消跳转
            [self.player.currentItem cancelPendingSeeks];
            //取消加载
            [self.player.currentItem.asset cancelLoading];
            //移除
            [self.itemHandler removeItem];
        } break;
        case FZAVPlayerStatusFinished:
        {
            [self.player seekToTime:kCMTimeZero];
            if (!self.autoReplay) {
                [self.player pause];
            }
        }break;
        case FZAVPlayerStatusLoading:{
            
        }break;
        case FZAVPlayerStatusFailed:{
            
        }break;
        default:{
         
        }break;
    }
    
    if (_playerStatus == playerStatus) return;
    _playerStatus = playerStatus;
    if ([self.delegate respondsToSelector:@selector(manager:playerStatusChanged:)]) {
        [self.delegate manager:self playerStatusChanged:self.playerStatus ];
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

@end
