//
//  FZAVPlayerControlView.m
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZAVPlayerControlView.h"

#import "FZAVPlayerTitleBar.h"
#import "FZAVPlayerToolBar.h"
#import "FZAVPlayerLightView.h"
#import "FZAVPlayerVolumeView.h"

#import "FZAVPlayerBundle.h"

@interface FZAVPlayerControlView ()

@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,strong) FZAVPlayerTitleBar *titleBar;
@property (nonatomic,strong) FZAVPlayerToolBar  *toolBar;
@property (nonatomic,strong) FZAVPlayerLightView  *lightControlView;
@property (nonatomic,strong) FZAVPlayerVolumeView *volumeControlView;

@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *retryButton;

/** 小菊花 */
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic,strong) NSTimer        *timer;
@property (nonatomic,assign) NSInteger      timeCount;
@property (nonatomic,assign) NSTimeInterval totalInterVals;
@property (nonatomic,assign) BOOL           isSliding;

@property (nonatomic,assign,readonly) CGFloat titleBarHeight;
@property (nonatomic,strong) NSLayoutConstraint *layoutTitleBarTop;
@property (nonatomic,strong) NSLayoutConstraint *layoutTitleBarHeight;

@end

@implementation FZAVPlayerControlView


#pragma mark -- Life Cycle Func ------------

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        self.playerStatus  = FZAVPlayerStatusPrepare;
        self.playerStyle  = FZAVPlayerViewStyleNormal;
        [self timer];
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    [self contentView];
    [self titleBar];
    [self toolBar];
    
    [self lightControlView];
    [self volumeControlView];
    
    [self playButton];
    [self retryButton];
    [self indicatorView];
    [self.contentView bringSubviewToFront:self.playButton];
    [self.contentView bringSubviewToFront:self.retryButton];
    
}




#pragma mark -- Customs Func ----

-(void)showControlViewWithfireTimer:(BOOL)fire{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
        if (self.viewDidAppearHandler) {
            self.viewDidAppearHandler();
        }
        
        if (fire) {
            [self fireTimer];
        }
    }];
}

-(void)hideControlView{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.viewDidDisappearHandler) {
            self.viewDidDisappearHandler();
        }
        [self cancelTimer];
    }];
}

-(void)fireTimer{
    [self.timer fire];
}

-(void)cancelTimer{
    self.timeCount = 0;
    //取消定时器
    [self.timer invalidate];
    self.timer = nil;
}

/** 转换成显示的时间 */
+ (NSString *)convertTime:(CGFloat)second{
    
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}


#pragma mark -- Action Func ----

-(void)backButtonAction:(UIButton*)sender {
    if (self.playerStyle == FZAVPlayerViewStyleFullScreen) {
        if (self.showTitleBar) {
            self.layoutTitleBarTop.constant = 0;
        }else{
            self.layoutTitleBarTop.constant = -self.titleBarHeight;
        }
        self.playerStyle = FZAVPlayerViewStyleNormal;
        if ([self.delegate respondsToSelector:@selector(control:playerStyleChanged:)]) {
            [self.delegate control:self playerStyleChanged:self.playerStyle];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(control:didClickedWithBackButton:)]) {
            [self.delegate control:self didClickedWithBackButton:sender];
        }
    }
}

-(void)controlViewTapAction:(UITapGestureRecognizer*)sender{
    
    if (self.playerStatus == FZAVPlayerStatusLoading) return;
    
    if (self.contentView.alpha == 1) {
        [self hideControlView];
    }else{
        [self showControlViewWithfireTimer:YES];
    }
}

- (void)timerAction:(NSTimer *)sender {
    if (self.timeCount < 1.5) {
        self.timeCount++;
    } else {
        [self cancelTimer];
        [self hideControlView];
    }
}

