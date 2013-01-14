//
//  TYPlaceProfileViewController.m
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import "TYPlaceProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+HexString.h"
#import "TYAnnotation.h"
#import "NSString+Common.h"
#import "TYWildcardGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "TYUtils.h"
#import "TYIndeterminateProgressBar.h"
#import "TYCurrentUser.h"

@interface TYPlaceProfileViewController ()
-(UIView *) makeHeaderView;
-(UITableViewCell *) makeContactCell;
-(UITableViewCell *) makeInfoCell;
-(UITableViewCell *) makeMetaDataCell;
-(UIView *) infoViewWithFrame:(CGRect) frame mainText:(NSString *) mainTxt subText:(NSString *) subTxt;
-(NSString *) categories;
-(void) callButtonClicked:(id) sender;
-(void) directionsButtonClicked:(id) sender;
-(void) openMapsApp;
-(void) loadAdditionalMetaData;
@end

@implementation TYPlaceProfileViewController

const int kAlertViewYesIndex = 1;
const int kAlertViewNoIndex = 0;

const int kRowIndexInfo = 0;
const int kRowIndexContact = 1;
const int kRowIndexStats = 2;

const float kRowHeightInfo = 70.0f;
const float kRowHeightContact = 110.0f;
const float kRowHeightMetaData = 100.0f;

const int kNumberOfRows = 3;

@synthesize place = _place;
@synthesize tableView = _tableView;
@synthesize metaDataRequest = _metaDataRequest;

-(id) initWithPlace:(TYPage *) place {
    self = [super init];
    if (self) {
        self.place = place;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setTitle:self.place.pageName];
    [self.tableView setTableHeaderView:[self makeHeaderView]];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundView = nil;;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor bgColor];
    self.tableView.separatorColor = [UIColor subtitleTextColor];
    [self loadAdditionalMetaData];
    
    // Analytics
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    TYUser *currentUser = [TYCurrentUser sharedInstance].user;
    [mixpanel track:@"PageProfileViewed" properties:[NSDictionary dictionaryWithObjectsAndKeys:currentUser.userId, @"userId", currentUser.sex, @"sex", self.place.pageId, @"pageId", nil]];
}

-(void) dealloc {
    if (self.metaDataRequest) {
        [self.metaDataRequest cancel];
    }
}

#pragma mark - UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case kRowIndexInfo:
            return kRowHeightInfo;
        case kRowIndexContact:
            return kRowHeightContact;
        case kRowIndexStats:
            return kRowHeightMetaData;
        default:
            return 0.0f;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case kRowIndexInfo:
            return [self makeInfoCell];
        case kRowIndexContact:
            return [self makeContactCell];
        case kRowIndexStats:
            return [self makeMetaDataCell];
    }
    return nil;
}

#pragma mark - TYFBFacade

-(void) loadAdditionalMetaData {
    [TYIndeterminateProgressBar showInView:self.view backgroundColor:[UIColor dullWhite] indicatorColor:[UIColor dullRed] borderColor:[UIColor darkGrayColor]];
    self.metaDataRequest = [[TYFBRequest alloc] init];
    self.metaDataRequest.delegate = self;
    [self.metaDataRequest loadMetaDataForPage:self.place];
}

