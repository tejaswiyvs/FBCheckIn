//
//  TYCheckIn.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYUser.h"
#import "TYPage.h"
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

@interface TYCheckIn : NSObject<NSCoding>

@property (nonatomic, strong) NSNumber *checkInId;
@property (nonatomic, strong) NSDate *checkInDate;
@property (nonatomic, strong) TYUser *user;
@property (nonatomic, strong) NSMutableArray *taggedUsers;
@property (nonatomic, strong) TYPage *page;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *likes;
@property (nonatomic, assign) CLLocationCoordinate2D location;

-(id) initWithDictionary:(NSDictionary *) checkInDictionary;

@end
