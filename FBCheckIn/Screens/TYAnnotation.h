//
//  TYAnnotation.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TYUser.h"

@interface TYAnnotation : NSObject<MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *pictureUrl;
@property (nonatomic, strong) TYUser *user;

-(id) initWithCoordinate:(CLLocationCoordinate2D) coordinate;
@end
