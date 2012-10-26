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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.user = [TYCurrentUser sharedInstance];
        self.cache = [TYCheckInCache sharedInstance];
        [self registerForNotifications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [[TYFBManager sharedInstance] login];
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookDidLogin:) name:kFBManagerLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoginWasCancelled:) name:kFBManagerLoginCancelledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidLoad:) name:kCurrentUserDidLoadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidError:) name:kCurrentUserDidErrorNotification object:nil];
}

-(void) currentUserDidLoad:(NSNotification *) notification {
    [SVProgressHUD dismiss];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) currentUserDidError:(NSNotification *) notification {
    [SVProgressHUD dismiss];
    [TYUtils displayAlertWithTitle:@"Attention" message:@"There was an error getting your credentials from facebook. Please try logging in again"];
}

-(void) facebookDidLogin:(NSNotification *) notification {
    [SVProgressHUD showWithStatus:@"Setting up.." maskType:SVProgressHUDMaskTypeBlack];
    [self.user loadCurrentUser];
}

-(void) facebookLoginWasCancelled:(NSNotification *) notification {
    [TYUtils displayAlertWithTitle:@"Attention" message:@"You need to login with your facebook account to continue using this application"];
}

@end
