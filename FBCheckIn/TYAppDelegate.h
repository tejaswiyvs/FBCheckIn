//
//  PPAppDelegate.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYLogInViewController.h"
#import "TYFBManager.h"
#import "TYCheckInCache.h"
#import "TYFriendCache.h"
#import "Appirater.h"

@interface TYAppDelegate : UIResponder <UIApplicationDelegate, AppiraterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) TYFBManager *manager;
@property (nonatomic, strong) TYLogInViewController *loginScreen;
@property (nonatomic, strong) Mixpanel *mixPanel;
@property (nonatomic, strong) TYCheckInCache *checkInCache;
@property (nonatomic, strong) TYFriendCache *friendCache;
@property (nonatomic, strong) TYCurrentUser *currentUser;

-(void) checkInButtonClicked:(id) sender;
@end
