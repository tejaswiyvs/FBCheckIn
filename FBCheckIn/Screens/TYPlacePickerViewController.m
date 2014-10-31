//
//  PPCheckInViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYPlacePickerViewController.h"
#import "Facebook.h"
#import "SVProgressHUD.h"
#import "TYFBManager.h"
#import "TYPageCell.h"
#import "TYPage.h"
#import "UIImageView+AFNetworking.h"
#import "TYCheckInViewController.h"
#import "UIColor+HexString.h"
#import "UIBarButtonItem+Convinience.h"
#import "NSString+Common.h"

@interface TYPlacePickerViewController ()
-(void) cancelButtonClicked:(id) sender;
-(void) loadNearbyPages;
-(void) updateSearchBarBackground;
@end

@implementation TYPlacePickerViewController

@synthesize searchDisplayController;
@synthesize searchBar = _searchBar;
@synthesize allItems = _allItems;
@synthesize searchResults = _searchResults;
@synthesize tableView = _tableView;
@synthesize location = _location;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;
@synthesize request = _request;
@synthesize pageDataRequest = _pageDataRequest;
@synthesize searching = _searching;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.reloading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *cancelButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"red-button.png"] target:self action:@selector(cancelButtonClicked:) title:@"Cancel"];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"E9E4E1"]];
    [self loadNearbyPages];
    [self updateSearchBarBackground];
    self.searchResults = [NSMutableArray array];
    [(SCNavigationBar *) self.navigationController.navigationBar hideCheckInButton];
    self.view.backgroundColor = [UIColor bgColor];
    self.tableView.backgroundView = nil;
}

- (void) dealloc
{
    [super viewDidUnload];
    self.searchBar = nil;
    self.searchDisplayController = nil;
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) cancelButtonClicked:(id) sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searching ? [self.searchResults count] : [self.allItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kReuseId = @"search_checkin_cell";
    TYPageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kReuseId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TYPageCell" owner:self options:nil];
		for (id object in nib) {
			if([object isKindOfClass:[TYPageCell class]])
				cell = (TYPageCell *) object;
		}
    }
    TYPage *page;
    if (self.searching) {
        page = [self.searchResults objectAtIndex:indexPath.row];
    }
    else {
        page = [self.allItems objectAtIndex:indexPath.row];
    }
    [cell.pageName setText:page.pageName];
    [cell.pageAddress setText:[page shortAddress]];
    [cell.pageImage setImageWithURL:[NSURL URLWithString:page.pagePictureUrl]];
    [cell setPageDistanceWithCoorindate1:page.location andCoordinate2:self.location.coordinate];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYPage *selectedPage = [self.allItems objectAtIndex:indexPath.row];
    TYCheckInViewController *confirmationScreen = [[TYCheckInViewController alloc] initWithNibName:@"TYCheckInConfirmation" bundle:nil];
    confirmationScreen.currentPage = selectedPage;
    [self.navigationController pushViewController:confirmationScreen animated:YES];
}

#pragma mark - Facebook

-(void) loadNearbyPages {
    // Load location first 
    [SVProgressHUD showWithStatus:@"Loading nearby locations..." maskType:SVProgressHUDMaskTypeClear];
    [self updateLocation];
}

-(void) loadPagesWithQuery:(NSString *) query {
    // Cancel any request that are open currently
    [self cancelPendingRequests];
    
    // Start new request for search query. If blank, we load all. If not we load only search results.
    self.request = [[TYFBRequest alloc] init];
    self.request.delegate = self;
    [self.request placesNearLocation:self.location.coordinate withQuery:query limit:20];
}

-(void) loadPageData {
    self.pageDataRequest = [[TYFBRequest alloc] init];
    self.pageDataRequest.delegate = self;
    [self.pageDataRequest loadPageData:self.allItems];
}

-(void)fbHelper:(TYFBRequest *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    if (helper == self.request) {
        self.allItems = [results objectForKey:@"data"];
        [self loadPageData];
    }
    else {
        self.allItems = [results objectForKey:@"data"];
        [self sortItems];
        if (self.searching) {
            [self updateSearchResultsWithText:self.searchBar.text];
        }
        else {
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        }
    }
}

-(void)fbHelper:(TYFBRequest *)helper didFailWithError:(NSError *)err {
    [SVProgressHUD showErrorWithStatus:@"We couldn't access your facebook account. This might be temporary, please try again later."];
    DDLogInfo(@"%@", err);
}

#pragma mark - UISearchBar

-(void) updateSearchBarBackground {
    [[[self.searchBar subviews] objectAtIndex:0] setAlpha:0.0];
    self.searchBar.tintColor = [UIColor colorWithHexString:@"BFB8B0"];
    [self.searchBar setClipsToBounds:YES];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searching = YES;
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocapitalizationTypeNone;
    [self.searchResults removeAllObjects];
    
    // Loop through, and copy allItems -> searchResults
    for(TYPage *page in self.allItems)
    {
        [self.searchResults addObject:page];
    }
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self loadPagesWithQuery:searchText];
    [self updateSearchResultsWithText:searchText];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searching = NO;
    [searchBar endEditing:YES];
}

-(void) searchBarSearchButtonClicked:(UISearchBar*) searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self loadNearbyPages];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

#pragma mark - Location Manager

-(void) updateLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    self.locationManager = nil;
    self.reloading = NO;
    [SVProgressHUD showErrorWithStatus:@"Couldn't find your current location. Please try again when you have sufficient signal strength."];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.location = newLocation;
    [manager stopUpdatingLocation];
    self.locationManager = nil;
    [self loadPagesWithQuery:@""];
}

#pragma mark - Helpers

-(void) cancelPendingRequests {
    [self.request cancel];
    [self.pageDataRequest cancel];
}

-(void) updateSearchResultsWithText:(NSString *) searchText {
    // Clear search results
    [self.searchResults removeAllObjects];
    
    // If blank, show all.
    if (!searchText || [searchText isBlank]) {
        for (TYPage *page in self.allItems) {
            [self.searchResults addObject:page];
        }
        [self.tableView reloadData];
        return;
    }
    
    // Else, Loop through, find current matching places and populate search results.
    for(TYPage *page in self.allItems)
    {
        NSRange range = [page.pageName rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound)
        {
            [self.searchResults addObject:page];
        }
    }
    [self.tableView reloadData];
}

-(void) sortItems {
    [self.allItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TYPage *page1 = (TYPage *) obj1;
        TYPage *page2 = (TYPage *) obj2;
        CLLocationDistance distance1 = [self distanceBetweenCoordinate:page1.location andCoordinate:self.location.coordinate];
        CLLocationDistance distance2 = [self distanceBetweenCoordinate:page2.location andCoordinate:self.location.coordinate];
        if (distance1 < distance2) {
            return NSOrderedAscending;
        }
        else if(distance1 > distance2) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
}

-(CLLocationDistance) distanceBetweenCoordinate:(CLLocationCoordinate2D) location1 andCoordinate:(CLLocationCoordinate2D) location2 {
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:location1.latitude longitude:location1.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:location2.latitude longitude:location2.longitude];
    CLLocationDistance meters = [loc2 distanceFromLocation:loc1];
    return meters;
}

@end
