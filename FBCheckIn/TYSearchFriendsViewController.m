//
//  TYSearchFriendsViewController.m
//  FBCheckIn
//
//  Created by Teja on 12/15/12.
//
//

#import "TYSearchFriendsViewController.h"
#import "TYFBManager.h"
#import "TYUser.h"
#import "TYCurrentUser.h"
#import "NSString+Common.h"
#import "TYFriendCell.h"
#import "UIImageView+AFNetworking.h"
#import "TYUserProfileViewController.h"
#import "UIColor+HexString.h"
#import "TYIndeterminateProgressBar.h"

@interface TYSearchFriendsViewController ()

@end

@implementation TYSearchFriendsViewController

-(id) init {
    self = [super initWithNibName:@"TYSearchFriendsView" bundle:nil];
    if (self) {
        self.title = @"Search";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // inits
    self.friends = [NSMutableArray array];    
    self.filteredFriends = [NSMutableArray array];
    self.searching = NO;
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor bgColor];
    [self updateSearchBarBackground];
    self.friends = [TYFriendCache sharedInstance].cachedFriends;
    
    // Incase the cache is still empty for some reason, add self as observer and trigger a refresh
    if (!self.friends || [self.friends count] == 0) {
        [self registerForNotifications];
        [[TYFriendCache sharedInstance] forceRefresh];
        [TYIndeterminateProgressBar showInView:self.view backgroundColor:[UIColor dullWhite] indicatorColor:[UIColor dullRed] borderColor:[UIColor darkGrayColor]];
    }
}

-(void) viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Bar

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searching = YES;
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocapitalizationTypeNone;
    [self.filteredFriends removeAllObjects];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searching = NO;
    [searchBar endEditing:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searching = NO;
    searchBar.showsCancelButton = NO;
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Clear search results
    [self.filteredFriends removeAllObjects];
    
    // Return if blank.
    if ([searchText isBlank]) {
        [self.tableView reloadData];
        return;
    }
    
    // Loop through, find matching friends and populate search results.
    for(TYUser *user in self.friends)
    {
        NSRange range = [user.fullName rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound)
        {
            [self.filteredFriends addObject:user];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searching) {
        return [self.filteredFriends count];
    }
    else {
        return [self.friends count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kReuseId = @"friends_cell";
    TYFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TYFriendCell" owner:self options:nil];
		for (id object in nib) {
			if([object isKindOfClass:[TYFriendCell class]])
				cell = (TYFriendCell *) object;
		}
    }
    
    TYUser *user = nil;
    if(!self.searching) {
        user = [self.friends objectAtIndex:indexPath.row];
    }
    else {
        user = [self.filteredFriends objectAtIndex:indexPath.row];
    }
    
    [cell.profilePictureImg setImageWithURL:[NSURL URLWithString:user.profilePictureUrl]
                   placeholderImage:nil];
    [cell.userNameLbl setText:[user fullName]];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYUser *selectedUser = nil;
    if(!self.searching) {
        selectedUser = [self.friends objectAtIndex:indexPath.row];
    }
    else {
        selectedUser = [self.filteredFriends objectAtIndex:indexPath.row];
    }
    TYUserProfileViewController *userProfile = [[TYUserProfileViewController alloc] initWithUser:selectedUser];
    [self.navigationController pushViewController:userProfile animated:YES];
}

#pragma mark - FriendCache

-(void) friendCacheRefreshed:(NSNotification *) notification {
    [self unregisterFromNotifications];
    [TYIndeterminateProgressBar hideFromView:self.view];
    self.friends = [TYFriendCache sharedInstance].cachedFriends;
    [self.tableView reloadData];
}

-(void) friendCacheRefreshErrored:(NSNotification *) notification {
    [self unregisterFromNotifications];
    [TYIndeterminateProgressBar hideFromView:self.view];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"There was a problem loading your friends list. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [TYIndeterminateProgressBar hideFromView:self.view];
}

#pragma mark - Helpers

-(void) updateSearchBarBackground {
    [[[self.searchBar subviews] objectAtIndex:0] setAlpha:0.0];
    self.searchBar.tintColor = [UIColor bgColor];
    [self.searchBar setClipsToBounds:YES];
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendCacheRefreshed:) name:kFriendCacheUpdateComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendCacheRefreshErrored:) name:kFriendCacheUpdateComplete object:nil];
}

-(void) unregisterFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
