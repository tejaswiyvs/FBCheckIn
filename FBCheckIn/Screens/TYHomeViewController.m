//
//  TYFriendsViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYHomeViewController.h"
#import "TYPlacePicker.h"
#import "TYCheckInCache.h"
#import "TYCheckInCell.h"
#import "TYAppDelegate.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "TYCheckIn.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/CALayer.h>
#import "TYFBManager.h"
#import "TYCheckInDetailViewController.h"
#import "TYAppDelegate.h"
#import "SCNavigationBar.h"

@interface TYHomeViewController ()
-(void) checkInButtonClicked:(id) sender;
-(void) subscribeToNotifications;
-(void) unsubscribeFromNotifications;
-(void) registerObserver;
-(void) unregisterObserver;
-(void) didReceiveNotification:(NSNotification *) notification;
@end

@implementation TYHomeViewController

@synthesize tableView = _tableView;
@synthesize facebook = _facebook;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;

-(id) initWithTabBar {
    self = [super initWithNibName:@"TYHomeViewController" bundle:nil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"friends.png"];
        self.tabBarItem.title = @"Friends";
        self.title = @"Check-ins";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Subscribe to cache refresh notifications.
    [self subscribeToNotifications];
    
    // Register as an observer for the checkInArray of the checkIn cache. Lets us refresh the tableView.
    [self registerObserver];

    // Setup UITableView
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 10.0)]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];

    // Setup other UI
    UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check-in" style:UIBarButtonItemStylePlain target:self action:@selector(checkInButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:checkInButton];
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        NSLog(@"Height of the header view = %f", self.tableView.bounds.size.height);
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self unsubscribeFromNotifications];
    [self unregisterObserver];
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView

-(void) checkInButtonClicked:(id) sender {
    TYPlacePicker *checkInScreen = [[TYPlacePicker alloc] initWithNibName:@"TYCheckInViewController" bundle:nil];
    UINavigationController *navigationController = [SCNavigationBar customizedNavigationController];
    navigationController.viewControllers = [NSArray arrayWithObject:checkInScreen];
    [self presentModalViewController:navigationController animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TYCheckInCache *cache = [TYCheckInCache sharedInstance];
    return [cache.checkIns count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 125.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = @"TYCheckInCell";
    TYCheckInCache *cache = [TYCheckInCache sharedInstance];
    TYCheckInCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TYCheckInCell" owner:self options:nil];
		for (id object in nib) {
			if([object isKindOfClass:[TYCheckInCell class]])
				cell = (TYCheckInCell *) object;
		}
    }
    TYCheckIn *checkIn = [cache.checkIns objectAtIndex:indexPath.row];
    cell.name.text = checkIn.user.shortName;
    cell.checkInLocation.text = checkIn.page.pageName;
    
    // Some werid cases where locations are not returned without address.
    if (checkIn.page.state && checkIn.page.city) {
        cell.address.text = [checkIn.page shortAddress];
    }
    else {
        cell.address.text = @"";
    }
    
    [cell setTime:checkIn.checkInDate];

    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSLog(@"image url = %@", checkIn.user.profilePictureUrl);
    [cell.picture setImageWithURL:[NSURL URLWithString:checkIn.user.profilePictureUrl] placeholderImage:[UIImage imageNamed:@"user_placeholder.png"]];
    [cell.picture.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [cell.picture.layer setBorderWidth:3.0f];
    [cell.picture.layer setCornerRadius:3.0f];
    [cell.picture.layer setMasksToBounds:YES];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYCheckInCache *cache = [TYCheckInCache sharedInstance];
    TYCheckIn *checkIn = [cache.checkIns objectAtIndex:indexPath.row];
    TYCheckInDetailViewController *checkInDetail = [[TYCheckInDetailViewController alloc] initWithNibName:@"TYCheckInDetailViewController" bundle:nil];
    checkInDetail.checkIn = checkIn;
    [self.navigationController pushViewController:checkInDetail animated:YES];
}

- (void) forceRefreshCache {
	TYCheckInCache *cache = [TYCheckInCache sharedInstance];
    [cache forceRefresh];
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
	[self forceRefreshCache];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}


#pragma mark - Observer

-(void) registerObserver {
    TYCheckInCache *cache = [TYCheckInCache sharedInstance];
    [cache addObserver:self forKeyPath:@"checkIns" options:0 context:NULL];
}

-(void) unregisterObserver {
    TYCheckInCache *cache = [TYCheckInCache sharedInstance];
    [cache removeObserver:self forKeyPath:@"checkIns"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.tableView reloadData];
}

#pragma mark - Helpers

-(void) didReceiveNotification:(NSNotification *) notification {
    NSLog(@"Notification received: %@", [notification name]);
    if ([notification.name isEqualToString:kFBManagerLoginNotification]) {
        TYCheckInCache *cache = [TYCheckInCache sharedInstance];
        [cache forceRefresh];
    }
    else if([notification.name isEqualToString:kFBManagerLogOutNotification]) {
    
    }
    else if([notification.name isEqualToString:kNotificationCacheRefreshStart]) {
        self.reloading = YES;
        [SVProgressHUD show];
    }
    else if([notification.name isEqualToString:kNotificationCacheRefreshEnd]) {
        self.reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [SVProgressHUD dismiss];
    }
}

-(void) subscribeToNotifications {
    NSLog(@"Notification constants = %@-%@-%@-%@", kFBManagerLoginNotification, kFBManagerLogOutNotification, kNotificationCacheRefreshStart, kNotificationCacheRefreshEnd);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kFBManagerLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kFBManagerLogOutNotification object:nil];
    // Listen to notification if check-in cache starts / ends up dating itself and display an unintrusive "working" animation.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kNotificationCacheRefreshStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kNotificationCacheRefreshEnd object:nil];
}

-(void) unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFBManagerLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFBManagerLogOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCacheRefreshEnd object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCacheRefreshStart object:nil];
}

@end
