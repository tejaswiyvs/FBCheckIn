//
//  TYFriendsViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYHomeViewController.h"
#import "TYPlacePickerViewController.h"
#import "TYCheckInCache.h"
#import "TYAppDelegate.h"
#import "JSONKit.h"
#import "TYCheckIn.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/CALayer.h>
#import "TYFBManager.h"
#import "TYCheckInDetailViewController.h"
#import "TYAppDelegate.h"
#import "SCNavigationBar.h"
#import "TYIndeterminateProgressBar.h"
#import "NSString+Common.h"
#import "UIColor+HexString.h"
#import "NSDate+Helper.h"
#import "TYCurrentUser.h"
#import "TYUtils.h"

@interface TYHomeViewController ()
-(void) checkInButtonClicked:(id) sender;
-(void) subscribeToNotifications;
-(void) unsubscribeFromNotifications;
-(void) registerObserver;
-(void) unregisterObserver;
-(void) didReceiveNotification:(NSNotification *) notification;
-(float) heightForText:(NSString *) messageText;
-(CGFloat) heightForIndexPath:(NSIndexPath *) indexPath;
-(void) commentButtonClicked:(id) sender;
@end

@implementation TYHomeViewController

@synthesize tableView = _tableView;
@synthesize facebook = _facebook;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;
@synthesize cache = _cache;
@synthesize requests = _requests;

-(id) initWithTabBar {
    self = [super initWithNibName:@"TYHomeViewController" bundle:nil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"friends.png"];
        self.tabBarItem.title = @"Friends";
        self.title = @"Check-ins";
        self.cache = [TYCheckInCache sharedInstance];
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
    self.tableView.separatorColor = [UIColor grayColor];

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
    if (![self.cache checkIns] || [self.cache.checkIns count] == 0) {
        [self.cache forceRefresh];
    }
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

-(void) checkInButtonClicked:(id) sender {
    TYPlacePickerViewController *checkInScreen = [[TYPlacePickerViewController alloc] initWithNibName:@"TYPlacePicker" bundle:nil];
    UINavigationController *navigationController = [SCNavigationBar customizedNavigationController];
    navigationController.viewControllers = [NSArray arrayWithObject:checkInScreen];
    [self presentModalViewController:navigationController animated:YES];
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cache.checkIns count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return [self heightForIndexPath:indexPath];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kReuseId = @"check_in_cell";
    TYCheckIn *checkIn = [self.cache.checkIns objectAtIndex:indexPath.row];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseId];
    UITableViewCell *cell = nil;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseId];
    }
    
    float height = [self heightForIndexPath:indexPath];
    CGRect rect = CGRectMake(0.0f, 0.0f, 320.0f, height);
    [cell setFrame:rect];
    
    UIImageView *backgroundImgView = [[UIImageView alloc] initWithFrame:rect];
    [backgroundImgView setImage:[UIImage imageNamed:@"table-cell-bg.png"]];
    [cell addSubview:backgroundImgView];
    
    UIImageView *profilePictureImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 11.0f, 64.0f, 64.0f)];
    [profilePictureImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [profilePictureImgView.layer setBorderWidth:3.0f];
    [profilePictureImgView.layer setCornerRadius:3.0f];
    [profilePictureImgView.layer setMasksToBounds:YES];
    [profilePictureImgView setImageWithURL:[NSURL URLWithString:checkIn.user.profilePictureUrl] placeholderImage:[UIImage imageNamed:@"user_placeholder.png"]];
    [cell addSubview:profilePictureImgView];
    
    UILabel *fullNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(84.0f, 11.0f, 208.0f, 21.0f)];
    [fullNameLbl setText:[checkIn.user shortName]];
    [fullNameLbl setTextColor:[UIColor headerTextColor]];
    [fullNameLbl setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [fullNameLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:fullNameLbl];
    
    UILabel *atLabel = [[UILabel alloc] initWithFrame:CGRectMake(84.0f, 32.0f, 19.0f, 21.0f)];
    [atLabel setText:@"@"];
    [atLabel setTextColor:[UIColor subtitleTextColor]];
    [atLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [atLabel setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:atLabel];
    
    UILabel *locationLbl = [[UILabel alloc] initWithFrame:CGRectMake(104.0f, 32.0f, 188.0f, 21.0f)];
    [locationLbl setText:checkIn.page.pageName];
    [locationLbl setTextColor:[UIColor subtitleTextColor]];
    [locationLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:locationLbl];
    
    UILabel *timestampLbl = [[UILabel alloc] initWithFrame:CGRectMake(84.0f, 54.0f, 208.0f, 21.0f)];
    [timestampLbl setText:[NSDate stringForDisplayFromDate:checkIn.checkInDate prefixed:YES]];
    [timestampLbl setTextColor:[UIColor subtitleTextColor]];
    [timestampLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:timestampLbl];
    
    UIImageView *separatorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 82.0f, 320.0f, 4.0f)];
    [separatorImgView setImage:[UIImage imageNamed:@"separator.png"]];
    [cell addSubview:separatorImgView];

    float y = 94.0f;

    if ([checkIn hasMessage]) {
        int checkInMessageHeight = [self heightForText:checkIn.message];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, 300.0f, checkInMessageHeight)];
        [messageLabel setTextColor:[UIColor headerTextColor]];
        [messageLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [messageLabel setText:checkIn.message];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:messageLabel];
        y = y + checkInMessageHeight + 5.0f; // 5 px padding
    }
    
    if ([checkIn hasPhoto]) {
        UIImageView *checkInPictureImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, y, 300.0f, 200.0f)];
        [checkInPictureImgView setImageWithURL:[NSURL URLWithString:checkIn.photo.src]];
        [checkInPictureImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
        [checkInPictureImgView.layer setBorderWidth:3.0f];
        [checkInPictureImgView.layer setCornerRadius:3.0f];
        [checkInPictureImgView.layer setMasksToBounds:YES];
        checkInPictureImgView.contentMode = UIViewContentModeScaleAspectFit;
        [checkInPictureImgView setBackgroundColor:[UIColor darkGrayColor]];
        [cell addSubview:checkInPictureImgView];
    }
    
    UILabel *commentCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(204.0f, height - 31.0f, 20.0f, 20.0f)];
    [commentCountLbl setText:[NSString stringWithFormat:@"%d", [checkIn.comments count]]];
    [commentCountLbl setTextAlignment:UITextAlignmentCenter];
    [commentCountLbl setTextColor:[UIColor subtitleTextColor]];