-(void)fbHelper:(TYFBRequest *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    NSNumber *count = [results objectForKey:@"data"];
    if (count) {
        self.place.numberOfFriendsCheckedIn = [count intValue];
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kRowIndexStats inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [TYIndeterminateProgressBar hideFromView:self.view];
}

-(void)fbHelper:(TYFBRequest *)helper didFailWithError:(NSError *)err {
    [TYIndeterminateProgressBar hideFromView:self.view];
    DebugLog(@"%@", err);
}

#pragma mark - Event Handlers

-(void) callButtonClicked:(id) sender {
    if (!self.place.hasPhone) {
        [TYUtils displayAlertWithTitle:@"Attention" message:[NSString stringWithFormat:@"Cannot Call %@. We don't have a phone number for this place.", self.place.pageName]];
        return;
    }
    
    NSString *phoneNumber = [NSString stringWithFormat:@"tel:%@", self.place.phoneNumber];
    NSString *deviceType = [UIDevice currentDevice].model;
    if ([deviceType isEqualToString:@"iPhone"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
    else {
        [TYUtils displayAlertWithTitle:@"Attention" message:@"This feature is only supported on iPhones."];
    }
}

-(void) directionsButtonClicked:(id) sender {
    [self openMapsApp];
}

#pragma mark - Helpers

-(UIView *) makeHeaderView {    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.02;
    span.longitudeDelta=0.02;
    CLLocationCoordinate2D location = self.place.location;
    region.span=span;
    region.center=location;
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.f, 133.0f)];
    [mapView setMapType:MKMapTypeStandard];
    TYAnnotation *annotation = [[TYAnnotation alloc] initWithCoordinate:self.place.location];
    [mapView addAnnotation:annotation];
    [mapView setCenterCoordinate:self.place.location];
    [mapView setZoomEnabled:NO];
    [mapView setScrollEnabled:NO];
    [mapView setRegion:region];
    TYWildcardGestureRecognizer * tapInterceptor = [[TYWildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Would you like to open this location in Maps?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    };
    [mapView addGestureRecognizer:tapInterceptor];

    return mapView;
}

-(UITableViewCell *) makeInfoCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setFrame:CGRectMake(0.0f, 0.0f, 320.0f, kRowHeightInfo)];
    [cell setBackgroundColor:[UIColor dullWhite]];
    
    UIImageView *profilePictureImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 10.0f, 50.0f, 50.0f)];
    [profilePictureImgView setImageWithURL:[NSURL URLWithString:self.place.pagePictureUrl]];
    [profilePictureImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [profilePictureImgView.layer setBorderWidth:3.0f];
    [profilePictureImgView.layer setCornerRadius:3.0f];
    [profilePictureImgView.layer setMasksToBounds:YES];
    [cell addSubview:profilePictureImgView];
    
    UILabel *placeNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(68.0f, 10.0f, 234.0f, 20.0f)];
    [placeNameLbl setTextColor:[UIColor headerTextColor]];
    [placeNameLbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [placeNameLbl setText:self.place.pageName];
    [placeNameLbl setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:placeNameLbl];
    
    UILabel *placeCategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(68.0f, 40.0f, 234.0f, 20.0f)];
    [placeCategoryLabel setTextColor:[UIColor subtitleTextColor]];
    [placeCategoryLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [placeCategoryLabel setText:[self categories]];
    [placeCategoryLabel setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:placeCategoryLabel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UITableViewCell *) makeContactCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setFrame:CGRectMake(0.0f, 0.0f, 320.0f, kRowHeightContact)];
    [cell setBackgroundColor:[UIColor dullWhite]];
    
    if ([self.place hasAddress] || [self.place hasPhone]) {
        UILabel *addressLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 3.0f, 280.0f, 34.0f)];
        [addressLbl setText:[NSString stringWithFormat:@"Address: %@", self.place.shortAddress]];
        [addressLbl setTextColor:[UIColor headerTextColor]];
        [addressLbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [addressLbl setNumberOfLines:2];
        [addressLbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:addressLbl];
        
        UILabel *phoneNumberLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 45.0f, 280.0f, 18.0f)];
        [phoneNumberLbl setText:[NSString stringWithFormat:@"Phone: %@", self.place.phoneNumber]];
        [phoneNumberLbl setTextColor:[UIColor subtitleTextColor]];
        [phoneNumberLbl setFont:[UIFont systemFontOfSize:14.0f]];
        [phoneNumberLbl setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:phoneNumberLbl];
        
        UIButton *callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [callButton setFrame:CGRectMake(86.0f, 71.0f, 70.0f, 35.0f)];
        [callButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateNormal];
        [callButton setTitle:@"Call" forState:UIControlStateNormal];
        [callButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [callButton setEnabled:YES];
        [callButton addTarget:self action:@selector(callButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:callButton];
        
        UIButton *directionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [directionsButton setFrame:CGRectMake(164.0f, 71.0f, 70.0f, 35.0f)];
        [directionsButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateNormal];
        [directionsButton setTitle:@"Directions" forState:UIControlStateNormal];
        [directionsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [directionsButton addTarget:self action:@selector(directionsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:directionsButton];
    }
    else {
        UILabel *noContactLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 46.0f, 280.0f, 18.0f)];
        [noContactLbl setTextColor:[UIColor headerTextColor]];
        [noContactLbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [noContactLbl setBackgroundColor:[UIColor clearColor]];
        [noContactLbl setTextAlignment:UITextAlignmentCenter];
        [noContactLbl setText:@"Contact Information Unavailable"];
        [cell addSubview:noContactLbl];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UITableViewCell *) makeMetaDataCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setFrame:CGRectMake(0.0f, 0.0f, 320.0f, kRowHeightMetaData)];
    [cell setBackgroundColor:[UIColor dullWhite]];
    
    [cell addSubview:[self infoViewWithFrame:CGRectMake(20.0f, 11.0f, 88.0f, 77.0f)
                                    mainText:[NSString stringWithFormat:@"%d", self.place.numberOfFriendsCheckedIn]
                                     subText:@"friends were here."]];
    
    [cell addSubview:[self infoViewWithFrame:CGRectMake(116.0f, 11.0f, 88.0f, 77.0f)
                                    mainText:[NSString stringWithFormat:@"%d", self.place.fanCount]
                                     subText:@"people like this"]];

    [cell addSubview:[self infoViewWithFrame:CGRectMake(212.0f, 11.0f, 88.0f, 77.0f)
                                    mainText:[NSString stringWithFormat:@"%d", self.place.checkIns]
                                     subText:@"checkins here"]];
    return cell;
}

