//
//  TYComment.h
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import <Foundation/Foundation.h>
#import "TYUser.h"

@interface TYComment : NSObject<NSCoding>

@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *checkInId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) TYUser *user;
@property (nonatomic, assign) int likes;
@property (nonatomic, assign) BOOL canLike;

-(id) initWithDictionary:(NSDictionary *) params;

@end
