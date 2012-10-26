//
//  PPAppDelegate.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYAppDelegate.h"
#import "TYHomeViewController.h"
#import "TYPlacePickerViewController.h"
#import "TYMapViewController.h"
#import "TYFBManager.h"
#import "SCNavigationBar.h"
#import "TYUITabBarController.h"
#import "TYCurrentUser.h"

@interface TYAppDelegate ()
-(void) makeTabBar;
-(void) registerForNotifications;
-(void) presentLoginScreen;
@end

@implementation TYAppDelegate

@synthesize window = _window;
@synthesize tabBar = _tabBar;
@synthesize loginScreen = _loginScreen;
@synthesize manager = _manager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.manager = [TYFBManager sharedInstance];
    [self makeTabBar];
    self.window.rootViewController = self.tabBar;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    if (![self.manager isLoggedIn]) {
        self.loginScreen = [[TYLogInViewController alloc] initWithNibName:@"TYLoginView" bundle:nil];
        [self.tabBar presentModalViewController:self.loginScreen animated:YES];
    }
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.manager.facebook handleOpenURL:url];
}

#pragma mark - Helpers

-(void) registerForNotifications {
    
}

-(void) presentLoginScreen {

}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

-(void) makeTabBar {
    self.tabBar = [[TYUITabBarController alloc] init];
    NSMutableArray *localControllers = [NSMutableArray array];

    TYHomeViewController *homeScreen = [[TYHomeViewController alloc] initWithTabBar];
    UINavigationController *homeNavController = [SCNavigationBar customizedNavigationController];
    [homeNavController setViewControllers:[NSArray arrayWithObject:homeScreen]];
    [localControllers addObject:homeNavController];
    
    TYMapViewController *mapsScreen = [[TYMapViewController alloc] initWithTabBar];
    UINavigationController *mapsNavController = [SCNavigationBar customizedNavigationController];
    [mapsNavController setViewControllers:[NSArray arrayWithObject:mapsScreen]];
    [localControllers addObject:mapsNavController];
    
    self.tabBar.viewControllers = localControllers;
}

@end
