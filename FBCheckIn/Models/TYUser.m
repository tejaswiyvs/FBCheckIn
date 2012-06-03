//
//  TYUser.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYUser.h"

@implementation TYUser

@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize firstName = _firstName;
@synthesize lastName =_lastName;
@synthesize fullName = _fullName;
@synthesize profilePictureUrl = _profilePictureUrl;
@synthesize profilePicture = _profilePicture;

-(id) initWithDictionary:(NSDictionary *) userDictionary {
    self = [super init];
    if (self) {
        self.userId = [userDictionary objectForKey:@"id"];
        self.userName = [userDictionary objectForKey:@"username"];
        self.firstName = [userDictionary objectForKey:@"first_name"];
        self.lastName = [userDictionary objectForKey:@"last_name"];
        self.fullName = [userDictionary objectForKey:@"name"];
        self.profilePictureUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", self.userName];
    }
    return self;
}
@end