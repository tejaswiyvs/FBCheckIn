// This subclass creates a raised tab bar item with the center button of a uitabbarcontroller. The button click triggers presents the center item as a modalViewController.

// NOTE: THIS ONLY WORKS IF YOU PLACE THE UITabBarController as the rootViewController of your window. If the tab bar controller is nested with in a UINavigationController, we *will* have issues. I would redirect you to https://github.com/boctor/idev-recipes/tree/master/RaisedCenterTabBar in that case. This is just intended as a convinent drag + drop replacement for your current UITabBarController

typedef enum {
    UITabBarCenterItemStyleInstagram
} UITabBarCenterItemStyles;

@interface TYRaisedTabBarController : UITabBarController
{
}

@property (nonatomic, assign) UITabBarCenterItemStyles centerItemStyle;
@property (nonatomic, strong) UIImage *centerItemImage;
@property (nonatomic, strong) UIImage *centerItemHighlightedImage;
@property (nonatomic, strong) UIViewController *centerViewController;

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

@end
