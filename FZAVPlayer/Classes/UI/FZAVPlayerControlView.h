//
//  FZAVPlayerControlView.h
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FZAVPlayerManager.h"
#import "FZAVPlayerView.h"

NS_ASSUME_NONNULL_BEGIN


@class FZAVPlayerControlView;

@protocol FZPlayControlDelegate <NSObject>
/** 控制播放状态改变 */
- (void)control:(FZAVPlayerControlView *)control playerStatusChanged:(FZAVPlayerStatus)playerStatus ;
/** 控制播放样式改变*/
- (void)control:(FZAVPlayerControlView *)control playerStyleChanged:(FZAVPlayerViewStyle)playerStyle ;
@optional
/** 缓存改变 */
- (void)control:(FZAVPlayerControlView *)control bufferChanged:(NSTimeInterval)timeInterval;
/** 控制播放进度改变 */
- (void)control:(FZAVPlayerControlView *)control progressChanged:(NSTimeInterval)timeInterval;
/** 控制滑块正在滑动 */
- (void)control:(FZAVPlayerControlView *)control sliderChanged:(BOOL)isSliding;
/** 控制返回按钮响应 */
- (void)control:(FZAVPlayerControlView *)control didClickedWithBackButton:(UIButton *)button;

@end

@interface FZAVPlayerControlView : UIView

@property (nonatomic,weak) id <FZPlayControlDelegate> delegate;

@property (nonatomic,strong) NSString *title;
 
/** 自动重新播放 */
@property (nonatomic,assign) BOOL autoReplay;
/** 显示标题栏 */
@property (nonatomic,assign) BOOL showTitleBar;
@property (nonatomic,assign) BOOL showBackBtn;
/** 禁止全屏 */
@property (nonatomic,assign) BOOL disableFullScreen;
/** 禁止调节亮度,音量 */
@property (nonatomic,assign) BOOL disableAdjustBrightnessOrVolume;

@property (nonatomic,assign) FZAVPlayerStatus playerStatus;
@property (nonatomic,assign) FZAVPlayerViewStyle  playerStyle;



/** 总时间 */
@property (nonatomic,assign) NSTimeInterval totalInterval;
/** 缓存时间 */
@property (nonatomic,assign) NSTimeInterval bufferInterval;
/** 进度时间 */
@property (nonatomic,assign) NSTimeInterval progressInterval;

@end


NS_ASSUME_NONNULL_END
