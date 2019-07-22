//
//  FZAVPlayerItemHandler.h
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <Foundation/Foundation.h>
// AVPlayer
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,FZAVPlayerStatus) {
    FZAVPlayerStatusUnkown = 0,      //未知
    FZAVPlayerStatusPrepare,         //准备播放
    FZAVPlayerStatusPlaying,         //正在播放
    FZAVPlayerStatusPaused,          //暂停
    FZAVPlayerStatusStoped,          //停止
    FZAVPlayerStatusFinished,        //完成
    FZAVPlayerStatusSeeking,         //正在定位
    FZAVPlayerStatusLoading,         //真正加载
    FZAVPlayerStatusFailed,          //失败
    
};

@class FZAVPlayerItemHandler;

@protocol FZAVPlayerItemDelegate <NSObject>
/** 状态回调 */
-(void)item:(FZAVPlayerItemHandler *)item statusChanged:(FZAVPlayerStatus)status;
/** 缓存回调 */
-(void)item:(FZAVPlayerItemHandler *)item bufferUpdated:(NSTimeInterval)timeInteval;

@end

@interface FZAVPlayerItemHandler : NSObject

@property (nonatomic,weak) id<FZAVPlayerItemDelegate> delegate;

/** 管理资源对象，提供播放数据源 */
@property (nonatomic,strong,nullable) AVPlayerItem *playerItem;

/** 配置播放项目 */
- (void)replaceItemWihtURL:(NSURL *)url;
-(void)removeItem;

/** 获取缓存时长 */
+ (NSTimeInterval)seekableDuration:(AVPlayerItem *)item;
/** 获取总时长 */
+ (NSTimeInterval)playableDuration:(AVPlayerItem *)item;
/** 获取帧率 */
+ (CGFloat)framesPerSecond:(AVPlayerItem *)item;

@end


NS_ASSUME_NONNULL_END
