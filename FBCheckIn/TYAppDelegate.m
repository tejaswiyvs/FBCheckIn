//
//  PPAppDelegate.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYAppDelegate.h"
#import "TYHomeViewController.h"
#import "TYCheckInViewController.h"
#import "TYMapViewController.h"
#import "TYFBManager.h"

@interface TYAppDelegate ()
-(void) makeTabBar;
@end

@implementation TYAppDelegate

@synthesize window = _window;
@synthesize tabBar = _tabBar;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    TYFBManager *manager = [TYFBManager sharedInstance];
    [manager login];
    [self makeTabBar];
    self.window.rootViewController = self.tabBar;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    TYFBManager *manager = [TYFBManager sharedInstance];
    [manager.facebook extendAccessTokenIfNeeded];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    TYFBManager *manager = [TYFBManager sharedInstance];
    return [manager.facebook handleOpenURL:url]; 
}

#pragma mark - Helpers

-(void) makeTabBar {
    self.tabBar = [[UITabBarController alloc] init];
    NSMutableArray *localControllers = [NSMutableArray array];

    TYHomeViewController *homeScreen = [[TYHomeViewController alloc] initWithTabBar];
    UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:homeScreen];
    [localControllers addObject:homeNavController];
    
    // Hack around having the middle button for UITabBarController
    /* TYCheckInViewController *checkInScreen = [[TYCheckInViewController alloc] initWithNibName:@"TYCheckInViewController" bundle:nil];
    UINavigationController *checkInNavController = [[UINavigationController alloc] initWithRootViewController:checkInScreen];
    [localControllers addObject:checkInNavController]; */
    
    TYMapViewController *mapsScreen = [[TYMapViewController alloc] initWithTabBar];
    UINavigationController *mapsNavController = [[UINavigationController alloc] initWithRootViewController:mapsScreen];
    [localControllers addObject:mapsNavController];
    
    self.tabBar.viewControllers = localControllers;
}

@end
