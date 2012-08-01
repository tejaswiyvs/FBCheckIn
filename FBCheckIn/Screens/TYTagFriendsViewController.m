//
//  TYTagFriendsViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYTagFriendsViewController.h"
#import "TYFBManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "TYUser.h"
#import "TYTagUserCell.h"
#import "NSString+Common.h"

@interface TYTagFriendsViewController ()
-(void) getFacebookFriends;
-(BOOL) userBelongsToTaggedUsers:(TYUser *) user;
@end

@implementation TYTagFriendsViewController

@synthesize friends = _friends;
@synthesize filteredFriends = _filteredFriends;
@synthesize loadFriendsRequest = _loadFriendsRequest;
@synthesize taggedUsers = _taggedUsers;
@synthesize tableView = _tableView;
@synthesize searching = _searching;
@synthesize searchBar = _searchBar;

const int kSectionTaggedUsers = 0;
const int kSectionFriends = 1;
const int kNumberOfSections = 2;

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
    self.taggedUsers = [NSMutableArray array];
    self.filteredFriends = [NSMutableArray array];
    self.searching = NO;
    
    // Download friends. Possibly cache them and download them later.
    [self getFacebookFriends];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.loadFriendsRequest setDelegate:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Facebook

-(void) getFacebookFriends {
    [SVProgressHUD showWithStatus:@"Loading ..."];
    TYFBManager *manager = [TYFBManager sharedInstance];
    Facebook *facebook = [manager facebook];
    NSString *fql = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=me())";
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    fql, @"query",
                                    nil];
    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    [SVProgressHUD showWithStatus:@"Failed."];
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    [SVProgressHUD dismiss];
    for (NSDictionary *userDict in ((NSArray *) result)) {
        TYUser *user = [[TYUser alloc] init];
        user.userId = [userDict objectForKey:@"id"];
        user.fullName = [userDict objectForKey:@"name"];
        [self.friends addObject:user];
    }
    [self.tableView reloadData];
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kSectionTaggedUsers) {
        return @"Tagged Users";
    }
    else if(section == kSectionFriends) {
        return @"Friends";
    }
    return @"";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSectionTaggedUsers) {
        return [self.taggedUsers count];
    }
    else if(section == kSectionFriends && self.searching) {
        return [self.filteredFriends count];
    }
    else if(section == kSectionFriends && !self.searching) {
        return [self.friends count];
    }
    return 0;
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
    if (indexPath.section == kSectionFriends) {
        user = [self.friends objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == kSectionTaggedUsers && !self.searching) {
        user = [self.taggedUsers objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == kSectionTaggedUsers && self.searching) {
        user = [self.filteredFriends objectAtIndex:indexPath.row];
    }
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePictureUrl] 
                   placeholderImage:nil];
    [cell.fullName setText:[user fullName]];
    [cell.checkMark setHidden:![self userBelongsToTaggedUsers:user]];
    [cell.profilePicture setImageWithURL:[NSURL URLWithString:user.profilePictureUrl]];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kSectionTaggedUsers) {
        TYUser *taggedUser = [self.taggedUsers objectAtIndex:indexPath.row];
        [self.taggedUsers removeObject:taggedUser];
    }
    else if(indexPath.section == kSectionFriends && !self.searching) {
        TYUser *user = [self.friends objectAtIndex:indexPath.row];
        if ([self userBelongsToTaggedUsers:user]) {
            [self.taggedUsers removeObject:user];
        }
        else {
            [self.taggedUsers addObject:user];
        }
    }
    else if(indexPath.section == kSectionFriends && self.searching) {
        TYUser *user = [self.filteredFriends objectAtIndex:indexPath.row];
        if ([self userBelongsToTaggedUsers:user]) {
            [self.taggedUsers removeObject:user];
        }
        else {
            [self.taggedUsers addObject:user];
        }
    }
    [tableView reloadData];
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

@end
