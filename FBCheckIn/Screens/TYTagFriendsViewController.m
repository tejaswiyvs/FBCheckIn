//
//  TYTagFriendsViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYTagFriendsViewController.h"
#import "TYFBManager.h"
#import "UIImageView+AFNetworking.h"
#import "TYUser.h"
#import "TYTagUserCell.h"
#import "NSString+Common.h"
#import "UIBarButtonItem+Convinience.h"
#import "UIColor+HexString.h"
#import "TYIndeterminateProgressBar.h"

@interface TYTagFriendsViewController ()
-(BOOL) userBelongsToTaggedUsers:(TYUser *) user;
-(void) doneButtonClicked:(id) sender;
-(void) cancelButtonClicked:(id) sender;
@end

@implementation TYTagFriendsViewController

@synthesize friends = _friends;
@synthesize filteredFriends = _filteredFriends;
@synthesize taggedUsers = _taggedUsers;
@synthesize tableView = _tableView;
@synthesize searching = _searching;
@synthesize searchBar = _searchBar;
@synthesize cancelItem = _cancelItem;
@synthesize clearTagsItem = _clearTagsItem;

const int kSectionFriends = 1;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // inits
    self.friends = [NSMutableArray array];
    
    // Tagged Users can be provided by the caller.
    if (!self.taggedUsers) {
        self.taggedUsers = [NSMutableArray array];
    }

    self.filteredFriends = [NSMutableArray array];
    self.searching = NO;
    
    self.view.backgroundColor = [UIColor bgColor];
    self.tableView.backgroundView = nil;
    [self updateSearchBarBackground];
    
    // Add done & cancel buttons
    UIBarButtonItem *doneItem = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"red-button.png"] target:self action:@selector(doneButtonClicked:) title:@"Done"];
    [self.navigationItem setRightBarButtonItem:doneItem];
    
    self.cancelItem = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"black-button.png"] target:self action:@selector(cancelButtonClicked:) title:@"Cancel"];
    self.clearTagsItem = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"black-button.png"] target:self action:@selector(clearTagsButtonClicked:) title:@"Clear"];
    
    [self refreshLeftBarButtonItem];
    self.friends = [TYFriendCache sharedInstance].cachedFriends;
    
    // Incase the cache is still empty for some reason, add self as observer and trigger a refresh
    if (!self.friends || [self.friends count] == 0) {
        [self registerForNotifications];
        [[TYFriendCache sharedInstance] forceRefresh];
        [TYIndeterminateProgressBar showInView:self.view backgroundColor:[UIColor dullWhite] indicatorColor:[UIColor dullRed] borderColor:[UIColor darkGrayColor]];
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Search Bar

-(void) updateSearchBarBackground {
    [[[self.searchBar subviews] objectAtIndex:0] setAlpha:0.0];
    self.searchBar.tintColor = [UIColor bgColor];
    [self.searchBar setClipsToBounds:YES];
}

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
    return self.searching ? [self.filteredFriends count] : [self.friends count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kReuseId = @"tagged_users_cell";
    TYTagUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TYTagUserCell" owner:self options:nil];
		for (id object in nib) {
			if([object isKindOfClass:[TYTagUserCell class]])
				cell = (TYTagUserCell *) object;
		}
    }
    
    TYUser *user = nil;
    if (!self.searching) {
        user = [self.friends objectAtIndex:indexPath.row];
    }
    else {
        user = [self.filteredFriends objectAtIndex:indexPath.row];
    }
    
    [cell.fullName setText:[user fullName]];
    [cell.checkMark setHidden:![self userBelongsToTaggedUsers:user]];
    [cell.profilePicture setImageWithURL:[NSURL URLWithString:user.profilePictureUrl]];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(!self.searching) {
        TYUser *user = [self.friends objectAtIndex:indexPath.row];
        if ([self userBelongsToTaggedUsers:user]) {
            [self.taggedUsers removeObject:user];
        }
        else {
            [self.taggedUsers addObject:user];
        }
    }
    else {
        TYUser *user = [self.filteredFriends objectAtIndex:indexPath.row];
        if ([self userBelongsToTaggedUsers:user]) {
            [self.taggedUsers removeObject:user];
        }
        else {
            [self.taggedUsers addObject:user];
        }
    }
    
    [self refreshLeftBarButtonItem];
    [self.tableView reloadData];
}

#pragma mark - Event Handlers

-(void) doneButtonClicked:(id) sender {
    [self.delegate taggedUsers:self.taggedUsers];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) cancelButtonClicked:(id) sender {
    [self.delegate tagUsersCancelled];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) clearTagsButtonClicked:(id) sender {
    self.taggedUsers = [NSMutableArray array];
    [self.tableView reloadData];
    [self refreshLeftBarButtonItem];
}

-(void) refreshLeftBarButtonItem {
    if (self.taggedUsers && self.taggedUsers.count != 0) {
        [self.navigationItem setLeftBarButtonItem:self.clearTagsItem];
    }
    else {
        [self.navigationItem setLeftBarButtonItem:self.cancelItem];
    }
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

-(BOOL) userBelongsToTaggedUsers:(TYUser *) user {
    for(TYUser *taggedUser in self.taggedUsers) {
        if([user.userId isEqualToString:taggedUser.userId]) {
            return YES;
        }
    }
    return NO;
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendCacheRefreshed:) name:kFriendCacheUpdateComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendCacheRefreshErrored:) name:kFriendCacheUpdateComplete object:nil];
}

-(void) unregisterFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
