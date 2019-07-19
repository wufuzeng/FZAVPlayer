#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FZAVPlayerBundle.h"
#import "FZAVPlayerItem.h"
#import "FZAVPlayerManager.h"
#import "FZAVPlayerView.h"
#import "FZAVPlayer.h"
#import "FZAVPlayerControlView.h"
#import "FZAVPlayerLightView.h"
#import "FZAVPlayerTitleBar.h"
#import "FZAVPlayerToolBar.h"
#import "FZAVPlayerVolumeView.h"

FOUNDATION_EXPORT double FZAVPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char FZAVPlayerVersionString[];

