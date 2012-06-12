//
//  TYCheckInDetailViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYCheckInDetailViewController.h"
#import "TYUser.h"
#import "TYPage.h"
#import "UIImageView+AFNetworking.h"

@interface TYCheckInDetailViewController ()

@end

@implementation TYCheckInDetailViewController

@synthesize userNameLbl = _userNameLbl;
@synthesize pagePictureView = _pagePictureView;
@synthesize pageNameLbl = _pageNameLbl;
@synthesize pageDescriptionTxtView = _pageDescriptionTxtView;
@synthesize pageAddressLbl = _pageAddressLbl;

@synthesize checkIn = _checkIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:self.checkIn.user.userName];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.pagePictureView = nil;
    self.pageNameLbl = nil;
    self.pageAddressLbl = nil;
    self.pageDescriptionTxtView = nil;
    self.userNameLbl = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
