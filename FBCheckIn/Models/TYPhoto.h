//
//  TYPhoto.h
//  FBCheckIn
//
//  Created by Teja on 10/17/12.
//
//

#import <Foundation/Foundation.h>

@interface TYPhoto : NSObject<NSCoding>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *src;
@property (nonatomic, assign) int srcWidth;
@property (nonatomic, assign) int srcHeight;

-(id) initWithDictionary:(NSDictionary *) params;

@end
