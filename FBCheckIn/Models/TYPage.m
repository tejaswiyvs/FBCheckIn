//
//  TYLocation.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYPage.h"

@implementation TYPage

@synthesize pageName = _pageName;
@synthesize pageId = _pageId;
@synthesize pagePictureUrl = _pagePictureUrl;
@synthesize pagePicture = _pagePicture;
@synthesize category = _category;
@synthesize pageDescription = _pageDescription;
@synthesize website = _website;
@synthesize street = _street;
@synthesize state = _state;
@synthesize city = _city;
@synthesize zip = _zip;
@synthesize location = _location;

-(id) initWithDictionary:(NSDictionary *) pageDictionary {
    self = [super init];
    if (self) {
        self.pageId = [pageDictionary objectForKey:@"id"];
        self.pageName = [pageDictionary objectForKey:@"name"];
        self.pagePictureUrl = [pageDictionary objectForKey:@"picture"];
        self.category = [pageDictionary objectForKey:@"category"];
        self.pageDescription = [pageDictionary objectForKey:@"about"];
        NSDictionary *locationDict = [pageDictionary objectForKey:@"location"];
        self.street = [locationDict objectForKey:@"street"];
        self.state = [locationDict objectForKey:@"state"];
        self.city = [locationDict objectForKey:@"city"];
        self.zip = [locationDict objectForKey:@"zip"];
        NSDictionary *coordinates = [locationDict objectForKey:@"coordinates"];
        NSNumber *latitude = [coordinates objectForKey:@"latitude"];
        NSNumber *longitude = [coordinates objectForKey:@"longitude"];
        self.location = CLLocationCoordinate2DMake([latitude longValue], [longitude longValue]);
    }
    return self;
}

@end