- (void)fullScreenButtonAction:(UIButton *)sender {
    if (self.playerStyle == FZAVPlayerViewStyleFullScreen) {
        if (self.showTitleBar) {
            self.layoutTitleBarTop.constant = 0;
            
        }else{
            self.layoutTitleBarTop.constant = -self.titleBarHeight;
        }
        self.playerStyle = FZAVPlayerViewStyleNormal;
    } else {
        self.layoutTitleBarTop.constant = 0;
        self.playerStyle = FZAVPlayerViewStyleFullScreen;
    }
}

-(void)playButtonAction:(UIButton *)sender {
    if (sender.selected) {
        [self cancelTimer];
        self.playerStatus = FZAVPlayerStatusPaused;
        if ([self.delegate respondsToSelector:@selector(control:pauseAction:)]) {
            [self.delegate control:self pauseAction:sender];
        }
    }else{
        [self cancelTimer];
        [self showControlViewWithfireTimer:NO];
        self.playerStatus = FZAVPlayerStatusPlaying;
        if ([self.delegate respondsToSelector:@selector(control:playAction:)]) {
            [self.delegate control:self playAction:sender];
        }
    }
//    if (self.playerStatus == FZAVPlayerStatusPaused ||
//        self.playerStatus == FZAVPlayerStatusPrepare ||
//        self.playerStatus == FZAVPlayerStatusFinished) {
//        [self cancelTimer];
//        [self showControlViewWithfireTimer:NO];
//        self.playerStatus = FZAVPlayerStatusPlaying;
//        if ([self.delegate respondsToSelector:@selector(control:playAction:)]) {
//            [self.delegate control:self playAction:sender];
//        }
//    } else if (self.playerStatus == FZAVPlayerStatusPlaying) {
//        [self cancelTimer];
//        self.playerStatus = FZAVPlayerStatusPaused;
//        if ([self.delegate respondsToSelector:@selector(control:pauseAction:)]) {
//            [self.delegate control:self pauseAction:sender];
//        }
//    }
}

-(void)retryButtonAction:(UIButton *)sender {
    self.playerStatus = FZAVPlayerStatusPlaying;
    if ([self.delegate respondsToSelector:@selector(control:playAction:)]) {
        [self.delegate control:self playAction:sender];
    }
}

- (void)progressChanged:(UISlider *)sender {
    //赋值播放时间
    self.toolBar.currentTimeLabel.text = [FZAVPlayerControlView convertTime:sender.value];
    
    //进度条变化回调
    if ([self.delegate respondsToSelector:@selector(control:progressChanged:)]) {
        [self.delegate  control:self progressChanged:sender.value];
    }
}

- (void)progressTouchDown:(UISlider *)sender {
    FZAVPlayerSlider *slider = (FZAVPlayerSlider *)sender;
    slider.singleTapGesture.enabled = NO;
    self.isSliding = YES;
    
    [self cancelTimer];
    
    if ([self.delegate respondsToSelector:@selector(control:sliderChanged:)]) {
        [self.delegate control:self sliderChanged:self.isSliding];
    }
}

- (void)progressTouchUp:(UISlider *)sender {
    FZAVPlayerSlider *slider = (FZAVPlayerSlider *)sender;
    slider.singleTapGesture.enabled = YES;
    self.isSliding = NO;
    
    [self fireTimer];
    
    if ([self.delegate respondsToSelector:@selector(control:sliderChanged:)]) {
        [self.delegate control:self sliderChanged:self.isSliding];
    }
}

#pragma mark -- Set Func -------

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.toolBar.playProgress layoutIfNeeded];
}

-(void)setTotalInterval:(NSTimeInterval)totalInterval{
    _totalInterval = totalInterval;
    self.toolBar.totalTimeLabel.text = [FZAVPlayerControlView convertTime:totalInterval];
    self.toolBar.playProgress.maximumValue = totalInterval;
    _totalInterVals = totalInterval;
}

