//
//  TYOffer.m
//  FBCheckIn
//
//  Created by Teja on 1/3/13.
//
//

#import "TYOffer.h"

@implementation TYOffer

-(id) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        self.claimLimit = [[dictionary objectForKey:@"claim_limit"] intValue];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.claimLimit = [[aDecoder decodeObjectForKey:@"claimLimit"] intValue];
        self.offerId = [aDecoder decodeObjectForKey:@"offerId"];
        self.imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        self.pageId = [aDecoder decodeObjectForKey:@"pageId"];
        self.redemptionCode = [aDecoder decodeObjectForKey:@"redemptionCode"];
        self.redemptionLink = [aDecoder decodeObjectForKey:@"redemptionLink"];
        self.terms = [aDecoder decodeObjectForKey:@"terms"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInt:self.claimLimit] forKey:@"claimLimit"];
    [aCoder encodeObject:self.offerId forKey:@"offerId"];
    [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:self.pageId forKey:@"pageId"];
    [aCoder encodeObject:self.redemptionCode forKey:@"redemptionCode"];
    [aCoder encodeObject:self.redemptionLink forKey:@"redemptionLink"];
    [aCoder encodeObject:self.terms forKey:@"terms"];
    [aCoder encodeObject:self.title forKey:@"title"];
}
@end
