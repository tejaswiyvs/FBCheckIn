//
//  TYUser.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYUser.h"
#import "TYUtils.h"

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
@synthesize coverPictureUrl = _coverPictureUrl;
@synthesize coverOffSetY = _coverOffSetY;
@synthesize hiResProfilePictureUrl = _hiResProfilePictureUrl;
@synthesize city = _city;
@synthesize state = _state;

-(id) initWithDictionary:(NSDictionary *) userDictionary {
    self = [super init];
    if (self) {
        self.userId = [[TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"uid"] stringValue];
        self.userName = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"username"];
        self.sex = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"sex"];
        self.firstName = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"first_name"];
        self.lastName = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"last_name"];
        self.middleName = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"middle_name"];
        self.fullName = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"name"];
        self.profilePictureUrl = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"pic"];
        self.hiResProfilePictureUrl = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"pic_big"];
        NSDictionary *coverDict = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"pic_cover"];
        self.coverPictureUrl = [coverDict objectForKey:@"source"];
        self.coverOffSetY = [[coverDict objectForKey:@"offset_y"] floatValue];
        NSDictionary *homeTownLocationDict = [TYUtils nullSafeObjectFromDictionary:userDictionary withKey:@"current_address"];
        self.city = [homeTownLocationDict objectForKey:@"city"];
        self.state = [homeTownLocationDict objectForKey:@"state"];
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
    [aCoder encodeObject:self.coverPictureUrl forKey:@"cover_picture_url"];
    [aCoder encodeObject:self.hiResProfilePictureUrl forKey:@"hi_res_picture_url"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.coverOffSetY] forKey:@"cover_offset_y"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.state forKey:@"state"];
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
    self.coverPictureUrl = [aDecoder decodeObjectForKey:@"cover_picture_url"];
    self.coverOffSetY = [[aDecoder decodeObjectForKey:@"cover_offset_y"] floatValue];
    self.hiResProfilePictureUrl = [aDecoder decodeObjectForKey:@"hi_res_picture_url"];
    self.city = [aDecoder decodeObjectForKey:@"city"];
    self.state = [aDecoder decodeObjectForKey:@"state"];
    return self;
}
@end
