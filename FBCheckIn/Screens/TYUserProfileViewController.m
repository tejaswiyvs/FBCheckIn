//
//  TYUserProfileViewController.m
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import "TYUserProfileViewController.h"
#import "UIColor+HexString.h"
#import "TYAnnotation.h"
#import "NSString+Common.h"
#import <QuartzCore/QuartzCore.h>
#import "TYUtils.h"
#import "TYIndeterminateProgressBar.h"
#import "UIImageView+AFNetworking.h"
#import "TYUserProfileViewController.h"
#import "UIImage+Convinience.h"
#import "TYPictureViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "TYPlaceProfileViewController.h"
#import "TYCurrentUser.h"
#import "TYIndeterminateProgressBar.h"
#import "UIImage+Convinience.h"
#import "SCNavigationBar.h"

@interface TYUserProfileViewController ()
-(UIView *) makeHeaderView;
-(void) loadUserMetaData;
@end

@implementation TYUserProfileViewController

const int kNumberOfUserSections = 3;
const int kRequestTagTop5Pages = 0;
const int kRequestTagLast3CheckIns = 1;

@synthesize tableView = _tableView;
@synthesize userCheckInsRequest = _getTopPlacesRequest;
@synthesize user = _user;
@synthesize pageMetaDataRequests = _pageMetaDataRequests;
@synthesize topVisitedPlaces = _topVisitedPlaces;
@synthesize topVisitedPlacesCount = _topVisitedPlacesCount;
@synthesize last3CheckIns = _last3CheckIns;
@synthesize mapView = _mapView;

