//
//  TYUser.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TYUser : NSObject<NSCoding>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *profilePictureUrl;
@property (nonatomic, strong) NSString *hiResProfilePictureUrl;
@property (nonatomic, strong) UIImage *profilePicture;
@property (nonatomic, strong) NSString *coverPictureUrl;
@property (nonatomic, assign) float coverOffSetY;
@property (nonatomic, strong) NSMutableArray *top5Locations;
@property (nonatomic, strong) NSMutableArray *top5TaggedUsers;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;

-(NSString *) shortName;
-(id) initWithDictionary:(NSDictionary *) userDictionary;
@end
