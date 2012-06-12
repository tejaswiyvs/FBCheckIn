//
//  TYPageCell.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TYPageCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *pageImage;
@property (nonatomic, strong) IBOutlet UILabel *pageName;
@property (nonatomic, strong) IBOutlet UILabel *pageAddress;
@property (nonatomic, strong) IBOutlet UILabel *pageDistance;

-(void) setPageDistanceWithCoorindate1:(CLLocationCoordinate2D) location1 andCoordinate2:(CLLocationCoordinate2D) location2;
@end