-(id) initWithUser:(TYUser *) user {
    self = [super init];
    if (self) {
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 505.0f) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setTitle:@"User"];
    [self.tableView setTableHeaderView:[self makeHeaderView]];
    [self.view addSubview:self.tableView];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor bgColor];
    self.tableView.separatorColor = [UIColor subtitleTextColor];
    [self.tableView setTableFooterView:[self makeFooterView]];
    [self loadUserMetaData];
    
    // Analytics
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    TYUser *currentUser = [TYCurrentUser sharedInstance].user;
    [mixpanel track:@"UserProfileViewed" properties:[NSDictionary dictionaryWithObjectsAndKeys:currentUser.userId, @"userId", currentUser.sex, @"sex", self.user.userId, @"viewedUserId", nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    for (TYFBRequest *request in self.pageMetaDataRequests) {
        [request cancel];
    }
    [self.userCheckInsRequest cancel];
}

#pragma mark - TYFBFacade

-(void) loadUserMetaData {
    DebugLog(@"Loading User Meta Data");
    [TYIndeterminateProgressBar showInView:self.view backgroundColor:[UIColor dullWhite] indicatorColor:[UIColor dullRed] borderColor:[UIColor darkGrayColor]];
    self.userCheckInsRequest = [[TYFBRequest alloc] init];
    self.userCheckInsRequest.delegate = self;
    [self.userCheckInsRequest loadMetaDataForUser:self.user];
}

-(void) loadPageData:(NSArray *) pageIds withTag:(int) tag {
    if (!self.pageMetaDataRequests) {
        self.pageMetaDataRequests = [[NSMutableArray alloc] init];
    }
    for (NSString *pageId in pageIds) {
        if (![pageId isBlank]) {
            TYFBRequest *pageMetaDataRequest = [[TYFBRequest alloc] init];
            pageMetaDataRequest.delegate = self;
            pageMetaDataRequest.tag = tag;
            [self.pageMetaDataRequests addObject:pageMetaDataRequest];
            TYPage *page = [[TYPage alloc] init];
            page.pageId = pageId;
            [pageMetaDataRequest loadPageData:[NSMutableArray arrayWithObject:page]];
        }
    }
}

-(void)fbHelper:(TYFBRequest *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    if (helper == self.userCheckInsRequest) {
        NSMutableArray *checkIns = [results objectForKey:@"data"];
        checkIns = [self sortedCheckIns:checkIns];
        if (!checkIns || [checkIns count] == 0) {
            [TYIndeterminateProgressBar hideFromView:self.view];
            return;
        }
        // Load Data For Top 5 Most Visited Places.
        NSArray *top5Pages = [self top5PagesFromCheckIns:checkIns];
        [self loadPageData:top5Pages withTag:kRequestTagTop5Pages];
        
        // Load Data For Most Recent Checkins
        NSMutableArray *pageIds = [NSMutableArray array];
        for (TYCheckIn *checkIn in checkIns) {
            [pageIds addObject:checkIn.page.pageId];
        }
        if (pageIds.count > 3) {
            [self loadPageData:[pageIds subarrayWithRange:NSMakeRange(0, 3)] withTag:kRequestTagLast3CheckIns];
        }
        else {
            [self loadPageData:[pageIds subarrayWithRange:NSMakeRange(0, pageIds.count)] withTag:kRequestTagLast3CheckIns];
        }
    }
    else {
        [self.pageMetaDataRequests removeObject:helper];
        if (!self.topVisitedPlaces) {
            self.topVisitedPlaces = [NSMutableArray array];
        }
        if (!self.last3CheckIns) {
            self.last3CheckIns = [NSMutableArray array];
        }
        NSMutableArray *resultsArr = [results objectForKey:@"data"];
        if (resultsArr && [resultsArr count] == 1) {
            TYPage *page = [resultsArr objectAtIndex:0];
            if (page && helper.tag == kRequestTagTop5Pages) {
                [self.topVisitedPlaces addObject:page];
            }
            else if(page && helper.tag == kRequestTagLast3CheckIns) {
                [self.last3CheckIns addObject:page];
            }
            if ([self.pageMetaDataRequests count] == 0) {
                [TYIndeterminateProgressBar hideFromView:self.view];
                [self.tableView reloadData];
                [self reloadPins];
            }
        }
    }
}

-(void)fbHelper:(TYFBRequest *)helper didFailWithError:(NSError *)err {
    [TYIndeterminateProgressBar hideFromView:self.view];
    if (helper == self.userCheckInsRequest) {
        
    }
    else {
        [self.pageMetaDataRequests removeObject:helper];
    }
    if ([self.pageMetaDataRequests count] == 0) {
        [TYIndeterminateProgressBar hideFromView:self.view];
        [self.tableView reloadData];
        [self reloadPins];
    }
}

#pragma mark - UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 101.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topVisitedPlaces count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.0f, 315.0f, 15.0f)];
    [titleLabel setText:@"Usually Seen At"];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor headerTextColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    return titleLabel;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.0f, 315.0f, 15.0f)];
    [titleLabel setText:@"Last 3 CheckIns At"];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor headerTextColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    return titleLabel;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kReuseId = @"place_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseId];
        cell.frame = CGRectMake(3.0f, 0.0f, 300.0f, 120.0f);
        cell.backgroundColor = [UIColor clearColor];
    }
    
    TYPage *page = [self.topVisitedPlaces objectAtIndex:indexPath.row];
    
    UIImageView *backgroundImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 100.0f)];
    [backgroundImgView setImage:[UIImage imageNamed:@"table-cell-bg.png"]];
    [cell addSubview:backgroundImgView];
    
    UIImageView *placePictureImgView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0f, 12.0f, 68.0f, 76.0f)];
    [placePictureImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [placePictureImgView.layer setBorderWidth:1.0f];
    [placePictureImgView.layer setCornerRadius:4.0f];
    [placePictureImgView setImageWithURL:[NSURL URLWithString:page.pagePictureUrl]];
    [cell addSubview:placePictureImgView];
    
    UILabel *placeNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(90.0f, 32.0f, 140.0f, 35.0f)];
    [placeNameLbl setBackgroundColor:[UIColor clearColor]];
    [placeNameLbl setText:page.pageName];
    [placeNameLbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [placeNameLbl setTextColor:[UIColor headerTextColor]];
    [placeNameLbl setNumberOfLines:2];
    [cell addSubview:placeNameLbl];
    
    UIView *checkInCountHolderView = [[UIView alloc] initWithFrame:CGRectMake(248.0f, 39.0f, 20.0f, 20.0f)];
    [checkInCountHolderView.layer setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
    [checkInCountHolderView.layer setCornerRadius:4.0f];
    [checkInCountHolderView.layer setBorderColor:[[UIColor headerTextColor] CGColor]];
    [checkInCountHolderView.layer setBorderWidth:1.0f];
    
    NSNumber *checkInCount = [self.topVisitedPlacesCount objectAtIndex:indexPath.row];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    [label setText:[checkInCount stringValue]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [label setTextColor:[UIColor headerTextColor]];
    [checkInCountHolderView addSubview:label];
    
    [cell addSubview:checkInCountHolderView];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TYPage *page = [self.topVisitedPlaces objectAtIndex:indexPath.row];
    TYPlaceProfileViewController *placeProfileViewController = [[TYPlaceProfileViewController alloc] initWithPlace:page];
    [self.navigationController pushViewController:placeProfileViewController animated:YES];
}

#pragma mark - MKMapViewDelegate

#pragma mark - Event Handlers

-(void) profilePictureTapped:(UITapGestureRecognizer *) recognizer {
    TYPictureViewController *pictureScreen = [[TYPictureViewController alloc] initWithImageUrl:self.user.profilePictureUrl hiResUrl:self.user.hiResProfilePictureUrl];
    pictureScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:pictureScreen animated:YES];
}

#pragma mark - Helpers

-(NSMutableArray *) sortedCheckIns:(NSMutableArray *) checkIns {
    [checkIns sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([((TYCheckIn *) obj1).checkInDate compare:((TYCheckIn *) obj2).checkInDate] == NSOrderedDescending) {
            return NSOrderedAscending;
        }
        else if ([((TYCheckIn *) obj1).checkInDate compare:((TYCheckIn *) obj2).checkInDate] == NSOrderedAscending) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    return checkIns;
}

-(UIView *) makeFooterView {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 200.0f)];
    [self.mapView setMapType:MKMapTypeStandard];
    self.mapView.delegate = self;
    return self.mapView;
}