//    [commentCountLbl setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [commentCountLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:commentCountLbl];
    
    UILabel *likeCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(256.0f, height - 31.0f, 20.0f, 20.0f)];
    [likeCountLbl setText:[NSString stringWithFormat:@"%d", [checkIn.likes count]]];
    [likeCountLbl setTextAlignment:UITextAlignmentCenter];
    [likeCountLbl setTextColor:[UIColor subtitleTextColor]];
    //    [likeCountLbl setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [likeCountLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:likeCountLbl];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setFrame:CGRectMake(228.0f, height - 31.0f, 20.0f, 20.0f)];
    commentButton.tag = indexPath.row;
    [commentButton addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:commentButton];
    
    // Set check in count.
    if ([checkIn.comments count] > 0) {
        [commentCountLbl setText:[NSString stringWithFormat:@"%d", checkIn.comments.count]];
        [commentButton setImage:[UIImage imageNamed:@"comment-bubble-blue.png"] forState:UIControlStateNormal];
    }
    else {
        [commentCountLbl setText:@"0"];
        [commentButton setImage:[UIImage imageNamed:@"comment-bubble.png"] forState:UIControlStateNormal];
    }

    UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeButton setFrame:CGRectMake(280.0f, height - 33.0f, 20.0f, 20.0f)];
    likeButton.tag = indexPath.row;
    [likeButton addTarget:self action:@selector(likeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:likeButton];
    [likeCountLbl setText:[NSString stringWithFormat:@"%d", checkIn.likes.count]];
    
    // Set like count.
    if ([checkIn isLikedByUser:[TYCurrentUser sharedInstance].user]) {
        [likeButton setImage:[UIImage imageNamed:@"facebook_like_green.png"] forState:UIControlStateNormal];
    }
    else if([[checkIn likes] count] > 0) {
        [likeButton setImage:[UIImage imageNamed:@"facebook_like_blue.png"] forState:UIControlStateNormal];
    }
    else {
        [likeButton setImage:[UIImage imageNamed:@"facebook_like.png"] forState:UIControlStateNormal];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark - FBFacadeDelegate

-(void) fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    [self.requests removeObject:helper];
    return;
}

-(void) fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err {
    [self.requests removeObject:helper];
    if (helper.tag >= 0) {
        NSMutableArray *checkIns = self.cache.checkIns;
        TYCheckIn *selectedCheckIn = [checkIns objectAtIndex:helper.tag];
        TYUser *currentUser = [TYCurrentUser sharedInstance].user;
        [selectedCheckIn unlikeCheckIn:currentUser];
    }
    [TYUtils displayAlertWithTitle:@"Error" message:@"Could not contact Facebook servers. Please try again later."];
}

#pragma mark - Helpers

-(void) likeButtonClicked:(id) sender {
    UIButton *button = (UIButton *) sender;
    NSMutableArray *checkIns = self.cache.checkIns;
    TYCheckIn *selectedCheckIn = [checkIns objectAtIndex:button.tag];
    TYUser *currentUser = [TYCurrentUser sharedInstance].user;
    TYFBFacade *facade = [[TYFBFacade alloc] init];
    facade.tag = button.tag;
    facade.delegate = self;
    if ([selectedCheckIn isLikedByUser:currentUser]) {
        [selectedCheckIn unlikeCheckIn:currentUser];
        [facade unlikeCheckIn:selectedCheckIn];
    }
    else {
        [selectedCheckIn likeCheckIn:currentUser];
        [facade likeCheckIn:selectedCheckIn];
    }
    if (!self.requests) {
        self.requests = [NSMutableArray array];
    }
    [self.requests addObject:facade];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:button.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) commentButtonClicked:(id) sender {
    UIButton *button = (UIButton *) sender;
    NSMutableArray *checkIns = self.cache.checkIns;
    TYCheckIn *selectedCheckIn = [checkIns objectAtIndex:button.tag];
    TYUser *currentUser = [TYCurrentUser sharedInstance].user;
}

-(void) forceRefreshCache {
    [self.cache forceRefresh];
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
    [self.cache addObserver:self forKeyPath:@"checkIns" options:0 context:NULL];
}

-(void) unregisterObserver {
    [self.cache removeObserver:self forKeyPath:@"checkIns"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.tableView reloadData];
}

#pragma mark - Helpers

-(void) didReceiveNotification:(NSNotification *) notification {
    NSLog(@"Notification received: %@", [notification name]);
    if ([notification.name isEqualToString:kFBManagerLoginNotification]) {
        [self.cache forceRefresh];
    }
    else if([notification.name isEqualToString:kFBManagerLogOutNotification]) {
    
    }
    else if([notification.name isEqualToString:kNotificationCacheRefreshStart]) {
        self.reloading = YES;
        [TYIndeterminateProgressBar showInView:self.view];
    }
    else if([notification.name isEqualToString:kNotificationCacheRefreshEnd]) {
        self.reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [TYIndeterminateProgressBar hideFromView:self.view];
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

// Refactor?
-(float) heightForText:(NSString *) messageText {
    if (!messageText || [messageText isBlank]) {
        return 0.0f;
    }
    CGSize size = [messageText sizeWithFont:[UIFont systemFontOfSize:12.0f] forWidth:272.0f lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
}

-(CGFloat) heightForIndexPath:(NSIndexPath *) indexPath {
    TYCheckIn *checkIn = [self.cache.checkIns objectAtIndex:indexPath.row];
    float height = 125.0f;
    if ([checkIn hasPhoto]) {
        height = height + 200.0f + 5.0f;
    }
    if ([checkIn hasMessage]) {
        height = height + [self heightForText:checkIn.message] + 5.0f;
    }
    return height;
}

-(UILabel *) makeLabelWithFrame:(CGRect) frame color:(UIColor *) color text:(NSString *) text {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:color];
    [label setText:text];
    [label setTextAlignment:UITextAlignmentCenter];
    return label;
}

@end