-(void)setBufferInterval:(NSTimeInterval)bufferInterval{
    _bufferInterval = bufferInterval;
    CGFloat scale = 0;
    if (bufferInterval) {
        if (bufferInterval<self.totalInterval) {
            scale = _bufferInterval/self.totalInterval;
        }else{
            scale = 1;
        }
    }else{
        scale = 0;
    }
    self.toolBar.bufferProgress.value = scale;
    self.toolBar.buffer_track_right.constant = -(1 - scale) * self.toolBar.bufferProgress.frame.size.width;
}

-(void)setProgressInterval:(NSTimeInterval)progressInterval{
    _progressInterval = progressInterval;
    self.toolBar.currentTimeLabel.text = [FZAVPlayerControlView convertTime:progressInterval];
    self.toolBar.playProgress.value = progressInterval;
}
-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleBar.titleLabel.text = title;
}

-(void)setPlayerStatus:(FZAVPlayerStatus)playerStatus {
    
    _playerStatus = playerStatus;
    switch (playerStatus) {
        case FZAVPlayerStatusPrepare:{
            //重置toolBar
            self.toolBar.currentTimeLabel.text = @"00:00";
            self.toolBar.playProgress.value = 0;
        } break;
        case FZAVPlayerStatusPlaying:{
            //播放,重播 按钮
            self.playButton.selected = YES;
            self.playButton.alpha = 1;
            self.retryButton.alpha = 0;
            [self.indicatorView stopAnimating];
        } break;
        case FZAVPlayerStatusPaused:
        case FZAVPlayerStatusSeeking:{
            //播放,重播 按钮
            self.playButton.selected = NO;
            self.playButton.alpha = 1;
            self.retryButton.alpha = 0;
        } break;
        case FZAVPlayerStatusLoading:{
            //播放,重播 按钮
            self.playButton.selected = NO;
            self.playButton.alpha = 1;
            self.retryButton.alpha = 0;
            [self.indicatorView startAnimating];
            [self showControlViewWithfireTimer:NO];
        } break;
        case FZAVPlayerStatusFinished:{
            //播放,重播 按钮
            self.playButton.selected = NO;
            self.playButton.alpha = 0;
            if (self.autoReplay) {
                self.retryButton.alpha = 0;
            }else{
                self.retryButton.alpha = 1;
            }
            [self showControlViewWithfireTimer:YES];
            //重置toolBar
            self.toolBar.currentTimeLabel.text = @"00:00";
            self.toolBar.playProgress.value = 0;
        } break;
        case FZAVPlayerStatusStoped:{
            
        } break;
        default:
            break;
    }
 
}

-(void)setPlayerStyle:(FZAVPlayerViewStyle)playerStyle {
    
    if (_playerStyle != playerStyle) {
        _playerStyle = playerStyle;
        if ([self.delegate respondsToSelector:@selector(control:playerStyleChanged:)]) {
            [self.delegate control:self playerStyleChanged:playerStyle ];
        }
    }
    if (_playerStyle == FZAVPlayerViewStyleFullScreen) {
        self.lightControlView.userInteractionEnabled =  true;
        self.volumeControlView.userInteractionEnabled = true;
        self.toolBar.fullScreenButton.selected = NO;
        self.titleBar.backButton.alpha = 1;
        self.layoutTitleBarTop.constant = 0;
        
        if ([self isIPhoneXSeries]) {
            self.titleBar.layoutBackLeft.constant = 20;
            self.toolBar.layoutFullScreenRight.constant = -20;
        }else{
            self.titleBar.layoutBackLeft.constant = 0;
            self.toolBar.layoutFullScreenRight.constant = 0;
        }
        
        UIDevice *device = [UIDevice currentDevice];
        if (device.orientation == UIDeviceOrientationPortrait ||
            device.orientation == UIDeviceOrientationUnknown) {
            if ([self isIPhoneXSeries]) {
                self.layoutTitleBarHeight.constant = 44 + self.titleBarHeight;
            }else{
                self.layoutTitleBarHeight.constant = self.titleBarHeight;
            }
        }else{
            self.layoutTitleBarHeight.constant = self.titleBarHeight;
        }
        
    } else if (_playerStyle == FZAVPlayerViewStyleNormal) {
        self.lightControlView.userInteractionEnabled = !self.disableAdjustBrightnessOrVolume;
        self.volumeControlView.userInteractionEnabled = !self.disableAdjustBrightnessOrVolume;
        
        self.layoutTitleBarHeight.constant = self.titleBarHeight;
        
        self.toolBar.fullScreenButton.selected = YES;
        self.toolBar.layoutFullScreenRight.constant = 0;
        if (self.showTitleBar) {
            if (self.showBackBtn == NO) {
                self.titleBar.backButton.alpha = 0;
            }
            self.layoutTitleBarTop.constant = 0;
            self.titleBar.layoutBackLeft.constant = 0;
        }else{
            self.layoutTitleBarTop.constant = -self.titleBarHeight;
        }
    }
}

