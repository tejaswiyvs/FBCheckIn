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
#import <QuartzCore/CALayer.h>
#import "TYFBManager.h"
#import "TYCheckInDetailViewController.h"
#import "TYAppDelegate.h"
#import "SCNavigationBar.h"
#import "NSString+Common.h"
#import "UIColor+HexString.h"
#import "NSDate+Helper.h"
#import "TYCurrentUser.h"
#import "TYUtils.h"
#import "TYUserProfileViewController.h"
#import "TYPlaceProfileViewController.h"
#import "TYIndeterminateProgressBar.h"
#import "TYPictureViewController.h"

@interface TYHomeViewController ()
-(void) subscribeToNotifications;
-(void) unsubscribeFromNotifications;
-(void) registerObserver;
-(void) unregisterObserver;
-(void) didReceiveNotification:(NSNotification *) notification;
-(float) heightForText:(NSString *) messageText withFont:(UIFont *) font;
-(CGFloat) heightForIndexPath:(NSIndexPath *) indexPath;
-(void) commentButtonClicked:(id) sender;
-(void) pageNameTapped:(UIGestureRecognizer *) sender;
-(void) profilePictureTapped:(UIGestureRecognizer *) sender;
@end

@implementation TYHomeViewController

@synthesize tableView = _tableView;
@synthesize facebook = _facebook;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;
@synthesize cache = _cache;
@synthesize requests = _requests;

-(id) init {
    self = [super initWithNibName:@"TYHomeViewController" bundle:nil];
    if (self) {
        self.title = @"Check-ins";
        self.cache = [TYCheckInCache sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    DebugLog(@"HomeView Did Load. Setting up UI.");
    [super viewDidLoad];
    // Subscribe to cache refresh notifications.
    [self subscribeToNotifications];
    
    // Register as an observer for the checkInArray of the checkIn cache. Lets us refresh the tableView.
    [self registerObserver];

    // Setup UITableView
    self.view.backgroundColor = [UIColor bgColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.separatorColor = [UIColor subtitleTextColor];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 10.0)]];

    // Setup other UI
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        DebugLog(@"Height of the header view = %f", self.tableView.bounds.size.height);
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}        
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DebugLog(@"HomeView viewDidAppear. Checking if cache is empty.")
    if (![self.cache checkIns] || [self.cache.checkIns count] == 0) {
        DebugLog(@"Cache is empty, so force refreshing");
        [self.cache forceRefresh];
        [TYIndeterminateProgressBar showInView:self.view backgroundColor:[UIColor dullWhite] indicatorColor:[UIColor dullRed] borderColor:[UIColor darkGrayColor]];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [TYIndeterminateProgressBar hideFromView:self.view];
}

