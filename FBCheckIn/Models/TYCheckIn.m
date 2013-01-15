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
#import "TYLike.h"
#import "NSString+Common.h"
#import "TYUtils.h"

@implementation TYCheckIn

@synthesize checkInId = _checkInId;
@synthesize checkInDate = _checkInDate;
@synthesize likes = _likes;
@synthesize comments = _comments;
@synthesize taggedUsers = _taggedUsers;
@synthesize page = _page;
@synthesize user = _user;
@synthesize location = _location;
@synthesize message = _message;
@synthesize photo = _photo;
@synthesize type = _type;

-(id) initWithDictionary:(NSDictionary *) checkInDictionary {
    self = [super init];
    if (self) {
        // id can come from location_post or checkin tables. Rest of the fields are common.
        NSString *id1 = [[TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"id"] stringValue];
        NSString *id2 = [[TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"checkin_id"] stringValue];
        if (id1 && ![id1 isBlank]) {
            self.checkInId = id1;
        }
        else if(id2 && ![id2 isBlank]) {
            self.checkInId = id2;
        }
        self.user = [[TYUser alloc] init];
        self.page = [[TYPage alloc] init];
        self.user.userId = [[TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"author_uid"] stringValue];
        self.page.pageId = [[TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"page_id"] stringValue];
        NSDictionary *coordinates = [TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"coords"];
        NSNumber *latitude = [coordinates objectForKey:@"latitude"];
        NSNumber *longitude = [coordinates objectForKey:@"longitude"];
        self.location = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        long checkInUnixTimestamp = [[TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"timestamp"] doubleValue];;
        if (checkInUnixTimestamp) {
            self.checkInDate = [NSDate dateWithTimeIntervalSince1970:checkInUnixTimestamp];
        }
        self.message = [TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"message"];
        self.type = [TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"type"];
        self.taggedUsers = [NSMutableArray array];
        for (NSString *taggedUserId in [TYUtils nullSafeObjectFromDictionary:checkInDictionary withKey:@"tagged_uids"]) {
            TYUser *user = [[TYUser alloc] init];
            user.userId = taggedUserId;
            [self.taggedUsers addObject:user];
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
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.photo forKey:@"photo"];
    [aCoder encodeObject:self.type forKey:@"type"];
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
        self.message = [aDecoder decodeObjectForKey:@"message"];
        self.photo = [aDecoder decodeObjectForKey:@"photo"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
    }
    return self;
}

-(BOOL) hasPhoto {
    return (self.photo != nil);
}

-(BOOL) hasMessage {
    return (self.message != nil);
}

-(BOOL) isLikedByUser:(TYUser *) user {
    for (TYLike *like in self.likes) {
        if([like.user.userId isEqualToString:user.userId]) { return YES; }
    }
    return NO;
}

-(void) likeCheckIn:(TYUser *) user {
    if (!user) {
        return;
    }
    if (!self.likes) {
        self.likes = [NSMutableArray array];
    }
    for (TYLike *like in self.likes) {
        if ([like.user.userId isEqualToString:user.userId]) {
            return;
        }
    }
    TYLike *like = [[TYLike alloc] init];
    like.checkInId = self.checkInId;
    like.user = user;
    [self.likes addObject:like];
}

-(void) unlikeCheckIn:(TYUser *) user {
    if (!self.likes) {
        return;
    }
    for (TYLike *like in self.likes) {
        if ([like.user.userId isEqualToString:user.userId]) {
            [self.likes removeObject:like];
        }
    }
    return;
}
@end
