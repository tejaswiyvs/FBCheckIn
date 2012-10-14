//
//  TYLike.h
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import <Foundation/Foundation.h>
#import "TYUser.h"

@interface TYLike : NSObject<NSCoding>

@property (nonatomic, strong) NSString *checkInId;
@property (nonatomic, strong) TYUser *user;

-(id) initWithDictionary:(NSDictionary *) params;
@end
