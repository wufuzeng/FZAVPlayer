//
//  FZAVPlayerItemHandler.m
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZAVPlayerItemHandler.h"

@implementation FZAVPlayerItemHandler

-(void)dealloc{
    [self removeItem];
}

-(void)removeItem{
    [self removeObserver];
    self.playerItem = nil;
}

/** 配置播放项目 */
- (void)replaceItemWihtURL:(NSURL *)url{
/*
 * AVURLAssetPreferPreciseDurationAndTimingKey:
 *     这个选项对应的值是布尔值，默认为 @(NO)，
 *     当设为 @(YES) 时表示 asset 应该提供精确的时长，
 *     并能根据时间准确地随机访问，
 *     提供这样的能力是需要开销更大的计算的。
 *     当你只是想播放视频时，你可以不设置这个选项，
 *     但是如果你想把这个 asset 添加到一个composition（AVMutableComposition）中去做进一步编辑，
 *     你通常需要精确的随机访问，这时你最好设置这个选项为 YES。
 *
 * AVURLAssetReferenceRestrictionsKey:
 *     这个选项对应的值是 AVAssetReferenceRestrictions enum。
 *     有一些 asset 可以保护一些指向外部数据的引用，这个选项用来表示对外部数据访问的限制。
 *     具体含义参见 AVAssetReferenceRestrictions。
 *
 * AVURLAssetHTTPCookiesKey:
 *     这个选项用来设置 asset 通过 HTTP 请求发送的 HTTP cookies，当然 cookies 只能发给同站。具体参见文档。
 *
 * AVURLAssetAllowsCellularAccessKey:
 *     这个选项对应的值是布尔值，默认为 @(YES)。表示 asset 是否能使用移动网络资源。
 *
 * AVURLAssetHTTPHeaderFieldsKey:
 *     这个选项用来设置一个请求头的认证, 这个参数是非公开的API,但是经多人测试项目上线不受影响。
 *     播放视频只需一个url就能进行这样太不安全了,别人可以轻易的抓包盗链.
 *     因此此需要为视频链接做一个请求头的认证。
 * NSMutableDictionary * headers = [NSMutableDictionary dictionary];
 * headers[@"User-Agent"] = @"yourHeader";
 * AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url
 *                                            options:@{
 *                                                 @"AVURLAssetHTTPHeaderFieldsKey":headers
 *                                            }];
 */
    if (self.playerItem) {
        [self removeItem];
    }
    
    if (url) {
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url
                                                   options:nil];
        self.playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
        if (self.playerItem) {
            [self addObserver];
        }
    }else{
        [self removeItem];
    }
    
}





#pragma mark -- NSKeyValueObserving ------

-(void)addObserver{
    /*
     * 1.status 播放状态
     * 2.loadedTimeRanges 已加载时间范围
     * 3.playbackBufferEmpty //后续播放缓存为空(缓存不足，自动暂停)
     * 4.playbackLikelyToKeepUp //后续播放可能会更上(缓存不足,需手动播放)
     *
     * 3和4是一对,用于监听缓存足够播放的状态
     */
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    //播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    //播放失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.playerItem];
    //播放异常中断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemPlayblackStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
}

-(void)removeObserver{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
/** 播放完成 */
-(void)ItemDidPlayToEndTime:(AVPlayerItem *)item{
    if ([self.delegate respondsToSelector:@selector(item:statusChanged:)]) {
        [self.delegate item:self statusChanged:FZAVPlayerStatusFinished];
    }
    NSLog(@"播放结束");
}
/** 播放失败 */
-(void)itemFailedToPlayToEndTime:(AVPlayerItem *)item{
    NSLog(@"未播放结束");
}
/** 播放异常中断 */
-(void)itemPlayblackStalled:(AVPlayerItem *)item{
    NSLog(@"播放异常中断");
}
/**
 * 观察者模式 观察AVPlayerItem的值
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        FZAVPlayerStatus status = FZAVPlayerStatusUnkown;
        switch (playerItem.status) {
            case AVPlayerStatusUnknown:{
                status = FZAVPlayerStatusUnkown;
                break;}
            case AVPlayerStatusReadyToPlay:{
                status = FZAVPlayerStatusPrepare;
                break;}
            case AVPlayerStatusFailed:{
                status = FZAVPlayerStatusFailed;
                break;}
            default: break; 
        }
        if ([self.delegate respondsToSelector:@selector(item:statusChanged:)]) {
            [self.delegate item:self statusChanged:status];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval duration = [FZAVPlayerItemHandler seekableDuration:playerItem];//缓冲总时长
        if ([self.delegate respondsToSelector:@selector(item:bufferUpdated:)]) {
            [self.delegate item:self bufferUpdated:duration];
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (playerItem.playbackBufferEmpty) {
            if ([self.delegate respondsToSelector:@selector(item:statusChanged:)]) {
                [self.delegate item:self statusChanged:FZAVPlayerStatusLoading];
            }
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        if (playerItem.playbackLikelyToKeepUp) {
            if ([self.delegate respondsToSelector:@selector(item:statusChanged:)]) {
                [self.delegate item:self statusChanged:FZAVPlayerStatusPlaying];
            }
        }
    }
}


#pragma mark -- 工具方法 ------
/**  获取缓存时长 */
+ (NSTimeInterval)seekableDuration:(AVPlayerItem *)item{
    NSArray<NSValue *> *array = item.loadedTimeRanges;
    CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲时间范围
    CGFloat startSeconds  = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval duration = startSeconds + durationSeconds;//缓冲总时长
    return duration;
}
/** 获取总时长 */
+ (NSTimeInterval)playableDuration:(AVPlayerItem *)item {
    //NSTimeInterval duration = item.duration.timescale ? item.duration.value / item.duration.timescale : 0;
    NSTimeInterval duration = CMTimeGetSeconds(item.asset.duration);
    return duration;
}
/** 获取帧率 */
+ (CGFloat)framesPerSecond:(AVPlayerItem *)item{
    NSArray *videoArray = [item.asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoArray.count > 0) {
        CGFloat fps = [[videoArray objectAtIndex:0] nominalFrameRate];
        return fps;
    }
    return 0;
}

@end
