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

@end


@interface FZAVPlayerView : UIView

/** 代理 */
@property (nonatomic,weak) id<FZPlayerDelegate> delegate;

/** 要显示的view (nil 则是显示在window上) */
@property (nonatomic,weak) UIView *showInView;
/** 视频拉伸模式 */
@property (nonatomic,assign) AVLayerVideoGravity videoGravity;
/** 播放视频的标题 */
@property (nonatomic,copy) NSString *title;
/** 自动重新播放 */
@property (nonatomic,assign) BOOL autoReplay;
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

/**
 播放url地址
 @param url url地址
 */
- (void) playWithUrl:(NSURL *)url;

- (void) play;
- (void) pause;
- (void) stop;

@end

NS_ASSUME_NONNULL_END