-(void) reloadPins {
    if (self.last3CheckIns.count > 0) {
        self.mapView.region = [self regionThatFitsCoordinatesOfPages:self.last3CheckIns];
        for (TYPage *page in self.last3CheckIns) {
            TYAnnotation *annotation = [[TYAnnotation alloc] initWithCoordinate:page.location];
            annotation.title = page.pageName;
            [self.mapView addAnnotation:annotation];
        }
    }
}

-(NSArray *) top5PagesFromCheckIns:(NSMutableArray *) checkIns {
    NSMutableDictionary *countDictionary = [[NSMutableDictionary alloc] init];
    
    for (TYCheckIn *checkIn in checkIns) {
        if (![countDictionary objectForKey:checkIn.page.pageId]) {
            [countDictionary setObject:[NSNumber numberWithInt:1] forKey:checkIn.page.pageId];
        }
        else {
            int count = [[countDictionary objectForKey:checkIn.page.pageId] intValue];
            [countDictionary setObject:[NSNumber numberWithInt:++count] forKey:checkIn.page.pageId];
        }
    }
    
    NSArray *sortedCheckins = [countDictionary keysSortedByValueWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 intValue] == [obj2 intValue]) {
            return NSOrderedSame;
        }
        else if([obj1 intValue] > [obj2 intValue]) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedDescending;
        }
    }];
    
    if([sortedCheckins count] > 5) {
        sortedCheckins = [sortedCheckins subarrayWithRange:NSMakeRange(0, 5)];
    }
    
    self.topVisitedPlacesCount = [NSMutableArray array];
    for (NSString *pageId in sortedCheckins) {
        [self.topVisitedPlacesCount addObject:[countDictionary objectForKey:pageId]];
    }
    
    return sortedCheckins;
}

