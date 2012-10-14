//
//  TYCheckIn.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYCheckIn.h"
#import "TYUser.h"
#import "TYPage.h"

@implementation TYCheckIn

@synthesize checkInId = _checkInId;
@synthesize checkInDate = _checkInDate;
@synthesize likes = _likes;
@synthesize comments = _comments;
@synthesize taggedUsers = _taggedUsers;
@synthesize page = _page;
@synthesize user = _user;
@synthesize location = _location;

-(id) initWithDictionary:(NSDictionary *) checkInDictionary {
    self = [super init];
    if (self) {
        self.checkInId = [[checkInDictionary objectForKey:@"checkin_id"] stringValue];
        self.user = [[TYUser alloc] init];
        self.page = [[TYPage alloc] init];
        self.user.userId = [checkInDictionary objectForKey:@"author_uid"];
        self.page.pageId = [checkInDictionary objectForKey:@"page_id"];
        NSDictionary *coordinates = [checkInDictionary objectForKey:@"coords"];
        NSNumber *latitude = [coordinates objectForKey:@"latitude"];
        NSNumber *longitude = [coordinates objectForKey:@"longitude"];
        self.location = CLLocationCoordinate2DMake([latitude longValue], [longitude longValue]);
        long checkInUnixTimestamp = [[checkInDictionary objectForKey:@"timestamp"] doubleValue];;
        if (checkInUnixTimestamp) {
            self.checkInDate = [NSDate dateWithTimeIntervalSince1970:checkInUnixTimestamp];
        }
    }
    return self;
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.checkInId forKey:@"checkin_id"];
    [aCoder encodeObject:self.checkInDate forKey:@"checkin_date"];
    [aCoder encodeObject:self.user forKey:@"user"];
    [aCoder encodeObject:self.taggedUsers forKey:@"taggedUsers"];
    [aCoder encodeObject:self.page forKey:@"page"];
    [aCoder encodeObject:self.comments forKey:@"comments"];
    [aCoder encodeObject:self.likes forKey:@"likes"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.location.latitude] forKey:@"latitude"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.location.longitude] forKey:@"longitude"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.checkInId = [aDecoder decodeObjectForKey:@"checkin_id"];
        self.checkInDate = [aDecoder decodeObjectForKey:@"checkin_date"];
        self.user = [aDecoder decodeObjectForKey:@"user"];
        self.taggedUsers = [aDecoder decodeObjectForKey:@"taggedUsers"];
        self.page = [aDecoder decodeObjectForKey:@"page"];
        self.comments = [aDecoder decodeObjectForKey:@"comments"];
        self.likes = [aDecoder decodeObjectForKey:@"likes"];
        float latitude = [[aDecoder decodeObjectForKey:@"latitude"] floatValue];
        float longitude = [[aDecoder decodeObjectForKey:@"longitude"] floatValue];
        self.location = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}

@end
