//
//  PPAppDelegate.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYUITabBarController.h"
#import "TYLogInViewController.h"
#import "TYFBManager.h"

@interface TYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) TYFBManager *manager;
@property (nonatomic, strong) TYUITabBarController *tabBar;
@property (nonatomic, strong) TYLogInViewController *loginScreen;
@property (nonatomic, strong) Mixpanel *mixPanel;

@end
