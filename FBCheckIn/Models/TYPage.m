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
@synthesize phoneNumber = _phoneNumber;

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
        self.pageDescription = [pageDictionary objectForKey:@"description"];
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

-(NSString *) shortAddress {
    return [NSString stringWithFormat:@"%@, %@", self.street, self.state];
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pageId forKey:@"page_id"];
    [aCoder encodeObject:self.pageName forKey:@"page_name"];
    [aCoder encodeObject:self.pagePictureUrl forKey:@"page_picture_url"];
    [aCoder encodeObject:self.categories forKey:@"categories"];
    [aCoder encodeObject:self.pageDescription forKey:@"page_description"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.location.latitude] forKey:@"latitude"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.location.longitude] forKey:@"longitude"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.street forKey:@"street"];
    [aCoder encodeObject:self.zip forKey:@"zip"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.checkIns] forKey:@"checkins"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.fanCount] forKey:@"fan_count"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pageId = [aDecoder decodeObjectForKey:@"page_id"];
        self.pageName = [aDecoder decodeObjectForKey:@"page_name"];
        self.pagePictureUrl = [aDecoder decodeObjectForKey:@"page_picture_url"];
        self.categories = [aDecoder decodeObjectForKey:@"categories"];
        self.pageDescription = [aDecoder decodeObjectForKey:@"page_description"];
        float latitude = [[aDecoder decodeObjectForKey:@"latitude"] floatValue];
        float longitude = [[aDecoder decodeObjectForKey:@"longitude"] floatValue];
        self.location = CLLocationCoordinate2DMake(latitude, longitude);
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.country = [aDecoder decodeObjectForKey:@"country"];
        self.state = [aDecoder decodeObjectForKey:@"state"];
        self.street = [aDecoder decodeObjectForKey:@"street"];
        self.zip = [aDecoder decodeObjectForKey:@"zip"];
        self.checkIns = [[aDecoder decodeObjectForKey:@"checkins"] intValue];
        self.fanCount = [[aDecoder decodeObjectForKey:@"fan_count"] intValue];
    }
    return self;
}

@end
