//
//  TYComment.m
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import "TYComment.h"

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
        self.checkInId = [[params objectForKey:@"object_id"] stringValue];
        self.commentId = [params objectForKey:@"post_id"];
        self.text = [params objectForKey:@"text"];
        self.canLike = [[params objectForKey:@"can_like"] boolValue];
        self.userLikes = [[params objectForKey:@"user_likes"] boolValue];
        self.likes = [[params objectForKey:@"likes"] intValue];
        self.commentId = [[params objectForKey:@"commentId"] stringValue];
        self.user = [[TYUser alloc] init];
        self.user.userId = [[params objectForKey:@"fromid"] stringValue];
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
