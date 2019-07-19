//
//  UINavigationController+FZAVPlayer.m
//  FZAVPlayer
//
//  Created by 吴福增 on 2019/7/19.
//

#import "UINavigationController+FZAVPlayer.h"

@implementation UINavigationController (FZAVPlayer)

/**
 * 如果window的根视图是UINavigationController，则会先调用这个Category，然后调用UIViewController+ZFPlayerRotation
 * 只需要在支持除竖屏以外方向的页面重新下边三个方法
 */
    
    // 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return [self.visibleViewController shouldAutorotate];
}
    
    // 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.visibleViewController supportedInterfaceOrientations];
}
    
    // 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}
    
- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.visibleViewController;
}
    
- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.visibleViewController;
}

    
@end
