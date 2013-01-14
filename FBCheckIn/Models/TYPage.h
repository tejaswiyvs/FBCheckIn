//
//  TYLocation.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "TYOffer.h"

@interface TYPage : NSObject<NSCoding>

@property (nonatomic, assign) int checkIns;
@property (nonatomic, strong) NSString *pageDescription;
@property (nonatomic, assign) int fanCount;
@property (nonatomic, strong) NSString *pageName;
@property (nonatomic, strong) NSString *pageId;
@property (nonatomic, strong) NSString *coverPictureUrl;
@property (nonatomic, assign) float coverOffSetY;
@property (nonatomic, strong) NSString *pagePictureUrl;
@property (nonatomic, strong) UIImage *pagePicture;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, assign) int numberOfFriendsCheckedIn;
@property (nonatomic, strong) NSMutableArray *offers;
@property (nonatomic, strong) NSMutableArray *pagePictureUrls;

-(id) initWithDictionary:(NSDictionary *) pageDictionary;
-(NSString *) shortAddress;
-(BOOL) hasAddress;
-(BOOL) hasPhone;
@end
