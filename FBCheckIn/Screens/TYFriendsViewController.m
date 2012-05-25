//
//  TYFriendsViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYFriendsViewController.h"
#import "TYCheckInViewController.h"

@interface TYFriendsViewController ()
-(void) checkInButtonClicked:(id) sender;
@end

@implementation TYFriendsViewController

-(id) initWithTabBar {
    self = [super initWithNibName:@"TYFriendsViewController" bundle:nil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"friends.png"];
        self.tabBarItem.title = @"Friends";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check-in" style:UIBarButtonItemStylePlain target:self action:@selector(checkInButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:checkInButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) checkInButtonClicked:(id) sender {
    TYCheckInViewController *checkInScreen = [[TYCheckInViewController alloc] initWithNibName:@"TYCheckInViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:checkInScreen];
    [self presentModalViewController:navigationController animated:YES];
}

@end
