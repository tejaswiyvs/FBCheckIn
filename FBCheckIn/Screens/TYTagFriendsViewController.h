//
//  TYTagFriendsViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "TYBaseViewController.h"

@protocol TYTagFriendsDelegate;
@interface TYTagFriendsViewController : TYBaseViewController<FBRequestDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *taggedUsers;
@property (nonatomic, strong) NSMutableArray *filteredFriends;
@property (nonatomic, strong) FBRequest *loadFriendsRequest;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, strong) id<TYTagFriendsDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@end

@protocol TYTagFriendsDelegate
-(void) taggedUsers:(NSArray *) users;
-(void) tagUsersCancelled;
@end