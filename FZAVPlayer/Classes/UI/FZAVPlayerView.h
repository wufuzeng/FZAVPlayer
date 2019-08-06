//
//  FZAVPlayerView.h
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FZAVPlayerManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,FZAVPlayerViewStyle) {
    FZAVPlayerViewStyleNormal = 0,//正常
    FZAVPlayerViewStyleFullScreen,//全屏
};

@class FZAVPlayerView;

@protocol  FZPlayerDelegate <NSObject>

//播放器播放状态
- (void)player:(FZAVPlayerView *)player playerStatusChanged:(FZAVPlayerStatus)playState;
//播放器视图改变
- (void)player:(FZAVPlayerView *)player playerStyleChanged:(FZAVPlayerViewStyle)playerStyle;
//返回按钮点击
- (void)player:(FZAVPlayerView *)plyer didClickedWithBackButton:(UIButton *)button;
@optional
/** 播放进度 */
- (void)player:(FZAVPlayerView *)player didPlayedToTime:(CMTime)time;
/** 准备播放 */
- (void)player:(FZAVPlayerView *)player readyToPlayVideoOfIndex:(NSInteger)index;
/** 播放结束 */
- (void)didPlayToEndTimeHandler;
/** 控制视图显示 */
- (void)controlViewDidAppearHandler;
/** 控制视图消失 */
- (void)controlViewDidDisappearHandler;

@end


@interface FZAVPlayerView : UIView
/** 代理 */
@property (nonatomic,weak) id<FZPlayerDelegate> delegate;
/** 媒体 */
@property (nonatomic, strong) AVAsset* asset;
/** 链接 */
@property (nonatomic, strong) NSURL* videoURL;
/** 媒体数组 */
@property (nonatomic, strong) NSArray<AVAsset *>* videoQueue;
/** 单循环 */
@property (nonatomic, assign) BOOL singleCirclePlay;
/** 自动重新播放 */
@property (nonatomic,assign) BOOL autoReplay;
/** 是否使用遥控器 */
@property (nonatomic, assign) BOOL isUsingRemoteCommand;
/** 当前播放 */
@property (nonatomic, strong, readonly) AVPlayerItem* currentPlayItem;


/** 要显示的view (nil 则是显示在window上) */
@property (nonatomic,weak) UIView *showInView;
/** 视频拉伸模式 */
@property (nonatomic,assign) AVLayerVideoGravity videoGravity;
/** 播放视频的标题 */
@property (nonatomic,copy) NSString *title;

/** 显示控制图层 */
@property (nonatomic,assign) BOOL showControlView;
/** 显示标题栏 */
@property (nonatomic,assign) BOOL showTitleBar;
/** 显示返回按钮 */
@property (nonatomic,assign) BOOL showBackBtn;
/** 禁止全屏 */
@property (nonatomic,assign) BOOL disableFullScreen;
/** 禁止调节亮度,音量 */
@property (nonatomic,assign) BOOL disableAdjustBrightnessOrVolume;

/** 播放速度 */
- (void)playWithRate:(CGFloat)rate;
/** 移动指定时间 */
- (void)seekToTimestamp:(NSTimeInterval)timestamp;

/** 播放*/
- (void)play;
- (void)pause;
- (void)stop;
- (void)playNext;
- (void)playPrevious;

@end

NS_ASSUME_NONNULL_END
