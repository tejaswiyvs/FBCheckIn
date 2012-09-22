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
@synthesize sex = _sex;
@synthesize middleName = _middleName;

-(id) initWithDictionary:(NSDictionary *) userDictionary {
    self = [super init];
    if (self) {
        self.userId = [[userDictionary objectForKey:@"uid"] stringValue];
        self.userName = [userDictionary objectForKey:@"username"];
        self.sex = [userDictionary objectForKey:@"sex"];
        self.firstName = [userDictionary objectForKey:@"first_name"];
        self.lastName = [userDictionary objectForKey:@"last_name"];
        self.middleName = [userDictionary objectForKey:@"middle_name"];
        self.fullName = [userDictionary objectForKey:@"name"];
        self.profilePictureUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", self.userName];
    }
    return self;
}

-(NSString *) shortName {
    return [NSString stringWithFormat:@"%@ %@.", self.firstName, [self.lastName substringToIndex:1]];
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userId forKey:@"uid"];
    [aCoder encodeObject:self.userName forKey:@"username"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeObject:self.firstName forKey:@"first_name"];
    [aCoder encodeObject:self.lastName forKey:@"last_name"];
    [aCoder encodeObject:self.middleName forKey:@"middle_name"];
    [aCoder encodeObject:self.fullName forKey:@"name"];
    [aCoder encodeObject:self.profilePictureUrl forKey:@"profile_picture_url"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.userId = [aDecoder decodeObjectForKey:@"uid"];
    self.userName = [aDecoder decodeObjectForKey:@"username"];
    self.sex = [aDecoder decodeObjectForKey:@"sex"];
    self.firstName = [aDecoder decodeObjectForKey:@"first_name"];
    self.lastName = [aDecoder decodeObjectForKey:@"last_name"];
    self.middleName = [aDecoder decodeObjectForKey:@"middle_name"];
    self.fullName = [aDecoder decodeObjectForKey:@"name"];
    self.profilePictureUrl = [aDecoder decodeObjectForKey:@"profile_picture_url"];
    return self;
}
@end
