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
#import "TYFBRequest.h"

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
    
    // Set the right image for liked / shared buttons depending on status
    [self refreshLikeAndShareButtons];
}

-(IBAction) logout:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLogoutNotification object:nil]];
}

-(IBAction)supportButtonClicked:(id)sender {
    
}

-(IBAction)likeButtonClicked:(id)sender {
    TYFBRequest *request = [[TYFBRequest alloc] init];
    [request likeOnFacebook];
    [self setLiked:YES];
    [self refreshLikeAndShareButtons];
}

-(IBAction)shareButtonClicked:(id)sender {
    TYFBRequest *request = [[TYFBRequest alloc] init];
    [request shareOnFacebook];
    [self setShared:YES];
    [self refreshLikeAndShareButtons];
}

#pragma mark - Helpers

-(void) refreshLikeAndShareButtons {
    if ([self liked]) {
        [self.likeButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    else {
        [self.likeButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }

    if ([self shared]) {
        [self.shareButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    else {
        [self.shareButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
}

-(BOOL) liked {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"liked"];
}

-(void) setLiked:(BOOL) liked {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:liked forKey:@"liked"];
    [defaults synchronize];
    return;
}

-(BOOL) shared {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"shared"];
}

-(void) setShared:(BOOL) shared {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:shared forKey:@"shared"];
    [defaults synchronize];
    return;
}
@end
