//
//  TYSettingsViewController.m
//  FBCheckIn
//
//  Created by Teja on 12/21/12.
//
//

#import "TYSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HexString.h"

@interface TYSettingsViewController ()

@end

@implementation TYSettingsViewController

NSString * const kLogoutNotification = @"logout";

@synthesize aboutTxtView = _aboutTxtView;

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
    self.aboutTxtView.backgroundColor = [UIColor dullWhite];
    [self.aboutTxtView.layer setCornerRadius:3.0f];
    [self.aboutTxtView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [self.aboutTxtView.layer setBorderWidth:1.0f];
    self.view.backgroundColor = [UIColor bgColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) logout:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLogoutNotification object:nil]];
}

-(IBAction)supportButtonClicked:(id)sender {
    
}

@end
