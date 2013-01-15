//
//  TYMapViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYMapViewController.h"
#import "TYAppDelegate.h"
#import "TYAnnotation.h"
#import "TYCheckIn.h"
#import "TYAnnotationUtil.h"
#import "TYCheckInCache.h"
#import "MKAnnotationView+WebCache.h"
#import "TYUserProfileViewController.h"

@interface TYMapViewController ()

@end

@implementation TYMapViewController

@synthesize checkIns = _checkIns;
@synthesize mapView = _mapView;

-(id) init {
    self = [super initWithNibName:@"TYMapViewController" bundle:nil];
    if (self) {
        self.title = @"Find my friends";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get only one check-in / user.
    [self loadCheckIns];
    [self.mapView setDelegate:self];
    
    // Add annotations.
    for (TYCheckIn *checkIn in self.checkIns) {
        TYAnnotation *annotation = [[TYAnnotation alloc] initWithCoordinate:checkIn.location];
        annotation.pictureUrl = checkIn.user.profilePictureUrl;
        annotation.user = checkIn.user;
        [self.mapView addAnnotation:annotation];
    }
}

- (void) dealloc
{
    self.mapView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"map_view_reuse_id"];
    if (pin == nil)
    {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"map_view_reuse_id"];
    }
    else
    {
        pin.annotation = annotation;
    }
    pin.animatesDrop = NO;
    [pin setImageWithURL:[NSURL URLWithString:((TYAnnotation *) annotation).pictureUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        pin.image = [TYAnnotationUtil pinImageForImage:image];
    }];
    return pin;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    TYUser *selectedUser = ((TYAnnotation *) view.annotation).user;
    TYUserProfileViewController *nextScreen = [[TYUserProfileViewController alloc] initWithUser:selectedUser];
    [self.navigationController pushViewController:nextScreen animated:YES];
}

#pragma mark - Helpers

-(void) loadCheckIns {
    self.checkIns = [TYCheckInCache sharedInstance].checkIns;
    NSMutableArray *checkInArr = [NSMutableArray array];
    for (TYCheckIn *checkIn in self.checkIns) {
        if (![self checkInArray:checkInArr containsUser:checkIn.user]) {
            [checkInArr addObject:checkIn];
        }
    }
    self.checkIns = checkInArr;
}

-(BOOL) checkInArray:(NSMutableArray *) checkIns containsUser:(TYUser *) user {
    if (!user) {
        return YES;
    }
    
    for (TYCheckIn *checkIn2 in checkIns) {
        if ([checkIn2.user.userId isEqualToString:user.userId]) {
            return YES;
        }
    }
    return NO;
}

@end
