//
//  TYFriendsViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "TYCheckInCache.h"
#import "TYFBRequest.h"
#import "TYCommentViewController.h"
#import "TYBaseViewController.h"

@interface TYHomeViewController : TYBaseViewController<UITableViewDelegate, UITableViewDataSource, TYFBFacadeDelegate, EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, strong) TYCheckInCache *cache;
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, strong) NSMutableArray *requests;

@end