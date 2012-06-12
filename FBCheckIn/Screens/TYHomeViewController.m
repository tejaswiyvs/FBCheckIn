//
//  TYFriendsViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYHomeViewController.h"
#import "TYCheckInViewController.h"
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
-(void) loadCheckIns;
-(void) subscribeToNotifications;
-(void) unsubscribeFromNotifications;
@end

@implementation TYHomeViewController

@synthesize tableView = _tableView;
@synthesize checkIns = _checkIns;
@synthesize facebook = _facebook;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;

-(id) initWithTabBar {
    self = [super initWithNibName:@"TYHomeViewController" bundle:nil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"friends.png"];
        self.tabBarItem.title = @"Friends";
        self.title = @"Check-ins";
        TYAppDelegate *appDelegate = (TYAppDelegate *) [UIApplication sharedApplication].delegate;
        self.checkIns = [NSMutableArray array];
        appDelegate.checkIns = self.checkIns;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 10.0)]];
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check-in" style:UIBarButtonItemStylePlain target:self action:@selector(checkInButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:checkInButton];
    TYFBManager *manager = [TYFBManager sharedInstance];
    self.facebook = manager.facebook;
    if ([self.facebook isSessionValid]) {
        [self loadCheckIns];
    }
    
    // Pull to refresh
    if (_refreshHeaderView == nil) {
		
//		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - 100.0f, self.view.frame.size.width, 100.0f)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self unsubscribeFromNotifications];
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView

-(void) checkInButtonClicked:(id) sender {
    TYCheckInViewController *checkInScreen = [[TYCheckInViewController alloc] initWithNibName:@"TYCheckInViewController" bundle:nil];
    UINavigationController *navigationController = [SCNavigationBar customizedNavigationController];
    navigationController.viewControllers = [NSArray arrayWithObject:checkInScreen];
    [self presentModalViewController:navigationController animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.checkIns count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 125.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = @"TYCheckInCell";
    TYCheckInCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TYCheckInCell" owner:self options:nil];
		for (id object in nib) {
			if([object isKindOfClass:[TYCheckInCell class]])
				cell = (TYCheckInCell *) object;
		}
    }
    TYCheckIn *checkIn = [self.checkIns objectAtIndex:indexPath.row];
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
    TYCheckIn *checkIn = [self.checkIns objectAtIndex:indexPath.row];
    TYCheckInDetailViewController *checkInDetail = [[TYCheckInDetailViewController alloc] initWithNibName:@"TYCheckInDetailViewController" bundle:nil];
    checkInDetail.checkIn = checkIn;
    [self.navigationController pushViewController:checkInDetail animated:YES];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	self.reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	self.reloading = NO;
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
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
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


#pragma mark - Facebook
-(void) loadCheckIns {
    [SVProgressHUD showWithStatus:@"Loading Check-ins..."];
    NSString *fql1 = @"SELECT checkin_id, author_uid, page_id, coords, timestamp FROM checkin WHERE (author_uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) OR author_uid=me()) ORDER BY timestamp DESC LIMIT 50";
    NSString *fql2 = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me FROM user WHERE uid in (SELECT author_uid FROM #query1)";
    NSString *fql3 = @"SELECT page_id, name, description, categories, pic, fan_count, website, checkins, location FROM page WHERE page_id IN (SELECT page_id FROM #query1)";
    
    NSString* fql = [NSString stringWithFormat:
                     @"{\"query1\":\"%@\",\"query2\":\"%@\",\"query3\":\"%@\"}",fql1,fql2,fql3];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"queries"];   

    [self.facebook requestWithMethodName:@"fql.multiquery" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [SVProgressHUD dismissWithError:@"Could not load check-ins" afterDelay:2.5];
    // TODO: Add a #if DEBUG condition.
    NSLog(@"%@", error);
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    NSDictionary *checkinFqlDict = [(NSArray *) result objectAtIndex:0];
    NSDictionary *userFqlDict = [(NSArray *) result objectAtIndex:1];
    NSDictionary *pagesFqlDict = [(NSArray *) result objectAtIndex:2];
    
    NSArray *checkIns = [checkinFqlDict objectForKey:@"fql_result_set"];
    NSArray *users = [userFqlDict objectForKey:@"fql_result_set"];
    NSArray *pages = [pagesFqlDict objectForKey:@"fql_result_set"];
    
    NSMutableDictionary *userObjects = [NSMutableDictionary dictionary];
    NSMutableDictionary *pageObjects = [NSMutableDictionary dictionary];
    
    for (NSDictionary *userDictionary in users) {
        TYUser *user = [[TYUser alloc] initWithDictionary:userDictionary];
        [userObjects setObject:user forKey:[NSString stringWithFormat:@"user_%@", user.userId]];
    }
    
    for (NSDictionary *pageDictionary in pages) {
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDictionary];
        [pageObjects setObject:page forKey:[NSString stringWithFormat:@"page_%@", page.pageId]];
    }
    
    for (NSDictionary *checkInDictionary in checkIns) {
        TYCheckIn *checkIn = [[TYCheckIn alloc] initWithDictionary:checkInDictionary];
        TYUser *user = [userObjects objectForKey:[NSString stringWithFormat:@"user_%@", checkIn.user.userId]];
        TYPage *page = [pageObjects objectForKey:[NSString stringWithFormat:@"page_%@", checkIn.page.pageId]];
        if (user && page) {
            checkIn.user = user;
            checkIn.page = page;
            [self.checkIns addObject:checkIn];
        }
    }
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
}

#pragma mark - EGOPullToRefreshDelegate


#pragma mark - Helpers

-(void) receivedLoginNotification:(NSNotification *) notification {
    [self loadCheckIns];
}

-(void) receivedLogoutNotification:(NSNotification *) notification {
    // Don't have to do much here.
}

-(void) subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLoginNotification:) name:kFBManagerLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLogoutNotification:) name:kFBManagerLogOutNotification object:nil];
}

-(void) unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFBManagerLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFBManagerLogOutNotification object:nil];
}

@end
