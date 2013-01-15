//
//  TYPhoto.m
//  FBCheckIn
//
//  Created by Teja on 10/17/12.
//
//

#import "TYPhoto.h"
#import "TYUtils.h"

@implementation TYPhoto

@synthesize objectId = _objectId;
@synthesize src = _src;
@synthesize srcHeight = _srcHeight;
@synthesize srcWidth = _srcWidth;

-(id) initWithDictionary:(NSDictionary *) params {
    self = [super init];
    if (self) {
        self.objectId = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"object_id"] stringValue];
        self.src = [TYUtils nullSafeObjectFromDictionary:params withKey:@"src_big"];
        self.srcWidth = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"src_big_width"] intValue];
        self.srcHeight = [[TYUtils nullSafeObjectFromDictionary:params withKey:@"src_big_height"] intValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.objectId forKey:@"objectId"];
    [aCoder encodeObject:self.src forKey:@"src"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.srcWidth] forKey:@"srcWidth"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.srcHeight] forKey:@"srcHeight"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.objectId = [aDecoder decodeObjectForKey:@"objectId"];
        self.src = [aDecoder decodeObjectForKey:@"src"];
        self.srcWidth = [[aDecoder decodeObjectForKey:@"srcWidth"] intValue];
        self.srcHeight = [[aDecoder decodeObjectForKey:@"srcHeight"] intValue];
    }
    return self;
}



@end
