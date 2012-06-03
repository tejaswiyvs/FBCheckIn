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
        self.checkInId = [checkInDictionary objectForKey:@"checkin_id"];
        self.user = [[TYUser alloc] init];
        self.page = [[TYPage alloc] init];
        self.user.userId = [checkInDictionary objectForKey:@"author_uid"];
        self.page.pageId = [checkInDictionary objectForKey:@"page_id"];
        NSDictionary *coordinates = [checkInDictionary objectForKey:@"coords"];
        NSNumber *latitude = [coordinates objectForKey:@"latitude"];
        NSNumber *longitude = [coordinates objectForKey:@"longitude"];
        self.location = CLLocationCoordinate2DMake([latitude longValue], [longitude longValue]);
    }
    return self;
}

@end
