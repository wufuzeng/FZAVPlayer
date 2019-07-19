
# 你刚好需要，我刚好出现，请赏一颗小星星.

 

<div>

横屏效果：
<br />
<div>
<img src="https://github.com/wufuzeng/FZAVPlayer/blob/master/Screenshots/example87.png" title="" float=left width = '1000px'>
</div>
<div>
竖屏效果：
<img src="https://github.com/wufuzeng/FZAVPlayer/blob/master/Screenshots/example88.png" title="" float=left width = '400px'>
</div>


# FZAVPlayer
##  特征
- [x]  1.  封装源生 AVPlayer 。
- [x]  2.  支持横竖屏切换。
- [x]  3.  支持亮度调节。
- [x]  4.  支持音量调节。
- [x]  5.  支持进度调节。



[![CI Status](https://img.shields.io/travis/wufuzeng/FZAVPlayer.svg?style=flat)](https://travis-ci.org/wufuzeng/FZAVPlayer)
[![Version](https://img.shields.io/cocoapods/v/FZAVPlayer.svg?style=flat)](https://cocoapods.org/pods/FZAVPlayer)
[![License](https://img.shields.io/cocoapods/l/FZAVPlayer.svg?style=flat)](https://cocoapods.org/pods/FZAVPlayer)
[![Platform](https://img.shields.io/cocoapods/p/FZAVPlayer.svg?style=flat)](https://cocoapods.org/pods/FZAVPlayer)

## 例

要运行示例项目，请克隆repo，然后从Example目录运行 ”pod install“。

## 要求


## 安装

FZAVPlayer 可通过[CocoaPods](https://cocoapods.org)获得. 要安装它，只需将以下行添加到Podfile文件

```ruby
pod 'FZAVPlayer'
```

## 怎样使用

* Objective-C

```objective-c

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]  pathForResource:@"Test"  ofType:@"mov"]];
    self.player.title = @"屌丝男士";
    [self.playerView playWithUrl:url];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.playerView play];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.playerView stop]; 
}

-(FZAVPlayerView *)playerView{
    if (_playerView == nil) {
        _playerView = [[FZAVPlayerView alloc]initWithFrame:CGRectMake(0, 200,   [UIScreen  mainScreen].bounds.size.width, [UIScreen     mainScreen].bounds.size.width)];
        _playerView.showControlView = YES;
        _playerView.showTitleBar = YES;
        _playerView.showBackBtn = NO;
        _playerView.autoReplay = YES;
        _playerView.disableFullScreen = NO;
        _playerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerView.showInView = self.view;
    }
    return _playerView;
}

```

* Swift

```swift

//swif代码

```


## 作者

wufuzeng, wufuzeng_lucky@sina.com
### 纵有疾风起，人生不言弃

## 许可证

FZAVPlayer is available under the MIT license. See the LICENSE file for more info.