-(void)setDisableFullScreen:(BOOL)disableFullScreen{
    _disableFullScreen = disableFullScreen;
    if (_disableFullScreen == YES) {
        self.toolBar.fullScreenButton.alpha = 0;
        self.toolBar.layoutFullScreenRight.constant = 35;
    }else{
        self.toolBar.fullScreenButton.alpha = 1;
    }
}

-(void)setDisableAdjustBrightnessOrVolume:(BOOL)disableAdjustBrightnessOrVolume{
    _disableAdjustBrightnessOrVolume = disableAdjustBrightnessOrVolume;
    self.lightControlView.userInteractionEnabled = !disableAdjustBrightnessOrVolume;
    self.volumeControlView.userInteractionEnabled = !disableAdjustBrightnessOrVolume;
}

- (void)setShowBackBtn:(BOOL)showBackBtn {
    _showBackBtn = showBackBtn;
    if (!_showBackBtn && self.playerStyle == FZAVPlayerViewStyleNormal) {
        self.titleBar.backButton.alpha = 0;
    }
}

#pragma mark -- Lazy Func -------

-(UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.alpha = 0;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        
        [self addConstraints:@[top,left,bottom,right]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlViewTapAction:)];
        [self addGestureRecognizer:tap];
    }
    return _contentView;
}



-(FZAVPlayerTitleBar *)titleBar{
    if (_titleBar == nil) {
        _titleBar = [[FZAVPlayerTitleBar alloc]init];
        
        _titleBar.backgroundColor = [UIColor blackColor];
        
        [self.contentView addSubview:_titleBar];
        _titleBar.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:self.showTitleBar?0:-self.titleBarHeight];
        self.layoutTitleBarTop = top;
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.titleBarHeight];
        self.layoutTitleBarHeight = height;
        [self.contentView addConstraints:@[top,left,right,height]];
        
        [_titleBar.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _titleBar;
}

