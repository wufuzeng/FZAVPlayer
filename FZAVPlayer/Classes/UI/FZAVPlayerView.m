
//
//  FZAVPlayerView.m
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZAVPlayerView.h"

#import "FZAVPlayerManager.h"
#import "FZAVPlayerControlView.h"

@interface FZAVPlayerView ()
<
FZPlayControlDelegate,
FZPlayManagerDelegate
>
/** 播放源持有者 */
@property (nonatomic,strong) FZAVPlayerItemHandler *itemHandler;
/** 播放管理 */
@property (nonatomic,strong) FZAVPlayerManager *playerManager;
/** 播放控制界面 */
@property (nonatomic,strong) FZAVPlayerControlView *controlView;
/** 原始的rect */
@property (nonatomic,assign) CGRect originRect;
/** 视频链接 */
@property (nonatomic,strong) NSURL *urlPath;
/** 重试次数 */
@property (nonatomic,assign) NSInteger retryCount;

@end

@implementation FZAVPlayerView

#pragma mark -- Life Cycle Func -------

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self addObserver];
    }
    return self;
}

-(void)dealloc{
    NSLog(@"%@释放了",NSStringFromClass([self class]));
    [self removeObserver];
}

#pragma mark -- SetupViews Func -----
/** 配置 */
-(void)setupView{
    self.retryCount = 0;
    self.backgroundColor = [UIColor blackColor];
    self.layer.masksToBounds = YES;
}

#pragma mark -- Play Func -------------

-(void)playWithUrl:(NSURL *)url {
    self.urlPath = url;
    [self.itemHandler replaceItemWihtURL:url];
    self.playerManager.itemHandler = self.itemHandler;
}

-(void)resume{
    self.controlView.playerStatus  = FZAVPlayerStatusPlaying;
    self.playerManager.playerStatus = FZAVPlayerStatusPlaying;
}

-(void)pause{
    self.controlView.playerStatus  = FZAVPlayerStatusPaused;
    self.playerManager.playerStatus = FZAVPlayerStatusPaused;
}

- (void)stop{
    self.controlView.playerStatus  = FZAVPlayerStatusStoped;
    self.playerManager.playerStatus = FZAVPlayerStatusStoped;
}

#pragma mark -- Notice Func -------

/** 添加监听 */
-(void)addObserver{
    //-------------------------------监听屏幕方向-------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

-(void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
    
- (void) handleDeviceOrientationDidChange:(NSNotification *)notifi {
    UIDevice *device = [UIDevice currentDevice];
    
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:{
            //竖屏
            self.controlView.playerStyle = FZAVPlayerViewStyleNormal;
            [self rotateView:device.orientation];
        } break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:{
            if (self.disableFullScreen) {
                
            }else{
                self.controlView.playerStyle = FZAVPlayerViewStyleFullScreen;
                [self rotateView:device.orientation];
            }
        } break;
        default: break;
    }
}
#pragma mark -- Rotation Func ----
/** 播放视图旋转 */
-(void)rotateView:(UIDeviceOrientation)orientation {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect fullRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    if (orientation == UIDeviceOrientationPortrait ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        [UIView animateWithDuration:0.3 animations:^{
            if (orientation == UIDeviceOrientationPortrait) {
                self.transform = CGAffineTransformIdentity;//CGAffineTransformMakeRotation(0/180.0 * M_PI);
            }else{
                self.transform = CGAffineTransformMakeRotation(180/180.0 * M_PI);
            }
            if (self.controlView.playerStyle == FZAVPlayerViewStyleNormal) {
                [self switchFrame:self.originRect];
            }else{
                [self switchFrame:fullRect];
            }
        } completion:^(BOOL finished) {
            if (self.controlView.playerStyle == FZAVPlayerViewStyleNormal) {
                [window setWindowLevel:UIWindowLevelNormal];
                [self.showInView addSubview:self];
                [self.showInView bringSubviewToFront:self];
            }else{
                [window setWindowLevel:UIWindowLevelStatusBar];
                [window addSubview:self];
                [window bringSubviewToFront:self];
            }
        }];
        
    } else if (orientation == UIDeviceOrientationLandscapeLeft ||
               orientation == UIDeviceOrientationLandscapeRight) {
        
        [UIView animateWithDuration:0.3 animations:^{
            if (orientation == UIDeviceOrientationLandscapeLeft) {
                self.transform = CGAffineTransformMakeRotation(90/180.0 * M_PI);
            }else{
                self.transform = CGAffineTransformMakeRotation(270/180.0 * M_PI);
            }
            [self switchFrame:fullRect];
            self.layer.cornerRadius = 0;
        } completion:^(BOOL finished) {
            [window setWindowLevel:UIWindowLevelStatusBar];
            [window addSubview:self];
            [window bringSubviewToFront:self];
        }];
    }
}

#pragma mark -- Zoom Func ----
/** 播放视图放缩 */
-(void)zoomView:(FZAVPlayerViewStyle)style {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (style == FZAVPlayerViewStyleNormal) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformIdentity;
            [self switchFrame:self.originRect];
        } completion:^(BOOL finished) {
            [window setWindowLevel:UIWindowLevelNormal];
            [self.showInView addSubview:self];
            [self.showInView bringSubviewToFront:self];
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect fullRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [self switchFrame:fullRect];
            self.layer.cornerRadius = 0;
        } completion:^(BOOL finished) {
            [window setWindowLevel:UIWindowLevelStatusBar];
            [window addSubview:self];
            [window bringSubviewToFront:self];
        }];
    }
}


