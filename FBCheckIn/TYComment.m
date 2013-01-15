//
//  TYComment.m
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import "TYComment.h"
#import "TYUtils.h"

@implementation TYComment

@synthesize checkInId = _checkInId;
@synthesize text = _text;
@synthesize canLike = _canLike;
@synthesize likes = _likes;
@synthesize user = _user;
@synthesize commentId = _commentId;

-(id) initWithDictionary:(NSDictionary *) params {
    self = [super init];
    if (self) {
        self.checkInId = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"object_id"] stringValue];
        self.commentId = [TYUtils nullSafeObjectFromDictionary:params withKey:@"post_id"];
        self.text = [TYUtils nullSafeObjectFromDictionary:params withKey:@"text"];
        self.canLike = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"can_like"] boolValue];
        self.userLikes = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"user_likes"] boolValue];
        self.likes = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"likes"] intValue];
        self.commentId = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"comment_id"] stringValue];
        self.user = [[TYUser alloc] init];
        self.user.userId = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"fromid"] stringValue];
    }
    return self;
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.checkInId forKey:@"checkInId"];
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.canLike] forKey:@"canLike"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.likes] forKey:@"likes"];
    [aCoder encodeObject:self.commentId forKey:@"commentId"];
    [aCoder encodeObject:self.user forKey:@"user"];

}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.checkInId = [aDecoder decodeObjectForKey:@"checkInId"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.canLike = [[aDecoder decodeObjectForKey:@"canLike"] boolValue];
        self.likes = [[aDecoder decodeObjectForKey:@"likes"] intValue];
        self.commentId = [aDecoder decodeObjectForKey:@"commentId"];
        self.user = [aDecoder decodeObjectForKey:@"user"];
    }
    return self;
}


@end
