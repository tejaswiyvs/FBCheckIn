//
//  TYFriendsViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface TYHomeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, FBRequestDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FBRequest *checkInRequest;
@property (nonatomic, strong) FBRequest *usersRequest;
@property (nonatomic, strong) FBRequest *pagesRequest;
@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, assign) BOOL pagesRequestCompleted;
@property (nonatomic, assign) BOOL usersRequestCompleted;


@property (nonatomic, strong) NSMutableArray *checkIns;

-(id) initWithTabBar;
@end
