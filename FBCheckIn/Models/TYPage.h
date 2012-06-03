//
//  TYLocation.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TYPage : NSObject

@property (nonatomic, strong) NSString *pageId;
@property (nonatomic, strong) NSString *pageName;
@property (nonatomic, strong) NSString *pagePictureUrl;
@property (nonatomic, strong) UIImage *pagePicture;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *pageDescription;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, assign) CLLocationCoordinate2D location;

-(id) initWithDictionary:(NSDictionary *) pageDictionary;
@end
