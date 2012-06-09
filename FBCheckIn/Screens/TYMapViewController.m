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

@interface TYMapViewController ()

@end

@implementation TYMapViewController

@synthesize checkIns = _checkIns;
@synthesize mapView = _mapView;

-(id) initWithTabBar {
    self = [super initWithNibName:@"TYMapViewController" bundle:nil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"map.png"];
        self.tabBarItem.title = @"Map";
        self.title = @"Find my friends";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.checkIns = ((TYAppDelegate *) [UIApplication sharedApplication].delegate).checkIns;
    for (TYCheckIn *checkIn in self.checkIns) {
        TYAnnotation *annotation = [[TYAnnotation alloc] initWithCoordinate:checkIn.location andPicture:checkIn.user.profilePicture];
        [self.mapView addAnnotation:annotation];
    }
    [self.mapView setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
