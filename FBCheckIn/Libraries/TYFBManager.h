//
//  TYFBManager.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

NSString * const kFBManagerLoginNotification;
NSString * const kFBManagerLogOutNotification;

@interface TYFBManager : NSObject<FBSessionDelegate>

@property (nonatomic, strong) Facebook *facebook;

+(TYFBManager *) sharedInstance;
-(void) login;
-(void) logout;
@end
