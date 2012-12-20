//
//  TYLogInViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYCurrentUser.h"
#import "TYUser.h"
#import "Facebook.h"
#import "TYCheckInCache.h"
#import "TYFBManager.h"
#import "TYBaseViewController.h"
#import "TYFriendCache.h"

@interface TYLogInViewController : TYBaseViewController

@property (nonatomic, strong) TYCheckInCache *cache;
@property (nonatomic, strong) TYFriendCache *friendCache;
@property (nonatomic, strong) TYCurrentUser *user;
@property (nonatomic, strong) IBOutlet UIImageView *logoImgView;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;

-(IBAction)loginButtonClicked:(id)sender;
@end
