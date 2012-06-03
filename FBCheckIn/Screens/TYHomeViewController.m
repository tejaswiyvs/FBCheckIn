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

@interface TYHomeViewController ()
-(void) checkInButtonClicked:(id) sender;
-(void) loadCheckIns;
-(void) reloadIfDone;
-(void) subscribeToNotifications;
-(void) unsubscribeFromNotifications;
@end

@implementation TYHomeViewController

@synthesize tableView = _tableView;
@synthesize checkIns = _checkIns;
@synthesize checkInRequest = _checkInRequest;
@synthesize pagesRequest = _pagesRequest;
@synthesize usersRequest = _usersRequest;
@synthesize pagesRequestCompleted = _pagesRequestCompleted;
@synthesize usersRequestCompleted = _usersRequestCompleted;
@synthesize facebook = _facebook;

-(id) initWithTabBar {
    self = [super initWithNibName:@"TYFriendsViewController" bundle:nil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"friends.png"];
        self.tabBarItem.title = @"Friends";
        self.title = @"Check-ins";
        self.checkIns = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check-in" style:UIBarButtonItemStylePlain target:self action:@selector(checkInButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:checkInButton];
    TYFBManager *manager = [TYFBManager sharedInstance];
    self.facebook = manager.facebook;
    if ([self.facebook isSessionValid]) {
        [self loadCheckIns];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self unsubscribeFromNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) checkInButtonClicked:(id) sender {
    TYCheckInViewController *checkInScreen = [[TYCheckInViewController alloc] initWithNibName:@"TYCheckInViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:checkInScreen];
    [self presentModalViewController:navigationController animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.checkIns count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 86.0;
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
    cell.name.text = checkIn.user.fullName;
    cell.checkInLocation.text = checkIn.page.pageName;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSLog(@"image url = %@", checkIn.user.profilePictureUrl);
    [cell.picture setImageWithURL:[NSURL URLWithString:checkIn.user.profilePictureUrl] placeholderImage:[UIImage imageNamed:@"user_placeholder.png"]];
    [cell.picture.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [cell.picture.layer setBorderWidth:3.0f];
    [cell.picture.layer setCornerRadius:3.0f];
    [cell.picture.layer setMasksToBounds:YES];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYCheckIn *checkIn = [self.checkIns objectAtIndex:indexPath.row];
    TYCheckInDetailViewController *checkInDetail = [[TYCheckInDetailViewController alloc] initWithNibName:@"TYCheckInDetailViewController" bundle:nil];
    checkInDetail.checkIn = checkIn;
    [self.navigationController pushViewController:checkInDetail animated:YES];
}

-(void) loadCheckIns {
    [SVProgressHUD showWithStatus:@"Loading Check-ins..."];
    NSString *fql = @"SELECT checkin_id, author_uid, page_id, coords FROM checkin WHERE (author_uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) OR author_uid=me()) LIMIT 50";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fql, @"query", nil];
    self.checkInRequest = [self.facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [SVProgressHUD dismissWithError:@"Could not load check-ins" afterDelay:5.0];
    if (request == self.checkInRequest) {
        
    }
    else if(request == self.pagesRequest) {
        
    }
    else if (request == self.usersRequest) {
        
    }
    NSLog(@"%@", error);
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    if (request == self.checkInRequest) {
        NSString *userRequestsString = @"[";
        NSString *pageRequestsString = @"[";
        for (NSDictionary *checkInDict in (NSArray *) result) {
            TYCheckIn *checkIn = [[TYCheckIn alloc] initWithDictionary:checkInDict];
            [self.checkIns addObject:checkIn];
            NSString *userRequest = [NSString stringWithFormat:@"{ \"method\": \"GET\", \"relative_url\": \"%@\" }", checkIn.user.userId];
            NSString *pageRequest = [NSString stringWithFormat:@"{ \"method\": \"GET\", \"relative_url\": \"%@\" }", checkIn.page.pageId];
            userRequestsString = [userRequestsString stringByAppendingFormat:@"%@,", userRequest];
            pageRequestsString = [pageRequestsString stringByAppendingFormat:@"%@,", pageRequest];
        }
        userRequestsString = [userRequestsString substringToIndex:[userRequestsString length] - 1];
        pageRequestsString = [pageRequestsString substringToIndex:[pageRequestsString length] - 1];
        userRequestsString = [userRequestsString stringByAppendingString:@"]"];
        pageRequestsString = [pageRequestsString stringByAppendingString:@"]"];
        NSLog(@"%@", userRequestsString);
        NSLog(@"%@", pageRequestsString);
        NSMutableDictionary *userRequestParams = [NSMutableDictionary dictionaryWithObject:userRequestsString forKey:@"batch"];
        NSMutableDictionary *pageRequestParams = [NSMutableDictionary dictionaryWithObject:pageRequestsString forKey:@"batch"];
        self.usersRequest = [self.facebook requestWithGraphPath:@"me" andParams:userRequestParams andHttpMethod:@"POST" andDelegate:self];
        self.pagesRequest = [self.facebook requestWithGraphPath:@"me" andParams:pageRequestParams andHttpMethod:@"POST" andDelegate:self];
    }
    else if(request == self.pagesRequest) {
        NSMutableDictionary *pagesDictionary = [[NSMutableDictionary alloc] init];
        for (NSDictionary *pageDictionary in (NSArray *) result) {
            NSNumber *responseCode = [pageDictionary objectForKey:@"code"];
            if ([responseCode intValue] == 200) {
                NSString *responseBodyStr = [pageDictionary objectForKey:@"body"];
                NSDictionary *responseBody = [responseBodyStr objectFromJSONString];
                TYPage *page = [[TYPage alloc] initWithDictionary:responseBody];
                [pagesDictionary setObject:page forKey:page.pageId];
            }
        }
        for (TYCheckIn *checkIn in self.checkIns) {
            TYPage *page = checkIn.page;
            NSString *pageId = [NSString stringWithFormat:@"%@", page.pageId];
            TYPage *downloadedPage = [pagesDictionary objectForKey:pageId];
            if(downloadedPage) {
                checkIn.page = downloadedPage;                
            }
            else {
                TYPage *errorPage = [[TYPage alloc] init];
                errorPage.pageId = page.pageId;
                errorPage.pageName = @"Unknown location";
                checkIn.page = errorPage;
            }
        }
        self.pagesRequestCompleted = YES;
        [self reloadIfDone];
    }
    else if (request == self.usersRequest) {
        NSMutableDictionary *usersDictionary = [[NSMutableDictionary alloc] init];
        for (NSDictionary *userDictionary in (NSArray *) result) {
            NSNumber *responseCode = [userDictionary objectForKey:@"code"];
            if ([responseCode intValue] == 200) {
                NSString *responseBodyStr = [userDictionary objectForKey:@"body"];
                NSDictionary *responseBody = [responseBodyStr objectFromJSONString];
                TYUser *user = [[TYUser alloc] initWithDictionary:responseBody];
                [usersDictionary setObject:user forKey:user.userId];
            }
        }
        for (TYCheckIn *checkIn in self.checkIns) {
            TYUser *user = checkIn.user;
            NSString *userId = [NSString stringWithFormat:@"%@", user.userId];
            TYUser *downloadedUser = [usersDictionary objectForKey:userId];
            if(downloadedUser) {
                checkIn.user = downloadedUser;                
            }
            else {
                [self.checkIns removeObject:checkIn];
            }
        }
        self.usersRequestCompleted = YES; 
        [self reloadIfDone]; 
    }
}

#pragma mark - Helpers

-(void) reloadIfDone {
    if (self.usersRequestCompleted && self.pagesRequestCompleted) {
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    }
}

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