-(void) dealloc {
    DebugLog(@"HomeView dealloc");
    [self unsubscribeFromNotifications];
    [self unregisterObserver];
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cache.checkIns count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return [self heightForIndexPath:indexPath] + 1.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *kReuseId = @"check_in_cell";
    TYCheckIn *checkIn = [self.cache.checkIns objectAtIndex:indexPath.row];
    
    // Need to figure out reUseIds with dynamic cell heights etc.
    float height = [self heightForIndexPath:indexPath];
    CGRect rect = CGRectMake(10.0f, 0.0f, 300.0f, height);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:rect];
    cell.clipsToBounds = YES;
    
    UITapGestureRecognizer *profilePictureTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePictureTapped:)];
    [profilePictureTapRecognizer setNumberOfTouchesRequired:1];
    [profilePictureTapRecognizer setNumberOfTapsRequired:1];
    profilePictureTapRecognizer.cancelsTouchesInView = YES;
    
    UITapGestureRecognizer *userNameTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePictureTapped:)];
    [userNameTapRecognizer setNumberOfTouchesRequired:1];
    [userNameTapRecognizer setNumberOfTapsRequired:1];
    userNameTapRecognizer.cancelsTouchesInView = YES;
    
    UITapGestureRecognizer *checkInPhotoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkInPhotoTapped:)];
    checkInPhotoTapRecognizer.numberOfTouchesRequired = 1;
    checkInPhotoTapRecognizer.numberOfTapsRequired = 1;
    checkInPhotoTapRecognizer.cancelsTouchesInView = YES;
    
    UITapGestureRecognizer *pageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pageNameTapped:)];
    pageTapRecognizer.numberOfTouchesRequired = 1;
    pageTapRecognizer.numberOfTapsRequired = 1;
    pageTapRecognizer.cancelsTouchesInView = YES;

    
    UIImageView *backgroundImgView = [[UIImageView alloc] initWithFrame:rect];
    [backgroundImgView setImage:[UIImage imageNamed:@"table-cell-bg.png"]];
    [cell addSubview:backgroundImgView];
    
    UIImageView *profilePictureImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 11.0f, 64.0f, 64.0f)];
    [profilePictureImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [profilePictureImgView.layer setBorderWidth:3.0f];
    [profilePictureImgView.layer setCornerRadius:3.0f];
    [profilePictureImgView.layer setMasksToBounds:YES];
    [profilePictureImgView setBackgroundColor:[UIColor blackColor]];
    [profilePictureImgView setUserInteractionEnabled:YES];
    [profilePictureImgView setContentMode:UIViewContentModeScaleAspectFill];
    [profilePictureImgView setImageWithURL:[NSURL URLWithString:checkIn.user.profilePictureUrl] placeholderImage:[UIImage imageNamed:@"user_placeholder.png"]];
    [cell addSubview:profilePictureImgView];
    [profilePictureImgView addGestureRecognizer:profilePictureTapRecognizer];
    
    UILabel *fullNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 11.0f, 208.0f, 21.0f)];
    [fullNameLbl setText:[checkIn.user shortName]];
    [fullNameLbl setTextColor:[UIColor headerTextColor]];
    [fullNameLbl setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [fullNameLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:fullNameLbl];
    [fullNameLbl setUserInteractionEnabled:YES];
    fullNameLbl.tag = indexPath.row;
    [fullNameLbl addGestureRecognizer:userNameTapRecognizer];
    
    UILabel *atLabel = [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 32.0f, 19.0f, 21.0f)];
    [atLabel setText:@"@"];
    [atLabel setTextColor:[UIColor subtitleTextColor]];
    [atLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [atLabel setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:atLabel];
    
    UILabel *locationLbl = [[UILabel alloc] initWithFrame:CGRectMake(114.0f, 32.0f, 188.0f, 21.0f)];
    [locationLbl setText:checkIn.page.pageName];
    [locationLbl setTextColor:[UIColor subtitleTextColor]];
    [locationLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:locationLbl];
    [locationLbl setUserInteractionEnabled:YES];
    locationLbl.tag = indexPath.row;
    [locationLbl addGestureRecognizer:pageTapRecognizer];
    
    UILabel *timestampLbl = [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 54.0f, 208.0f, 21.0f)];
    [timestampLbl setText:[NSDate stringForDisplayFromDate:checkIn.checkInDate prefixed:YES]];
    [timestampLbl setTextColor:[UIColor subtitleTextColor]];
    [timestampLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:timestampLbl];
    
    float y = 90.0f;

    if ([checkIn hasMessage]) {
        UIFont *messageFont = [UIFont systemFontOfSize:16.0f];
        float checkInMessageHeight = [self heightForText:checkIn.message withFont:messageFont];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, 280.0f, checkInMessageHeight)];
        [messageLabel setTextColor:[UIColor headerTextColor]];
        [messageLabel setFont:messageFont];
        [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [messageLabel setText:checkIn.message];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setNumberOfLines:0];
        [cell addSubview:messageLabel];
        y = y + checkInMessageHeight + 5.0f; // 5 px padding
    }
    
    if ([checkIn hasPhoto]) {
        UIImageView *checkInPictureImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, y, 280.0f, 200.0f)];
        [checkInPictureImgView setImageWithURL:[NSURL URLWithString:checkIn.photo.src]];
        [checkInPictureImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
        [checkInPictureImgView.layer setBorderWidth:3.0f];
        [checkInPictureImgView.layer setCornerRadius:3.0f];
        [checkInPictureImgView.layer setMasksToBounds:YES];
        checkInPictureImgView.contentMode = UIViewContentModeScaleAspectFill;
        [checkInPictureImgView setUserInteractionEnabled:YES];
        [checkInPictureImgView addGestureRecognizer:checkInPhotoTapRecognizer];
        [checkInPictureImgView setBackgroundColor:[UIColor darkGrayColor]];
        checkInPictureImgView.tag = indexPath.row;
        [cell addSubview:checkInPictureImgView];
        y = y + 200.0f + 5.0f;
    }
    
    UIImageView *separatorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, y, 300.0f, 3.0f)];
    [separatorImgView setImage:[UIImage imageNamed:@"separator.png"]];
    [cell addSubview:separatorImgView];
    
    y = y + 4.0f + 5.0f;
    
    UILabel *commentCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(204.0f, y, 20.0f, 20.0f)];
    [commentCountLbl setText:[NSString stringWithFormat:@"%d", [checkIn.comments count]]];
    [commentCountLbl setTextAlignment:UITextAlignmentCenter];
    [commentCountLbl setTextColor:[UIColor subtitleTextColor]];
