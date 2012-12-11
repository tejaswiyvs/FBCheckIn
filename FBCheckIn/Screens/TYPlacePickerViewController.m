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
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    [self loadNearbyPages];
    [self updateSearchBarBackground];
}

- (void)viewDidUnload
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
    return [self.allItems count];
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
    TYPage *page = [self.allItems objectAtIndex:indexPath.row];
    [cell.pageName setText:page.pageName];
    [cell.pageAddress setText:[page shortAddress]];
    [cell.pageImage setImageWithURL:[NSURL URLWithString:page.pagePictureUrl]];
    [cell setPageDistanceWithCoorindate1:page.location andCoordinate2:self.locationManager.location.coordinate];
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
    [SVProgressHUD showWithStatus:@"Loading nearby locations..."];
    [self updateLocation];
}

-(void)fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    self.allItems = [results objectForKey:@"data"];
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
}

-(void)fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err {
    [SVProgressHUD showErrorWithStatus:@"We couldn't access your facebook account. This might be temporary, please try again later."];
    // TODO: Add a #if DEBUG condition.
    NSLog(@"%@", err);
}

#pragma mark - UISearchBar

-(void) updateSearchBarBackground {
    [[[self.searchBar subviews] objectAtIndex:0] setAlpha:0.0];
    self.searchBar.tintColor = [UIColor colorWithHexString:@"BFB8B0"];
    [self.searchBar setClipsToBounds:YES];
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
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.locationManager = nil;
    self.reloading = NO;
    [SVProgressHUD showErrorWithStatus:@"Couldn't find your current location. Please try again when you have sufficient signal strength."];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.location = newLocation;
    self.facade = [[TYFBFacade alloc] init];
    self.facade.delegate = self;
    [self.facade placesNearLocation:self.locationManager.location.coordinate];
    [self.locationManager stopUpdatingLocation];
}

@end
