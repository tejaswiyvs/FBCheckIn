//
//  PPAppDelegate.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYAppDelegate.h"
#import "TYFriendsViewController.h"
#import "TYCheckInViewController.h"
#import "TYMapViewController.h"

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
    [self makeTabBar];
    self.window.rootViewController = self.tabBar;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Helpers

-(void) makeTabBar {
    self.tabBar = [[UITabBarController alloc] init];
    NSMutableArray *localControllers = [NSMutableArray array];

    TYFriendsViewController *homeScreen = [[TYFriendsViewController alloc] initWithTabBar];
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
