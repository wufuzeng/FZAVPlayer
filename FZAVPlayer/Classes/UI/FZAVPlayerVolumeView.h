//
//  FZVideoVolumeView.h
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/1/5.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZAVPlayerVolumeView : UIView

@property (nonatomic,copy) void(^touchActionBlock)(UIGestureRecognizerState state) ;

@end

NS_ASSUME_NONNULL_END
