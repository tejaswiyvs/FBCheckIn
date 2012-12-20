//
//  TYTagFriendsViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYBaseViewController.h"
#import "TYFriendCache.h"

@protocol TYTagFriendsDelegate;
@interface TYTagFriendsViewController : TYBaseViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *taggedUsers;
@property (nonatomic, strong) NSMutableArray *filteredFriends;
@property (nonatomic, strong) TYFriendCache *friendCache;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *clearTagsItem;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, strong) id<TYTagFriendsDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@protocol TYTagFriendsDelegate
-(void) taggedUsers:(NSArray *) users;
-(void) tagUsersCancelled;
@end