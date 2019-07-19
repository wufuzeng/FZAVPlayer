//
//  FZAVPlayer.h
//  Pods
//
//  Created by 吴福增 on 2019/7/19.
//
/**
 在iOS平台使用播放视频，可用的选项一般有这四个，他们各自的作用和功能如下：
 
 视频播放类                  使用环境                优点                   缺点          支持以下格式
 MPMoviePlayerController    MediaPlayer         简单易用                 不可定制
 AVPlayerViewController     AVKit               简单易用                 不可定制      .mov、.mp4、.mpv、.3gp。
 AVPlayer                   AVFoundation        可定制度高，功能强大       不支持流媒体
 IJKPlayer                  IJKMediaFramework   定制度高，支持流媒体播放    使用稍复杂
 
 由此可以看出，如果我们不做直播功能AVPlayer就是一个最优的选择。
 
 AVPlayer：控制播放器的播放，暂停，播放速度
 AVURLAsset : AVAsset 的一个子类，使用 URL 进行实例化，实例化对象包换 URL 对应视频资源的所有信息。
 AVPlayerItem：管理资源对象，提供播放数据源
 AVPlayerLayer：负责显示视频，如果没有添加该类，只有声音没有画面
 
 */

#ifndef FZAVPlayer_h
#define FZAVPlayer_h

#import "FZAVPlayerItem.h"
#import "FZAVPlayerManager.h"

#import "FZAVPlayerView.h"

#endif /* FZAVPlayer_h */
