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
    for (TYCheckIn *checkIn in self.checkIns) {
        TYAnnotation *annotation = [[TYAnnotation alloc] initWithCoordinate:checkIn.location andPicture:checkIn.user.profilePicture];
        [self.mapView addAnnotation:annotation];
    }
    [self.mapView setDelegate:self];
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
    pin.image = [TYAnnotationUtil pinImageForImage:((TYAnnotation *) annotation).picture];
    return pin;
}

@end
