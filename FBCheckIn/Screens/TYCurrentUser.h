//
//  TYCurrentUser.h
//  FBCheckIn
//
//  Created by Teja on 10/21/12.
//
//

#import <Foundation/Foundation.h>
#import "TYUser.h"
#import "TYFBRequest.h"

extern NSString * const kCurrentUserDidLoadNotification;
extern NSString * const kCurrentUserDidErrorNotification;

@interface TYCurrentUser : NSObject<TYFBRequestDelegate>

@property (nonatomic, strong) TYUser *user;
@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) TYFBRequest *request;

+(TYCurrentUser *) sharedInstance;
-(void) loadCurrentUser;
-(void) clearCache;
@end
