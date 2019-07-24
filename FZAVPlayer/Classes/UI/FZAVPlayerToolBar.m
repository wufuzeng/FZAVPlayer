//
//  FZAVPlayerToolBar.m
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/5.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZAVPlayerToolBar.h"

#import "FZAVPlayerBundle.h"
@interface FZAVPlayerSlider ()

@property (nonatomic,assign) CGRect lastBounds;

@end

@implementation FZAVPlayerSlider

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self singleTapGesture];
    }
    return self;
}

#define SLIDER_X_BOUND 30
#define SLIDER_Y_BOUND 40

/**
 * 滑块可触摸范围的大小
 *
 * @param bounds 是滑块的大小
 * @param rect 是进度条的尺寸
 * @param value UISlider 当前的值
 * @return 滑块可触摸范围的大小
 */
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
    rect.origin.x = rect.origin.x;
    rect.size.width = rect.size.width;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    self.lastBounds = result;
    return result;
}
/** 检查点击事件点击范围是否能够交给self处理 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //调用父类方法,找到能够处理event的view
    UIView* result = [super hitTest:point withEvent:event];
    if (result != self) {
        /*
         * 如果这个view不是self,我们给slider扩充一下响应范围,
         * 这里的扩充范围数据就可以自己设置了
         */
        if ((point.y >= -15) &&
            (point.y < (self.lastBounds.size.height + 15)) &&
            (point.x >= 0 && point.x < CGRectGetWidth(self.bounds))) {
            result = self;
        }
    }
    return result;
}
/** 检查是点击事件的点是否在slider范围内 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    //调用父类判断
    BOOL result = [super pointInside:point withEvent:event];
    if (!result) {
        //同理,如果不在slider范围类,扩充响应范围
        if ((point.x >= (CGRectGetMinX(self.lastBounds) - 15)) &&
            (point.x <= (CGRectGetMaxX(self.lastBounds) + 15)) &&
            (point.y >= -15) &&
            (point.y < (CGRectGetMaxY(self.lastBounds) + 15))) {
            result = YES;
        }
    }
    return result;
}

- (void)singleTapGestureAction:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self];
    CGFloat value = (self.maximumValue - self.minimumValue) * (touchPoint.x / self.frame.size.width );
    [self setValue:value animated:NO];
    
    if (self.singleTapAcitonHandler) {
        self.singleTapAcitonHandler(self);
    }
}

-(UITapGestureRecognizer *)singleTapGesture{
    if (_singleTapGesture == nil) {
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureAction:)];
        [self addGestureRecognizer:_singleTapGesture];
    }
    return _singleTapGesture;
}

@end


@interface FZAVPlayerToolBar ()

@end

@implementation FZAVPlayerToolBar

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    [self currentTimeLabel];
    [self bufferProgress];
    [self playProgress];
    [self totalTimeLabel];
    [self fullScreenButton];
    
    //self.bufferProgress.value = 0.5;
    //self.bufferProgress.frame.size.width
}


#pragma mark -- Lazy Func ------

-(UILabel *)currentTimeLabel{
    if (_currentTimeLabel == nil) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize:10];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_currentTimeLabel];
        
        _currentTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_currentTimeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_currentTimeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        
        NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_currentTimeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:50];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_currentTimeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:30];
        
        [self addConstraints:@[top,left,width,height]];
        
    }
    return _currentTimeLabel;
}

-(UILabel *)totalTimeLabel{
    if (_totalTimeLabel == nil) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont systemFontOfSize:10];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_totalTimeLabel];
        
        _totalTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_totalTimeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_totalTimeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.fullScreenButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-5];
        
        NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_totalTimeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:50];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_totalTimeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:30];
        
        [self addConstraints:@[top,right,width,height]];
    }
    return _totalTimeLabel;
}

-(FZAVPlayerSlider *)playProgress{
    if (_playProgress == nil){
        _playProgress = [[FZAVPlayerSlider alloc] init];
        _playProgress.minimumValue = 0;
        _playProgress.value = 0;
        _playProgress.tintColor = [UIColor whiteColor];
        [_playProgress setMaximumTrackTintColor:[UIColor colorWithWhite:0.5 alpha:0.8]];
        [_playProgress setMinimumTrackTintColor:[UIColor whiteColor]];
        [_playProgress setThumbImage:[FZAVPlayerBundle fz_imageNamed:@"icon_dot"] forState:UIControlStateNormal];
        [self addSubview:_playProgress];
        
        _playProgress.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_playProgress attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bufferProgress attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_playProgress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.bufferProgress attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        
         NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_playProgress attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bufferProgress attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        self.buffer_track_right = right;
        NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:_playProgress attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bufferProgress attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        //NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_playProgress attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
        //witdh = width;
        [self addConstraints:@[top,left,right,bottom]];
    }
    return _playProgress;
}


-(UISlider *)bufferProgress{
    if (_bufferProgress == nil){
        _bufferProgress = [[UISlider alloc] init];
        _bufferProgress.minimumValue = 0;
        _bufferProgress.value = 0;
        _bufferProgress.tintColor = [UIColor whiteColor];
        [_bufferProgress setMaximumTrackTintColor:[UIColor colorWithWhite:0.3 alpha:0.5]];
        [_bufferProgress setMinimumTrackTintColor:[UIColor whiteColor]];
        [_bufferProgress setThumbImage:[UIImage new] forState:UIControlStateNormal];
        _bufferProgress.userInteractionEnabled = NO;
        
        [self addSubview:_bufferProgress];
 
        _bufferProgress.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_bufferProgress attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_bufferProgress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.currentTimeLabel attribute:NSLayoutAttributeRight multiplier:1 constant:5];
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_bufferProgress attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.totalTimeLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:-5];
        
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_bufferProgress attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:30];
        
        [self addConstraints:@[top,left,right,height]]; 
        
    }
    return _bufferProgress;
}

-(UIButton *)fullScreenButton {
    if (_fullScreenButton == nil) {
        _fullScreenButton = [[UIButton alloc] init];
        
        [_fullScreenButton setImage:[FZAVPlayerBundle fz_imageNamed:@"narrow_btn"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[FZAVPlayerBundle fz_imageNamed:@"video_amplification"] forState:UIControlStateSelected];
        //[_fullScreenButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenButtonAction:)]];
        [self addSubview:_fullScreenButton];
        
        _fullScreenButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_fullScreenButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_fullScreenButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        self.layoutFullScreenRight = right;
        NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_fullScreenButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:30];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_fullScreenButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:30];
        
        [self addConstraints:@[top,right,width,height]];
        
    }
    return _fullScreenButton;
}
 

@end
