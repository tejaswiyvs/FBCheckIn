//
//  TYFBManager.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYFBManager.h"
#import "TYAppDelegate.h"
#import "TYLogInViewController.h"
#import "SVProgressHUD.h"

@interface TYFBManager ()
-(void) raiseLogInNotification;
-(void) raiseLogOutNotification;
-(void) appDidBecomeActive:(NSNotification *) notification;
-(void) setupFacebook;
@end

@implementation TYFBManager

NSString * const kFBManagerLoginNotification = @"fb_mgr_login";
NSString * const kFBManagerLogOutNotification = @"fb_mgr_logout";
NSString * const kFBManagerLoginCancelledNotification = @"fb_mgr_logout";

@synthesize facebook;

-(id) init {
    self = [super init];
    if (self) {
        [self registerForNotifications];
        [self setupFacebook];
    }
    return self;
}

+(TYFBManager *) sharedInstance {
    static TYFBManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[TYFBManager alloc] init];
        }
    });
    return sharedInstance;
}

-(BOOL) isLoggedIn {
    return [self.facebook isSessionValid];
}

#pragma mark - Facebook Delegate

-(void) login {
    if (![self.facebook isSessionValid]) {
        NSArray *permissions = [NSArray arrayWithObjects:@"user_about_me", @"friends_about_me", @"user_status", @"friends_status", @"user_likes", @"friends_likes", @"publish_stream", @"user_photos", @"friends_photos", nil];
        [self.facebook authorize:permissions];
    }
}

-(void) logout {
    [self.facebook logout];
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self raiseLogInNotification];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    [self raiseLoginCancelledNotification];
}

- (void)fbDidLogout {
    [self raiseLogOutNotification];
}

- (void)fbSessionInvalidated {

}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {

}

#pragma mark - Notification Center

-(void) appDidBecomeActive:(NSNotification *) notification {
    [self.facebook extendAccessTokenIfNeeded];
}

#pragma mark - Helpers

-(void) setupFacebook {
    self.facebook = [[Facebook alloc] initWithAppId:[self appId] andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(NSString *) appId {
    NSString *configPlistPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:configPlistPath];
    return [dictionary objectForKey:@"facebook_app_id"];
}

-(void) raiseLogInNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFBManagerLoginNotification object:nil];
}

-(void) raiseLogOutNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFBManagerLogOutNotification object:nil];
}

-(void) raiseLoginCancelledNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFBManagerLoginCancelledNotification object:nil];
}
@end