#pragma mark -- FZPlayControlDelegate ---------
/** 控制播放状态改变 */
- (void)control:(FZAVPlayerControlView *)control playerStatusChanged:(FZAVPlayerStatus)playerStatus{
    
    self.playerManager.playerStatus = playerStatus;
    [self bringSubviewToFront:self.controlView];
    
    if ([self.delegate respondsToSelector:@selector(player:playerStatusChanged:)]) {
        [self.delegate player:self playerStatusChanged:playerStatus];
    }
}
/** 控制播放样式改变*/
- (void)control:(FZAVPlayerControlView *)control playerStyleChanged:(FZAVPlayerViewStyle)playerStyle{
    if (playerStyle == FZAVPlayerViewStyleFullScreen) {
        [self zoomView:FZAVPlayerViewStyleFullScreen];
    } else {
        [self zoomView:FZAVPlayerViewStyleNormal];
    }
    if ([self.delegate respondsToSelector:@selector(player:playerStyleChanged:)]){
        [self.delegate player:self playerStyleChanged:playerStyle];
    }
}
/** 控制播放进度改变 */
- (void)control:(FZAVPlayerControlView *)control progressChanged:(NSTimeInterval)timeInterval{
    [self.playerManager playFromTimeInterval:timeInterval];
}
/** 控制滑块正在滑动 */
- (void)control:(FZAVPlayerControlView *)control sliderChanged:(BOOL)isSliding{
    if (isSliding) {
        self.playerManager.playerStatus = FZAVPlayerStatusPaused;
    }
    self.playerManager.isSliding = isSliding;
}
/** 控制返回按钮响应 */
- (void)control:(FZAVPlayerControlView *)control didClickedWithBackButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(control:didClickedWithBackButton:)]){
        [self.delegate player:self didClickedWithBackButton:button];
    }
}
#pragma mark - FZPlayManagerDelegate ---
/** 播放状态改变 */
- (void)manager:(FZAVPlayerManager *)manager playerStatusChanged:(FZAVPlayerStatus)playerStatus{
    if (self.controlView.playerStatus == playerStatus) return;
    self.controlView.playerStatus = playerStatus;
    switch (playerStatus) {
        case FZAVPlayerStatusPlaying:{
            self.retryCount = 0;
        } break;
        case FZAVPlayerStatusFinished:{
            if (self.autoReplay) {
                [self resume];
            }
            if (self.didPlayToEndTimeHandler) {
                self.didPlayToEndTimeHandler();
            }
        } break; 
        case FZAVPlayerStatusFailed:
        case FZAVPlayerStatusUnkown:{
            if (self.retryCount < 3) {
                /** 重新设置 */
                [self playWithUrl:self.urlPath];
                self.retryCount++;
            }
        } break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(player:playerStatusChanged:)]){
        [self.delegate player:self playerStatusChanged:playerStatus ];
    }
}
/** 播放总时长改变 */
- (void)manager:(FZAVPlayerManager *)manager playItem:(FZAVPlayerItemHandler *)playItem totalIntervalChanged:(NSTimeInterval)totalInterval {
    [self.controlView setTotalInterval:totalInterval];
}
/** 播放进度改变 */
- (void)manager:(FZAVPlayerManager *)manager  playItem:(FZAVPlayerItemHandler *)playItem progressIntervalChanged:(NSTimeInterval)progressInterval{
    [self.controlView setProgressInterval:progressInterval];
}
/** 缓存时间改变 */
- (void)manager:(FZAVPlayerManager *)manager playItem:(FZAVPlayerItemHandler *)playItem bufferIntervalChanged:(NSTimeInterval)bufferInterval {
    [self.controlView setBufferInterval:bufferInterval];
}

