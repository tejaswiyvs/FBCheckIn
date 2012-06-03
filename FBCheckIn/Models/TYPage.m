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
@synthesize categories = _categories;
@synthesize pageDescription = _pageDescription;
@synthesize website = _website;
@synthesize location = _location;
@synthesize fanCount = _fanCount;
@synthesize checkIns = _checkIns;
@synthesize city = _city;
@synthesize state = _state;
@synthesize country = _country;
@synthesize street = _street;
@synthesize zip = _zip;

-(id) initWithDictionary:(NSDictionary *) pageDictionary {
    self = [super init];
    if (self) {
        self.pageId = [[pageDictionary objectForKey:@"page_id"] stringValue];
        self.pageName = [pageDictionary objectForKey:@"name"];
        self.pagePictureUrl = [pageDictionary objectForKey:@"pic"];
        NSArray *categories = [pageDictionary objectForKey:@"category"];
        for (NSDictionary *category in categories) {
            [self.categories addObject:[category objectForKey:@"name"]];
        }
        self.pageDescription = [pageDictionary objectForKey:@"about"];
        NSDictionary *locationDict = [pageDictionary objectForKey:@"location"];
        NSNumber *latitude = [locationDict objectForKey:@"latitude"];
        NSNumber *longitude = [locationDict objectForKey:@"longitude"];
        self.location = CLLocationCoordinate2DMake([latitude longValue], [longitude longValue]);
        self.city = [locationDict objectForKey:@"city"];
        self.country = [locationDict objectForKey:@"country"];
        self.state = [locationDict objectForKey:@"state"];
        self.street = [locationDict objectForKey:@"street"];
        self.zip = [locationDict objectForKey:@"zip"];
        self.checkIns = [[pageDictionary objectForKey:@"checkins"] intValue];
        self.fanCount = [[pageDictionary objectForKey:@"fan_count"] intValue];
    }
    return self;
}

@end