-(UIView *) makeHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.f, 160.0f)];
    UIImageView *coverPictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.f, 133.0f)];
    
    if (self.user.coverPictureUrl) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.user.coverPictureUrl]];
        __unsafe_unretained UIImageView *coverPictureView2 = coverPictureView;
        [coverPictureView setImageWithURLRequest:request placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             dispatch_async(dispatch_get_main_queue(), ^(void){
                                                 CGRect cropRect = CGRectMake(0.0f, self.user.coverOffSetY, 851.0f, 315.0f);
                                                 CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                                                 // or use the UIImage wherever you like
                                                 [coverPictureView2 setImage:[UIImage imageWithCGImage:imageRef]];
                                                 CGImageRelease(imageRef);
                                             });
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             dispatch_async(dispatch_get_main_queue(), ^(void){
                                                 DebugLog(@"Error loading user's cover photo : %@", error);
                                             });
                                         }
         ];
    }
    else {
        [coverPictureView setImage:[UIImage imageWithColor:[UIColor dullWhite] frame:coverPictureView.frame]];
    }
    [view addSubview:coverPictureView];
    
    UIImageView *profilePictureImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 91.0f, 65.0f, 65.0f)];
    [profilePictureImgView setImageWithURL:[NSURL URLWithString:self.user.profilePictureUrl]];
    [profilePictureImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [profilePictureImgView.layer setBorderWidth:3.0f];
    [profilePictureImgView.layer setCornerRadius:3.0f];
    [profilePictureImgView.layer setMasksToBounds:YES];
    profilePictureImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePictureTapped:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [profilePictureImgView addGestureRecognizer:tapRecognizer];
    [profilePictureImgView setContentMode:UIViewContentModeScaleAspectFill];
    [view addSubview:profilePictureImgView];
    
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(83.0f, 135.0f, 217.0f, 21.0f)];
    [nameLbl setBackgroundColor:[UIColor clearColor]];
    [nameLbl setTextColor:[UIColor blackColor]];
    [nameLbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [nameLbl setText:self.user.fullName];
    [view addSubview:nameLbl];
    return view;
}

-(MKCoordinateRegion) regionThatFitsCoordinatesOfPages:(NSArray *) pages {
    if (!pages || [pages count] == 0) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(-999.0f, -999.0f);
        MKCoordinateSpan span = MKCoordinateSpanMake(1.0f, 1.0f);
        return MKCoordinateRegionMake(location, span);
    }
    
    double maxLong = -999.0f, minLong = 999.0f, maxLat = -999.0f, minLat = 999.0f;
    for (TYPage *page in pages) {
        if(page.location.latitude > maxLat) {
            maxLat = page.location.latitude;
        }
        if (page.location.longitude > maxLong) {
            maxLong = page.location.longitude;
        }
        if (page.location.latitude < minLat) {
            minLat = page.location.latitude;
        }
        if (page.location.longitude < minLong) {
            minLong = page.location.longitude;
        }
    }
        
    //calculate center of map
    double centerLong = (maxLong + minLong) / 2;
    double centerLat = (maxLat + minLat) / 2;
    
    //calculate deltas
    double deltaLat = abs(maxLat - minLat);
    double deltaLong = abs(maxLong - minLong);
    
    //set minimal delta
    if (deltaLat < 2) {deltaLat = 2;}
    if (deltaLong < 2) {deltaLong = 2;}
    
    //create new region and set map
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(centerLat, centerLong);
    MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat, deltaLong);
    MKCoordinateRegion region = {coord, span};
    return region;
}

-(BOOL) isValidRegion:(MKCoordinateRegion) region {
    return !(region.center.latitude == -999.0f);
}

@end
