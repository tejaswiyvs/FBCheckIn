//
//  TYLocation.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYPage.h"
#import "NSString+Common.h"
#import "TYUtils.h"

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
@synthesize numberOfFriendsCheckedIn = _numberOfFriendsCheckedIn;
@synthesize offers = _offers;
@synthesize coverPictureUrl = _coverPictureUrl;
@synthesize coverOffSetY = _coverOffSetY;
@synthesize pagePictureUrls = _pagePictureUrls;

-(id) initWithDictionary:(NSDictionary *) pageDictionary {
    self = [super init];
    if (self) {
        self.pageId = [[TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"page_id"] stringValue];
        self.pageName = [TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"name"];
        self.pagePictureUrl = [TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"pic"];
        NSArray *categories = [TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"categories"];
        self.categories = [NSMutableArray array];
        for (NSDictionary *category in categories) {
            [self.categories addObject:[category objectForKey:@"name"]];
        }
        self.pageDescription = [TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"description"];
        NSDictionary *locationDict = [TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"location"];
        NSNumber *latitude = [locationDict objectForKey:@"latitude"];
        NSNumber *longitude = [locationDict objectForKey:@"longitude"];
        self.location = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        self.city = [locationDict objectForKey:@"city"];
        self.country = [locationDict objectForKey:@"country"];
        self.state = [locationDict objectForKey:@"state"];
        self.street = [locationDict objectForKey:@"street"];
        self.zip = [locationDict objectForKey:@"zip"];
        self.checkIns = [[TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"checkins"] intValue];
        self.fanCount = [[TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"fan_count"] intValue];
        self.phoneNumber = [TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"phone"];
        // Loaded at a later point if needed.
        self.numberOfFriendsCheckedIn = 0;
        NSDictionary *coverDict = [TYUtils nullSafeObjectFromDictionary:pageDictionary withKey:@"pic_cover"];
        self.coverPictureUrl = [coverDict objectForKey:@"source"];
        self.coverOffSetY = [[coverDict objectForKey:@"offset_y"] floatValue];
    }
    return self;
}

-(NSString *) shortAddress {
    // Street & State Present
    NSString *shortAddress = @"";
    if (self.street && ![self.street isBlank]) {
        shortAddress = [shortAddress stringByAppendingString:self.street];
    }
    
    if(self.city && ![self.city isBlank]) {
        if (![shortAddress isBlank]) {
            shortAddress = [shortAddress stringByAppendingString:@", "];
        }
        shortAddress = [shortAddress stringByAppendingString:self.city];
    }
    
    if(self.state && ![self.state isBlank]) {
        if (![shortAddress isBlank]) {
            shortAddress = [shortAddress stringByAppendingString:@", "];
        }
        shortAddress = [shortAddress stringByAppendingString:self.state];
    }
    
    if(self.country && ![self.country isBlank]) {
        if (![shortAddress isBlank]) {
            shortAddress = [shortAddress stringByAppendingString:@", "];
        }
        shortAddress = [shortAddress stringByAppendingString:self.country];
    }
    
    return shortAddress;
}

-(BOOL) hasAddress {
    return ![[self shortAddress] isBlank];
}

-(BOOL) hasPhone {
    return !(!_phoneNumber || [self.phoneNumber isBlank]);
}

-(NSString *) phoneNumber {
    return _phoneNumber ? _phoneNumber : @"NA";
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
    [aCoder encodeObject:self.offers forKey:@"offers"];
    [aCoder encodeObject:self.coverPictureUrl forKey:@"coverPictureUrl"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.coverOffSetY] forKey:@"coverOffSetY"];
    [aCoder encodeObject:self.pagePictureUrls forKey:@"pagePictureUrls"];
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
        self.offers = [aDecoder decodeObjectForKey:@"offers"];
        self.coverPictureUrl = [aDecoder decodeObjectForKey:@"coverPictureUrl"];
        self.coverOffSetY = [[aDecoder decodeObjectForKey:@"coverOffSetY"] floatValue];
        self.pagePictureUrls = [aDecoder decodeObjectForKey:@"pagePictureUrls"];
    }
    return self;
}

@end
