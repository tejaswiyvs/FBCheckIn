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
-(void) loadMetaData;
@end

@implementation TYCheckInDetailViewController

@synthesize userNameLbl = _userNameLbl;
@synthesize pagePictureView = _pagePictureView;
@synthesize pageNameLbl = _pageNameLbl;
@synthesize pageDescriptionTxtView = _pageDescriptionTxtView;
@synthesize pageAddressLbl = _pageAddressLbl;
@synthesize tableView = _tableView;

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
    
    // Set Page Title
    [self setTitle:self.checkIn.user.userName];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    // Load data from check-in object
    self.pageNameLbl.text = self.checkIn.page.pageName;
    self.pageAddressLbl.text = self.checkIn.page.shortAddress;
    self.pageDescriptionTxtView.text = self.checkIn.page.pageDescription;
    [self.pagePictureView setImageWithURL:[NSURL URLWithString:self.checkIn.page.pagePictureUrl]];
    
    // Setup tableView
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;

    // Load comments and likes
    [self loadMetaData];
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

-(void) loadMetaData {
    // Load meta data and display when it's done. Don't block the user however.
}

@end
