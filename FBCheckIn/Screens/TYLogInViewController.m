//
//  TYLogInViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYLogInViewController.h"
#import "TYAppDelegate.h"
#import "TYFBManager.h"
#import "SVProgressHUD.h"
#import "TYUtils.h"

@interface TYLogInViewController ()
-(void) facebookDidLogin:(NSNotification *) notification;
-(void) facebookLoginWasCancelled:(NSNotification *) notification;
@end

@implementation TYLogInViewController

@synthesize user = _user;
@synthesize cache = _cache;
@synthesize logoImgView = _logoImgView;
@synthesize loginButton = _loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        DebugLog(@"Init LoginViewController. Setting up user, cache, registering for notifications.");
        self.user = [TYCurrentUser sharedInstance];
        self.cache = [TYCheckInCache sharedInstance];
        [self registerForNotifications];
        DebugLog(@"Done.");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateLogo];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)loginButtonClicked:(id)sender {
    DebugLog(@"Login button clicked");
    [[TYFBManager sharedInstance] login];
    [self.mixPanel track:@"Facebook Login Clicked"];
}

-(void) animateLogo {
    [UIView animateWithDuration:1.5 animations:^{
        [self.logoImgView setFrame:CGRectMake(self.logoImgView.frame.origin.x,
                                              self.logoImgView.frame.origin.y - 40,
                                              self.logoImgView.frame.size.width,
                                              self.logoImgView.frame.size.height)];
        self.loginButton.alpha = 1.0f;
    }];
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookDidLogin:) name:kFBManagerLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoginWasCancelled:) name:kFBManagerLoginCancelledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidLoad:) name:kCurrentUserDidLoadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidError:) name:kCurrentUserDidErrorNotification object:nil];
}

-(void) currentUserDidLoad:(NSNotification *) notification {
    DebugLog(@"Succesfully loaded user details. Logged in : Username: %@, UserId: %@", self.user.user.userName, self.user.user.userId);
    [SVProgressHUD dismiss];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) currentUserDidError:(NSNotification *) notification {
    DebugLog(@"Userlogin failed");
    [SVProgressHUD dismiss];
    [TYUtils displayAlertWithTitle:@"Attention" message:@"There was an error getting your credentials from facebook. Please try logging in again"];
}

-(void) facebookDidLogin:(NSNotification *) notification {
    [self.mixPanel track:@"Facebook Login Succesful"];
    DebugLog(@"Facebook login succesful. Loading current user details..");
    [SVProgressHUD showWithStatus:@"Setting up.." maskType:SVProgressHUDMaskTypeBlack];
    [self.user loadCurrentUser];
}

-(void) facebookLoginWasCancelled:(NSNotification *) notification {
    DebugLog(@"Facebook login failed.");
    [self.mixPanel track:@"Facebook Login Cancelled"];
    [TYUtils displayAlertWithTitle:@"Attention" message:@"You need to login with your facebook account to continue using this application"];
}

@end