-(FZAVPlayerToolBar *)toolBar{
    if (_toolBar == nil) {
        _toolBar = [[FZAVPlayerToolBar alloc]init];
        
        _toolBar.backgroundColor = [UIColor blackColor];
        
        [self.contentView addSubview:_toolBar];
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.contentView addConstraints:@[left,bottom,right,height]];
        
        [_toolBar.playProgress addTarget:self action:@selector(progressTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_toolBar.playProgress addTarget:self action:@selector(progressChanged:) forControlEvents:UIControlEventValueChanged];
        __weak __typeof(self) weakSelf = self;
        _toolBar.playProgress.singleTapAcitonHandler = ^(UISlider * _Nonnull sender) {
            [weakSelf progressChanged:sender];
        };
        [_toolBar.playProgress addTarget:self action:@selector(progressTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        [_toolBar.fullScreenButton addTarget:self action:@selector(fullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolBar;
}



-(FZAVPlayerLightView *)lightControlView{
    if (_lightControlView == nil) {
        _lightControlView = [[FZAVPlayerLightView alloc] init];
        __weak __typeof(self) weakSelf = self;
        _lightControlView.touchActionBlock = ^(UIGestureRecognizerState state) {
            switch (state) {
                case UIGestureRecognizerStateBegan:{
                    [weakSelf cancelTimer];
                    break;}
                case UIGestureRecognizerStateEnded:{
                    [weakSelf fireTimer];
                    break;}
                default:
                    break;
            }
        };
        [self.contentView addSubview:_lightControlView];
        _lightControlView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_lightControlView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.titleBar
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1 constant:0];
        NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:_lightControlView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1 constant:0];
        NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:_lightControlView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.toolBar
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1 constant:0];
        NSLayoutConstraint * width = [NSLayoutConstraint constraintWithItem:_lightControlView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0.5 constant:0];
        
        [self.contentView addConstraints:@[top,left,bottom,width]];
        
        
        
    }
    return _lightControlView;
}

-(FZAVPlayerVolumeView *)volumeControlView{
    if (_volumeControlView == nil) {
        
        _volumeControlView = [[FZAVPlayerVolumeView alloc] init];
        __weak __typeof(self) weakSelf = self;
        _volumeControlView.touchActionBlock = ^(UIGestureRecognizerState state) {
            switch (state) {
                case UIGestureRecognizerStateBegan:{
                    [weakSelf cancelTimer];
                    break;}
                case UIGestureRecognizerStateEnded:{
                    [weakSelf fireTimer];
                    break;}
                default:
                    break;
            }
        };
        [self.contentView addSubview:_volumeControlView];
        _volumeControlView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_volumeControlView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.titleBar
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1 constant:0];
        NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:_volumeControlView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.toolBar
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1 constant:0];
        NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:_volumeControlView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1 constant:0];
        NSLayoutConstraint * width = [NSLayoutConstraint constraintWithItem:_volumeControlView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0.5 constant:0];
        
        [self.contentView addConstraints:@[top,bottom,right,width]];
        
        
        
    }
    return _volumeControlView;
}


-(UIButton *)playButton{
    if (_playButton == nil) {
        
        _playButton = [[UIButton alloc] init];
        [self.contentView addSubview:_playButton];
        
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_playButton
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_playButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_playButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:0 multiplier:1 constant:50];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_playButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:0 multiplier:1 constant:50];
        [self.contentView addConstraints:@[centerX,centerY,width,height]];
        
        
 
        
        
        [_playButton setImage:[FZAVPlayerBundle fz_imageNamed:@"btn_video_play_90x90"] forState:UIControlStateNormal];
        [_playButton setImage:[FZAVPlayerBundle fz_imageNamed:@"btn_video_stop_90x90"] forState:UIControlStateSelected];
        
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _playButton;
}




-(UIButton *)retryButton{
    if (_retryButton == nil) {
        _retryButton = [[UIButton alloc] init];
        
        [self.contentView addSubview:_retryButton];
        
        _retryButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil  attribute:0 multiplier:1 constant:60];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:30];
        [self.contentView addConstraints:@[centerX,centerY,width,height]];
        
        
        [_retryButton setImage:[FZAVPlayerBundle fz_imageNamed:@"btn_play_again_icon_160x80"] forState:UIControlStateNormal];
        _retryButton.alpha = 0;
        [_retryButton addTarget:self action:@selector(retryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryButton;
}


-(UIActivityIndicatorView *)indicatorView{
    if (_indicatorView == nil) {
        _indicatorView = [UIActivityIndicatorView new];
        [_indicatorView startAnimating];
        _indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_indicatorView];
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self.contentView addConstraints:@[centerX,centerY]];
    }
    return _indicatorView;
}

-(NSTimer *)timer{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    }
    return _timer;
}

-(CGFloat)titleBarHeight{
    return 40;
}

-(BOOL)isIPhoneXSeries{
    if ([UIScreen mainScreen].bounds.size.width == 375.f && [UIScreen mainScreen].bounds.size.height == 812.f) {
        return YES;
    } else if ([UIScreen mainScreen].bounds.size.width == 414.f && [UIScreen mainScreen].bounds.size.height == 896.f) {
        return YES;
    }else{
        return NO;
    }
}


@end

