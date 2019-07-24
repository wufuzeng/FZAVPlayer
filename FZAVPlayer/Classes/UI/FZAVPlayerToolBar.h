//
//  FZVideoPlayerToolBar.h
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/5.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZAVPlayerSlider : UISlider


@property (nonatomic,strong) UITapGestureRecognizer *singleTapGesture;

@property (nonatomic,copy) void (^singleTapAcitonHandler)(UISlider *sender);

@end


@interface FZAVPlayerToolBar : UIView

@property (nonatomic,strong) UILabel *currentTimeLabel;
@property (nonatomic,strong) UILabel *totalTimeLabel;


@property (nonatomic,strong) UISlider *bufferProgress;
@property (nonatomic,strong) NSLayoutConstraint *buffer_track_right;
@property (nonatomic,strong) FZAVPlayerSlider *playProgress;

@property (nonatomic,strong) UIButton *fullScreenButton;

@property (nonatomic,strong) NSLayoutConstraint* layoutFullScreenRight;

@end

NS_ASSUME_NONNULL_END
