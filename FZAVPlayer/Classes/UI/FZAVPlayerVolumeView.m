//
//  FZVideoVolumeView.m
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/5.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZAVPlayerVolumeView.h"

#import <MediaPlayer/MediaPlayer.h>

@interface FZAVPlayerVolumeView ()

@property (nonatomic,strong) UILabel *valueLabel;

@property (nonatomic,strong) UIProgressView *progressView;

@property (nonatomic,strong) MPVolumeView *volumeView;

@property (nonatomic,strong) UISlider *volumeViewSlider;

@end

@implementation FZAVPlayerVolumeView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupViews];
        
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(volumeControlTouch:)]];
        [self addObserver];
    }
    return self;
}

-(void)setupViews{
    [self valueLabel];
    [self progressView];
    self.valueLabel.alpha = self.progressView.alpha = 0;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

#pragma mark -- Notice Func ----------

-(void)addObserver{
    
    /** 改变铃声 的 通知
     
     "AVSystemController_AudioCategoryNotificationParameter" = Ringtone;    // 铃声改变
     "AVSystemController_AudioVolumeChangeReasonNotificationParameter" = ExplicitVolumeChange; // 改变原因
     "AVSystemController_AudioVolumeNotificationParameter" = "0.0625";  // 当前值
     "AVSystemController_UserVolumeAboveEUVolumeLimitNotificationParameter" = 0; 最小值
     
     
     改变音量的通知
     "AVSystemController_AudioCategoryNotificationParameter" = "Audio/Video"; // 音量改变
     "AVSystemController_AudioVolumeChangeReasonNotificationParameter" = ExplicitVolumeChange; // 改变原因
     "AVSystemController_AudioVolumeNotificationParameter" = "0.3";  // 当前值
     "AVSystemController_UserVolumeAboveEUVolumeLimitNotificationParameter" = 0; 最小值
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChange:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}


-(void)volumeChange:(NSNotification*)notifi{
    NSString * style = [notifi.userInfo objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"];
    CGFloat value = [[notifi.userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] doubleValue];
    if ([style isEqualToString:@"Ringtone"]) {
        NSLog(@"铃声改变");
    }else if ([style isEqualToString:@"Audio/Video"]){
        NSLog(@"音量改变 当前值:%f",value);
        [self showPercentValue:value];
    }
}

#pragma mark -- Gesture Func -----

-(void)volumeControlTouch:(UIPanGestureRecognizer *)sender {
    if (self.touchActionBlock) {
        self.touchActionBlock(sender.state);
    }
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            self.valueLabel.alpha = self.progressView.alpha = 1;
            break;}
        case UIGestureRecognizerStateEnded:{
            self.valueLabel.alpha = self.progressView.alpha = 0;
            break;}
        default:
            break;
    }
    
    
    CGPoint moviePoint = [sender translationInView:self];
    float volume = -moviePoint.y/2000;
    volume += self.volumeViewSlider.value;
    if (volume >= 1) {
        volume = 1;
    }else if (volume <= -1) {
        volume = 0;
    }
    
    self.volumeViewSlider.value = volume;
    [self showPercentValue:self.volumeViewSlider.value];
    //[FZAVPlayerVolumeView setSysVolumWith:volume];
    //[self showPercentValue:[FZAVPlayerVolumeView getSystemVolumValue]];
    
}

-(void)showPercentValue:(CGFloat)value {
    self.valueLabel.text = [NSString stringWithFormat:@"%.lf%%",value *100];
    self.progressView.progress = value;
}




#pragma mark -- Lazy Func ---


#pragma mark -- Lazy Func ---


-(UILabel *)valueLabel{
    if (_valueLabel == nil) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = [UIFont systemFontOfSize:18];
        _valueLabel.textColor = [UIColor whiteColor];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self.progressView addSubview:_valueLabel];
        
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_valueLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.progressView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:_valueLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.progressView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_valueLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:60];
        
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_valueLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:44];
        [self.progressView addConstraints:@[right,centerY,width,height]];
        
        
    }
    return _valueLabel;
}

-(UIProgressView *)progressView{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc]init];
        _progressView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [_progressView setProgressTintColor:[UIColor whiteColor]];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1 alpha:0.5]];
        
        [self addSubview:_progressView];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        
        NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.4 constant:0];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:2];
        
        [self addConstraints:@[centerX,centerY,width,height]];
        
        
    }
    return _progressView;
}

-(MPVolumeView *)volumeView{
    if (_volumeView == nil) {
        
        /*
         * 音量HUD是系统的HUD, 如果系统检测到没有显示 HUD, 会自动帮我们显示,
         * 所以我们要做的就是, 自己创建一个 MPVolumeView 添加到view上面.
         * 如果不需要系统的HUD的话, 我们可以把 MPVolumeView 的frame 设置为CGRectZero,
         * 或者不设置frame, 或者设置到屏幕外面,都可以.同时clipsToBounds设为YES.
         *
         * 如果需要系统的HUD的话, 直接不添加到控制器的view上面就可以,
         * 因为系统检测到没有 设置 MPVolumeView 就会自动添加
         */
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
        _volumeView.clipsToBounds = YES;
        [self addSubview:_volumeView];
    }
    return _volumeView;
}

-(UISlider *)volumeViewSlider{
    if (_volumeViewSlider == nil) {
        for (UIView* newView in self.volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider*)newView;
                break;
            }
        }
    }
    return _volumeViewSlider;
}

@end
