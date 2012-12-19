//
//  TYSearchFriendsViewController.h
//  FBCheckIn
//
//  Created by Teja on 12/15/12.
//
//

#import "TYBaseViewController.h"
#import "Facebook.h"

@interface TYSearchFriendsViewController : TYBaseViewController<FBRequestDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *filteredFriends;
@property (nonatomic, strong) FBRequest *loadFriendsRequest;
@property (nonatomic, assign) BOOL searching;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end
