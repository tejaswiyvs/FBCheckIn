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
@end

@implementation TYFBManager

NSString * const kFBManagerLoginNotification = @"fb_mgr_login";
NSString * const kFBManagerLogOutNotification = @"fb_mgr_logout";

@synthesize facebook;

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

#pragma mark - Facebook Delegate

-(void) setupFacebook {
    self.facebook = [[Facebook alloc] initWithAppId:[self appId] andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![self.facebook isSessionValid]) {
        NSArray *permissions = [NSArray arrayWithObjects:@"user_about_me", @"friends_about_me", @"user_checkins", @"friends_checkins", @"publish_stream", nil];
        [self.facebook authorize:permissions];
    }
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self raiseLogInNotification];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    TYAppDelegate *appDelegate = (TYAppDelegate *) [UIApplication sharedApplication].delegate;
    TYLogInViewController *login = [[TYLogInViewController alloc] initWithNibName:@"TYLoginViewController" bundle:nil];
    [appDelegate.window.rootViewController presentModalViewController:login animated:YES];
    [SVProgressHUD showErrorWithStatus:@"The login was cancelled. Please login your facebook account to use this app." duration:2.5];
}

- (void)fbDidLogout {
    TYAppDelegate *appDelegate = (TYAppDelegate *) [UIApplication sharedApplication].delegate;
    TYLogInViewController *login = [[TYLogInViewController alloc] initWithNibName:@"TYLoginViewController" bundle:nil];
    [appDelegate.window.rootViewController presentModalViewController:login animated:YES];
    [self raiseLogOutNotification];
}

- (void)fbSessionInvalidated {

}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {

}

#pragma mark - Helpers

-(void) login {
    [self setupFacebook];
}

-(void) logout {
    [self.facebook logout];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kFBManagerLoginNotification object:nil];
}
@end
