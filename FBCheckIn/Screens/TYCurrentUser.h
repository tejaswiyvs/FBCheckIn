//
//  TYCurrentUser.h
//  FBCheckIn
//
//  Created by Teja on 10/21/12.
//
//

#import <Foundation/Foundation.h>
#import "TYUser.h"
#import "TYFBFacade.h"

extern NSString * const kCurrentUserDidLoadNotification;
extern NSString * const kCurrentUserDidErrorNotification;

@interface TYCurrentUser : NSObject<TYFBFacadeDelegate>

@property (nonatomic, strong) TYUser *user;
@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) TYFBFacade *facade;

+(TYCurrentUser *) sharedInstance;
-(void) loadCurrentUser;
-(void) clearCache;
@end
