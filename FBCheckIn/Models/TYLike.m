//
//  TYLike.m
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import "TYLike.h"
#import "TYUtils.h"

@implementation TYLike

@synthesize checkInId = _checkInId;
@synthesize user = _user;

-(id) initWithDictionary:(NSDictionary *) params {
    self = [super init];
    if (self) {
        self.checkInId = [TYUtils nullSafeObjectFromDictionary:params withKey:@"object_id"];
        self.user = [[TYUser alloc] init];
        self.user.userId = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"user_id"] stringValue];
    }
    return self;
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.checkInId forKey:@"checkInId"];
    [aCoder encodeObject:self.user forKey:@"user"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.checkInId = [aDecoder decodeObjectForKey:@"checkInId"];
        self.user = [aDecoder decodeObjectForKey:@"user"];
    }
    return self;
}

@end
