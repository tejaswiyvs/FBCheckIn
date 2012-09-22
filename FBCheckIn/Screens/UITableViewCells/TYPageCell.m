//
//  TYPageCell.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYPageCell.h"

@interface TYPageCell ()
-(NSString *) distanceBetweenCoordinate:(CLLocationCoordinate2D) location1 andCoordinate:(CLLocationCoordinate2D) location2;
-(double) feetFromMeters:(double) meters;
-(NSString *) plainTextFromFeet:(double) feet;
@end

@implementation TYPageCell

@synthesize pageImage = _pageImage;
@synthesize pageAddress = _pageAddress;
@synthesize pageDistance = _pageDistance;
@synthesize pageName = _pageName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setPageDistanceWithCoorindate1:(CLLocationCoordinate2D) location1 andCoordinate2:(CLLocationCoordinate2D) location2 { 
    [self.pageDistance setText:[self distanceBetweenCoordinate:location1 andCoordinate:location2]];
}

-(NSString *) distanceBetweenCoordinate:(CLLocationCoordinate2D) location1 andCoordinate:(CLLocationCoordinate2D) location2 {
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:location1.latitude longitude:location1.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:location2.latitude longitude:location2.longitude];
    CLLocationDistance meters = [loc2 distanceFromLocation:loc1];
    double feet = [self feetFromMeters:meters];
    return [self plainTextFromFeet:feet];
}

-(double) feetFromMeters:(double) meters {
    return meters * 3.2808399;
}

-(NSString *) plainTextFromFeet:(double) feet {
    if (feet < 50) {
        return [NSString stringWithFormat:@"About %d feet away.", (int) feet];;
    }
    else if (feet < 100) {
        return @"Around 100 feet away.";
    }
    else if (feet < 250) {
        return @"Around 250 feet away.";
    }
    else if(feet < 528) {
        return @"Around 0.1 miles away.";
    }
    else if(feet < 1320) {
        return @"Around 0.25 miles away.";
    }
    else if(feet < 2640) {
        return @"Around 0.5 miles away.";
    }
    else if(feet < 5280) {
        return @"About a mile away.";
    }
    else if(feet < 5280*2) {
        return @"About two miles away.";
    }
    return @"Prettyyyy far off.";
}


@end