-(UIView *) infoViewWithFrame:(CGRect) frame mainText:(NSString *) mainTxt subText:(NSString *) subTxt {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view setBackgroundColor:[UIColor colorWithHexString:@"FFFBFA"]];
    [view.layer setCornerRadius:3.0f];
    [view.layer setBorderColor:[[UIColor subtitleTextColor] CGColor]];
    [view.layer setBorderWidth:1.0f];
    
    UILabel *mainTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 9.0f, 88.0f, 30.0f)];
    [mainTextLabel setTextAlignment:UITextAlignmentCenter];
    [mainTextLabel setText:mainTxt];
    [mainTextLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [mainTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [mainTextLabel setTextColor:[UIColor headerTextColor]];
    [mainTextLabel setBackgroundColor:[UIColor clearColor]];
    
    UILabel *subTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 47.0f, 88.0f, 30.0f)];
    [subTextLabel setTextAlignment:UITextAlignmentCenter];
    [subTextLabel setText:subTxt];
    [subTextLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [subTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [subTextLabel setTextColor:[UIColor subtitleTextColor]];
    [subTextLabel setBackgroundColor:[UIColor clearColor]];
    [subTextLabel setNumberOfLines:2];
    
    [view addSubview:mainTextLabel];
    [view addSubview:subTextLabel];
    
    return view;
}

-(NSString *) categories {
    NSString *categoryStr = @"";
    for (NSString *category in self.place.categories) {
        categoryStr = [categoryStr stringByAppendingFormat:@"%@, ", category];
    }
    
    if (![categoryStr isBlank]) {
        categoryStr = [categoryStr substringToIndex:(categoryStr.length - 2)];
    }
    
    return categoryStr;
}

-(void) openMapsApp {
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.place.location.latitude, self.place.location.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:self.place.pageName];
        [mapItem openInMapsWithLaunchOptions:nil];
    }
    else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f", self.place.location.latitude, self.place.location.longitude]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == kAlertViewYesIndex) {
        [self openMapsApp];
    }
}

@end