//    [commentCountLbl setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [commentCountLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:commentCountLbl];
    
    UILabel *likeCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(256.0f, y, 20.0f, 20.0f)];
    [likeCountLbl setText:[NSString stringWithFormat:@"%d", [checkIn.likes count]]];
    [likeCountLbl setTextAlignment:UITextAlignmentCenter];
    [likeCountLbl setTextColor:[UIColor subtitleTextColor]];
    //    [likeCountLbl setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [likeCountLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:likeCountLbl];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setFrame:CGRectMake(228.0f, y, 20.0f, 20.0f)];
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
    [likeButton setFrame:CGRectMake(280.0f, y - 2, 20.0f, 20.0f)];
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - FBFacadeDelegate

-(void) fbHelper:(TYFBRequest *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    [self.requests removeObject:helper];
    return;
}

-(void) fbHelper:(TYFBRequest *)helper didFailWithError:(NSError *)err {
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

-(void) checkInPhotoTapped:(UIGestureRecognizer *) sender {
    UIView *view = sender.view;
    TYCheckIn *checkIn = [self.cache.checkIns objectAtIndex:view.tag];
    TYPictureViewController *pictureController = [[TYPictureViewController alloc] initWithImageUrl:checkIn.photo.src hiResUrl:nil];
    pictureController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:pictureController animated:YES];
}

-(void) pageNameTapped:(UIGestureRecognizer *) sender {
    UIView *view = sender.view;
    TYCheckIn *checkIn = [self.cache.checkIns objectAtIndex:view.tag];
    TYPlaceProfileViewController *userProfile = [[TYPlaceProfileViewController alloc] initWithPlace:checkIn.page];
    [self.navigationController pushViewController:userProfile animated:YES];
}

-(void) profilePictureTapped:(UIGestureRecognizer *) sender {
    UIView *view = sender.view;
    TYCheckIn *checkIn = [self.cache.checkIns objectAtIndex:view.tag];
    TYUserProfileViewController *userProfile = [[TYUserProfileViewController alloc] initWithUser:checkIn.user];
    [self.navigationController pushViewController:userProfile animated:YES];
}

