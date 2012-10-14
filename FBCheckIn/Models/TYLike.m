//
//  TYLike.m
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import "TYLike.h"

@implementation TYLike

@synthesize checkInId = _checkInId;
@synthesize user = _user;

-(id) initWithDictionary:(NSDictionary *) params {
    self = [super init];
    if (self) {
        self.checkInId = [[params objectForKey:@"object_id"] stringValue];
        self.user = [[TYUser alloc] init];
        self.user.userId = [params objectForKey:@"user_id"];
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
