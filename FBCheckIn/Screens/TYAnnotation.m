//
//  TYAnnotation.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYAnnotation.h"

@implementation TYAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;
@synthesize pictureUrl = _pictureUrl;
@synthesize user = _user;

-(id) initWithCoordinate:(CLLocationCoordinate2D) coordinate {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
    }
    return self;
}

@end