-(void) likeButtonClicked:(id) sender {
    DebugLog(@"Like Check-in Button Clicked");
    UIButton *button = (UIButton *) sender;
    NSMutableArray *checkIns = self.cache.checkIns;
    TYCheckIn *selectedCheckIn = [checkIns objectAtIndex:button.tag];
    TYUser *currentUser = [TYCurrentUser sharedInstance].user;
    TYFBRequest *request = [[TYFBRequest alloc] init];
    request.tag = button.tag;
    request.delegate = self;
    if ([selectedCheckIn isLikedByUser:currentUser]) {
        [selectedCheckIn unlikeCheckIn:currentUser];
        [request unlikeCheckIn:selectedCheckIn];
    }
    else {
        [selectedCheckIn likeCheckIn:currentUser];
        [request likeCheckIn:selectedCheckIn];
    }
    if (!self.requests) {
        self.requests = [NSMutableArray array];
    }
    [self.requests addObject:request];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:button.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) commentButtonClicked:(id) sender {
    DebugLog(@"Comment Button Clicked. Launching CommentView");
    [self.mixPanel track:@"Comment Button Clicked"];
    UIButton *button = (UIButton *) sender;
    NSMutableArray *checkIns = self.cache.checkIns;
    TYCheckIn *selectedCheckIn = [checkIns objectAtIndex:button.tag];
    TYUser *currentUser = [TYCurrentUser sharedInstance].user;
    TYCommentViewController *commentScreen = [[TYCommentViewController alloc] initWithCheckIn:selectedCheckIn user:currentUser];
    UINavigationController *mapsNavController = [SCNavigationBar customizedNavigationController];
    [mapsNavController setViewControllers:[NSArray arrayWithObject:commentScreen]];
    [self presentModalViewController:mapsNavController animated:YES];
}

-(void) forceRefreshCache {
    [self.cache forceRefresh];
}

#pragma mark - TYCommentViewControllerDelegate

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
    DebugLog(@"Notification received: %@", [notification name]);
    if ([notification.name isEqualToString:kFBManagerLoginNotification]) {
        [self.cache forceRefresh];
    }
    else if([notification.name isEqualToString:kFBManagerLogOutNotification]) {
    
    }
    else if([notification.name isEqualToString:kNotificationCacheRefreshStart]) {
        self.reloading = YES;
        [TYIndeterminateProgressBar showInView:self.view backgroundColor:[UIColor dullWhite] indicatorColor:[UIColor dullRed] borderColor:[UIColor darkGrayColor]];
    }
    else if([notification.name isEqualToString:kNotificationCacheRefreshEnd]) {
        self.reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [TYIndeterminateProgressBar hideFromView:self.view];
    }
    else if([notification.name isEqualToString:@"checkedIn"]) {
        [self.tableView reloadData];
    }
}

-(void) subscribeToNotifications {
    DebugLog(@"Notification constants = %@-%@-%@-%@", kFBManagerLoginNotification, kFBManagerLogOutNotification, kNotificationCacheRefreshStart, kNotificationCacheRefreshEnd);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kFBManagerLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kFBManagerLogOutNotification object:nil];
    // Listen to notification if check-in cache starts / ends up dating itself and display an unintrusive "working" animation.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kNotificationCacheRefreshStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kNotificationCacheRefreshEnd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"checkedIn" object:nil];
}

-(void) unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFBManagerLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFBManagerLogOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCacheRefreshEnd object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCacheRefreshStart object:nil];
}

// Refactor?
-(float) heightForText:(NSString *) messageText withFont:(UIFont *) font {
    if (!messageText || [messageText isBlank]) {
        return 0.0f;
    }
    CGSize constraintSize;
    constraintSize.width = 260.0f;
    constraintSize.height = MAXFLOAT;
    CGSize size = [messageText sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

-(CGFloat) heightForIndexPath:(NSIndexPath *) indexPath {
    TYCheckIn *checkIn = [self.cache.checkIns objectAtIndex:indexPath.row];
    float height = 125.0f;
    if ([checkIn hasPhoto]) {
        height = height + 200.0f + 5.0f;
    }
    if ([checkIn hasMessage]) {
        UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
        height = height + [self heightForText:checkIn.message withFont:font] + 5.0f;
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
