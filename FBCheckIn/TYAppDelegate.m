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
#import "TYCurrentUser.h"
#import "MFSideMenu.h"
#import "TYFriendCache.h"
#import "TYSettingsViewController.h"
#import "Appirater.h"

@interface TYAppDelegate ()
@end

@implementation TYAppDelegate

@synthesize window = _window;
@synthesize loginScreen = _loginScreen;
@synthesize manager = _manager;
@synthesize mixPanel = _mixPanel;
@synthesize checkInCache = _checkInCache;
@synthesize friendCache = _friendCache;
@synthesize currentUser = _currentUser;

NSString * const kMixpanelToken = @"89bdac1836eed79c9b92634ffbe3b173";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DDLogInfo(@"Starting Application..");
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.mixPanel = [Mixpanel sharedInstanceWithToken:kMixpanelToken];
    [self.mixPanel track:@"App Launched"];
    self.manager = [TYFBManager sharedInstance];
    self.window.rootViewController = [self sideMenu].navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    if (![self.manager isLoggedIn]) {
        DDLogInfo(@"Session not valid. Presenting login screen.");
        self.loginScreen = [[TYLogInViewController alloc] initWithNibName:@"TYLoginView" bundle:nil];
        [self.window.rootViewController presentModalViewController:self.loginScreen animated:NO];
    }
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    // Override point for customization after application launch.
    // Force refresh friends on app launch
    self.friendCache = [TYFriendCache sharedInstance];
    [self.friendCache forceRefresh];
    self.checkInCache = [TYCheckInCache sharedInstance];
    [self registerForNotifications];
    self.currentUser = [TYCurrentUser sharedInstance];    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.checkInCache commit];
    DDLogInfo(@"Application will resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogInfo(@"Application did enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogInfo(@"Application will enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DDLogInfo(@"Application did become active");
    [self configureRater];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogInfo(@"Application will terminate");
    [self unregisterFromNotifications];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.manager.facebook handleOpenURL:url];
}

#pragma mark - NSNotification

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotificationReceived:) name:kLogoutNotification object:nil];
    [[self sideMenu].navigationController popToRootViewControllerAnimated:NO];
}

-(void) unregisterFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) logoutNotificationReceived:(NSNotification *) notification {
    DDLogInfo(@"Logging Out..");
    [self.checkInCache clearCache];
    [self.friendCache clearCache];
    [self.currentUser clearCache];
    [self.manager logout];
    self.loginScreen = [[TYLogInViewController alloc] initWithNibName:@"TYLoginView" bundle:nil];
    [self.window.rootViewController presentModalViewController:self.loginScreen animated:NO];
}

#pragma mark - Appirater

-(void) configureRater {
    // Configure app-iRater
    [Appirater setAppId:@"596726594"];
    [Appirater setDelegate:self];
    [Appirater setUsesUntilPrompt:10];
    [Appirater appEnteredForeground:YES];
}

#pragma mark - Helpers

-(void) checkInButtonClicked:(id)sender {
    DDLogInfo(@"Checkin button clicked. Launching PlacePicker");
    TYPlacePickerViewController *checkInScreen = [[TYPlacePickerViewController alloc] initWithNibName:@"TYPlacePickerView" bundle:nil];
    UINavigationController *navigationController = [SCNavigationBar customizedNavigationController];
    navigationController.viewControllers = [NSArray arrayWithObject:checkInScreen];
    [self.window.rootViewController presentModalViewController:navigationController animated:YES];
}

void uncaughtExceptionHandler(NSException *exception) {
    DDLogInfo(@"CRASH: %@", exception);
    DDLogInfo(@"Stack Trace: %@", [exception callStackSymbols]);
}

#pragma mark - SideMenu

- (UINavigationController *)navigationController {
    UINavigationController *navigationController = [SCNavigationBar customizedNavigationController];
    navigationController.viewControllers = [NSArray arrayWithObject:[self homeController]];
    return navigationController;
}

- (MFSideMenu *)sideMenu {
    SideMenuViewController *sideMenuController = [[SideMenuViewController alloc] init];
    UINavigationController *navigationController = [self navigationController];
    
    MFSideMenuOptions options = MFSideMenuOptionMenuButtonEnabled|MFSideMenuOptionBackButtonEnabled
    |MFSideMenuOptionShadowEnabled;
    MFSideMenuPanMode panMode = MFSideMenuPanModeNavigationBar|MFSideMenuPanModeNavigationController;
    
    MFSideMenu *sideMenu = [MFSideMenu menuWithNavigationController:navigationController
                                                 sideMenuController:sideMenuController
                                                           location:MFSideMenuLocationLeft
                                                            options:options
                                                            panMode:panMode];
    
    sideMenuController.sideMenu = sideMenu;
    
    return sideMenu;
}

-(UIViewController *) homeController {
    return [[TYHomeViewController alloc] init];
}

@end
