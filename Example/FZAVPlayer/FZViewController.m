//
//  FZViewController.m
//  FZAVPlayer
//
//  Created by wufuzeng on 07/19/2019.
//  Copyright (c) 2019 wufuzeng. All rights reserved.
//

#import "FZViewController.h"

#import <FZAVPlayer.h>
@interface FZViewController ()
    @property (nonatomic,strong) FZAVPlayerView *playerView;
    
    @property (nonatomic,strong) UIScrollView *scrollView;
    
    @end

@implementation FZViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self scrollView];
    //    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loginvideo" ofType:@"mp4"]];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Test" ofType:@"mov"]];
    NSURL *url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"3" ofType:@"mp4"]];
    self.playerView.title = @"屌丝男士";
    
    self.playerView.videoQueue = @[
                                   [AVURLAsset assetWithURL:url2],
                                   [AVURLAsset assetWithURL:url]
                                   ];
    [self.playerView play];
}
    
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.playerView stop];
}
    
-(void)dealloc{
    NSLog(@"%@释放了",NSStringFromClass([self class]));
}
    
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.playerView play];
    
    
}
    
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.playerView pause];
    
    
}
    
-(UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     [UIScreen mainScreen].bounds.size.width,
                                                                     [UIScreen mainScreen].bounds.size.height)];
        [self.view addSubview:_scrollView];
        _scrollView.backgroundColor = [UIColor orangeColor];
        _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    return _scrollView;
}
    
    
-(FZAVPlayerView *)playerView{
    if (_playerView == nil) {
        _playerView = [[FZAVPlayerView alloc]initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
        _playerView.showControlView = YES;
        _playerView.showTitleBar = YES;
        _playerView.showBackBtn = NO;
        _playerView.autoReplay = YES;
        _playerView.disableFullScreen = NO;
        _playerView.singleCirclePlay = YES;
        _playerView.disableAdjustBrightnessOrVolume = NO;
        _playerView.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerView.showInView = self.scrollView;
    }
    return _playerView;
}
    
    @end
