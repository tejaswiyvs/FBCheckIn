//
//  TYMapViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TYBaseViewController.h"

@interface TYMapViewController : TYBaseViewController<MKMapViewDelegate>

@property (nonatomic, strong) NSMutableArray *checkIns;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@end
