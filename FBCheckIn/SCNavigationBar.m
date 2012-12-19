//
//  SCNavigationBar.m
//  ExampleNavBarBackground
//
//  Created by Sebastian Celis on 3/1/2012.
//  Copyright 2012-2012 Sebastian Celis. All rights reserved.
//

#import "SCNavigationBar.h"
#import "TYPlacePickerViewController.h"

@interface SCNavigationBar ()
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) NSMutableDictionary *backgroundImages;
- (void)updateBackgroundImage;
@end


@implementation SCNavigationBar

@synthesize backgroundImages = _backgroundImages;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize checkInButton = _checkInButton;

+(UINavigationController *)customizedNavigationController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
    
    // Ensure the UINavigationBar is created so that it can be archived. If we do not access the
    // navigation bar then it will not be allocated, and thus, it will not be archived by the
    // NSKeyedArchvier.
    [navController navigationBar];
    
    // Archive the navigation controller.
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:navController forKey:@"root"];
    [archiver finishEncoding];
    
    // Unarchive the navigation controller and ensure that our UINavigationBar subclass is used.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [unarchiver setClass:[SCNavigationBar class] forClassName:@"UINavigationBar"];
    UINavigationController *customizedNavController = [unarchiver decodeObjectForKey:@"root"];
    [unarchiver finishDecoding];
    
    // Modify the navigation bar to have a background image.
    SCNavigationBar *navBar = (SCNavigationBar *)[customizedNavController navigationBar];
    // [navBar setTintColor:[UIColor colorWithRed:0.39 green:0.72 blue:0.62 alpha:1.0]];
    [navBar setBackgroundImage:[UIImage imageNamed:@"nav-bar.png"] forBarMetrics:UIBarMetricsDefault];
    
    navBar.checkInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navBar.checkInButton.frame = CGRectMake(navBar.frame.size.width - 45.0f, 5.0f, 42.0f, 32.0f);
    DebugLog(@"%@", NSStringFromCGRect(navBar.checkInButton.frame));
    [navBar.checkInButton setBackgroundImage:[UIImage imageNamed:@"check-in-icon.png"] forState:UIControlStateNormal];
    [navBar.checkInButton addTarget:navBar action:@selector(checkInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navBar.checkInButton];
    
    return customizedNavController;
}

-(void) checkInButtonClicked:(id) sender {
    TYAppDelegate *appDelegate = (TYAppDelegate *) [UIApplication sharedApplication].delegate;
    [appDelegate checkInButtonClicked:sender];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    TYUser *currentUser = [TYCurrentUser sharedInstance].user;
    [mixpanel track:@"CheckInClicked" properties:[NSDictionary dictionaryWithObjectsAndKeys:currentUser.userId, @"userId", currentUser.sex, @"sex", nil]];
}

-(void) hideCheckInButton {
    [self.checkInButton setEnabled:NO];
    [self.checkInButton setHidden:YES];
}

#pragma mark - View Lifecycle

- (void)dealloc
{
    [_backgroundImages release];
    [_backgroundImageView release];
    [super dealloc];
}

#pragma mark - Background Image

- (NSMutableDictionary *)backgroundImages
{
    if (_backgroundImages == nil)
    {
        _backgroundImages = [[NSMutableDictionary alloc] init];
    }
    
    return _backgroundImages;
}

- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil)
    {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self insertSubview:_backgroundImageView atIndex:0];
    }
    
    return _backgroundImageView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics
{
    if ([UINavigationBar instancesRespondToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [super setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    }
    else
    {
        [[self backgroundImages] setObject:backgroundImage forKey:[NSNumber numberWithInt:barMetrics]];
        [self updateBackgroundImage];
    }
}

- (void)updateBackgroundImage
{
    UIBarMetrics metrics = ([self bounds].size.height > 40.0) ? UIBarMetricsDefault : UIBarMetricsLandscapePhone;
    UIImage *image = [[self backgroundImages] objectForKey:[NSNumber numberWithInt:metrics]];
    if (image == nil && metrics != UIBarMetricsDefault)
    {
        image = [[self backgroundImages] objectForKey:[NSNumber numberWithInt:UIBarMetricsDefault]];
    }
    
    if (image != nil)
    {
        [[self backgroundImageView] setImage:image];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_backgroundImageView != nil)
    {
        [self updateBackgroundImage];
        [self sendSubviewToBack:_backgroundImageView];
    }
}

@end
