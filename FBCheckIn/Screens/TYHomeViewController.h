//
//  TYFriendsViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "EGORefreshTableHeaderView.h"
#import "TYCheckInCache.h"

@interface TYHomeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, FBRequestDelegate, EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) BOOL reloading;

-(id) initWithTabBar;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end