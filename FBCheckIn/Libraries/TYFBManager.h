//
//  TYFBManager.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

extern NSString * const kFBManagerLoginNotification;
extern NSString * const kFBManagerLogOutNotification;
extern NSString * const kFBManagerLoginCancelledNotification;

@interface TYFBManager : NSObject<FBSessionDelegate>

@property (nonatomic, strong) Facebook *facebook;

+(TYFBManager *) sharedInstance;
-(BOOL) isLoggedIn;
-(void) login;
-(void) logout;
@end