#pragma mark -- Set Func -----

-(void)setFrame:(CGRect)frame {
    self.originRect = frame;
    [self switchFrame:frame];
}
-(void)switchFrame:(CGRect)frame{
    [super setFrame:frame];
    CGRect nRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.playerManager.playerLayer.frame = nRect;
    self.controlView.frame = nRect;
    [self.controlView layoutIfNeeded];
}


-(void)setTitle:(NSString *)title {
    _title = title;
    self.controlView.title = title;
}

-(void)setShowBackBtn:(BOOL)showBackBtn {
    _showBackBtn = showBackBtn;
    self.controlView.showBackBtn = showBackBtn;
}

-(void)setDisableFullScreen:(BOOL)disableFullScreen{
    _disableFullScreen = disableFullScreen;
    self.controlView.disableFullScreen = disableFullScreen;
}

-(void)setDisableAdjustBrightnessOrVolume:(BOOL)disableAdjustBrightnessOrVolume{
    _disableAdjustBrightnessOrVolume = disableAdjustBrightnessOrVolume;
    self.controlView.disableAdjustBrightnessOrVolume = disableAdjustBrightnessOrVolume;
}

-(void)setShowInView:(UIView *)showInView {
    _showInView = showInView;
    [_showInView addSubview:self];
}

-(void)setShowControlView:(BOOL)showControlView {
    _showControlView = showControlView;
    if (!showControlView) {
        [_controlView removeFromSuperview];
    }
}
-(void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;
    self.playerManager.playerLayer.videoGravity = _videoGravity;
}

-(void)setAutoReplay:(BOOL)autoReplay {
    _autoReplay = autoReplay;
    self.playerManager.autoReplay = autoReplay;
    self.controlView.autoReplay = autoReplay;
}

-(void)setShowTitleBar:(BOOL)showTitleBar{
    _showTitleBar = showTitleBar;
    self.controlView.showTitleBar = showTitleBar;
}

#pragma mark -- Lazy Func -----

-(FZAVPlayerControlView *)controlView{
    if (_controlView == nil) {
        _controlView = [[FZAVPlayerControlView alloc] init];
        _controlView.delegate = self;
        [self addSubview:_controlView];
    }
    return _controlView;
}



-(FZAVPlayerItemHandler *)itemHandler{
    if (_itemHandler== nil) {
        _itemHandler = [FZAVPlayerItemHandler new];
    }
    return _itemHandler;
}


-(FZAVPlayerManager *)playerManager {
    if (_playerManager == nil) {
        _playerManager = [FZAVPlayerManager sharedPlayer];
        _playerManager.delegate = self;
        [self.layer addSublayer:_playerManager.playerLayer];
    }
    return _playerManager;
}


@end
