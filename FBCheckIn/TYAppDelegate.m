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
@end

@implementation TYAppDelegate

@synthesize window = _window;
@synthesize tabBar = _tabBar;
@synthesize loginScreen = _loginScreen;
@synthesize manager = _manager;
@synthesize mixPanel = _mixPanel;

NSString * const kMixpanelToken = @"";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DebugLog(@"Starting Application..");
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.manager = [TYFBManager sharedInstance];
    [self makeTabBar];
    self.window.rootViewController = self.tabBar;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    if (![self.manager isLoggedIn]) {
        DebugLog(@"Session not valid. Presenting login screen.");
        self.loginScreen = [[TYLogInViewController alloc] initWithNibName:@"TYLoginView" bundle:nil];
        [self.tabBar presentModalViewController:self.loginScreen animated:YES];
    }
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    // Override point for customization after application launch.
    self.mixPanel = [Mixpanel sharedInstanceWithToken:kMixpanelToken];
    [self.mixPanel track:@"App Launched"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DebugLog(@"Application will resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DebugLog(@"Application did enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DebugLog(@"Application will enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DebugLog(@"Application did become active");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DebugLog(@"Application will terminate");
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.manager.facebook handleOpenURL:url];
}

#pragma mark - Helpers

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

-(void) makeTabBar {
    DebugLog(@"Creating UITabBarController with Home, Map Views");
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
    DebugLog(@"Setup complete");
}

@end
