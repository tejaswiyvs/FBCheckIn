//
//  TYExploreDetailViewController.m
//  FBCheckIn
//
//  Created by Teja on 12/31/12.
//
//

#import "TYExploreDetailViewController.h"
#import "TYExploreCell.h"
#import "SVProgressHUD.h"
#import "TYPlaceProfileViewController.h"
#import "Constants.h"
#import "UIColor+HexString.h"
#import "UIImage+Convinience.h"
#import "UIImageView+WebCache.h"

@interface TYExploreDetailViewController ()
-(NSMutableArray *) filteredPages:(NSMutableArray *) pages;
@end

@implementation TYExploreDetailViewController

@synthesize tableView = _tableView;
@synthesize pages = _pages;
@synthesize filter = _filter;
@synthesize locationManager = _locationManager;
@synthesize location = _location;
@synthesize pageDataRequest = _pageDataRequest;

-(id) initWithFilter:(NSString *) filter {
    self = [super initWithNibName:@"TYExploreDetailView" bundle:nil];
    if (self) {
        self.filter = filter;
        self.pages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self updateLocation];
    self.title = self.filter;
}

-(void)dealloc {
    [self.request cancel];
    [self.pageDataRequest cancel];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TYFBRequest

-(void) loadPlaces {
    DebugLog(@"Loading nearby places");
    if (![self.filter isEqualToString:kFriendsBeenToFilter]) {
        self.request = [[TYFBRequest alloc] init];
        self.request.delegate = self;
        [self.request placesNearLocation:self.location.coordinate withQuery:@"" limit:100];
    }
    else {
        self.request = [[TYFBRequest alloc] init];
        self.request.delegate = self;
        [self.request placesVisitedByFriendsNearLocation:self.location.coordinate];
    }
}

-(void) loadPageData:(NSMutableArray *) pages {
    self.pageDataRequest = [[TYFBRequest alloc] init];
    self.pageDataRequest.delegate = self;
    [self.pageDataRequest loadPageData:pages];
}

-(void)fbHelper:(TYFBRequest *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    if (helper == self.request) {
        NSMutableArray *pages = [results objectForKey:@"data"];
        [self loadPageData:pages];
    }
    else {
        NSMutableArray *pages = [results objectForKey:@"data"];
        self.pages = [self filteredPages:pages];
        if ([self.pages count] == 0) {
            [SVProgressHUD showErrorWithStatus:@"Couldn't find any places matching your search criteria nearby."];
        }
        else {
            [SVProgressHUD showSuccessWithStatus:@""];
        }
        [self.tableView reloadData];
    }
}

-(void)fbHelper:(TYFBRequest *)helper didFailWithError:(NSError *)err {
    [SVProgressHUD showErrorWithStatus:@"Couldn't load near by pages. Please try again."];
}

#pragma mark - Location Manager

-(void) updateLocation {
    DebugLog(@"TYExploreDetailViewController: Updating Location.");
    [SVProgressHUD showWithStatus:@"Loading ..."];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DebugLog(@"Updating location failed.");
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    [SVProgressHUD showErrorWithStatus:@"Couldn't find your current location. Please try again when you have sufficient signal strength."];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.location = newLocation;
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    [self loadPlaces];
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pages count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 182.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kReuseId = @"exploreDetailCell";
    TYExploreCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseId];
    if (!cell) {
        // Load from nib
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TYExploreCell" owner:self options:nil];
        for (id object in nib) {
            if([object isKindOfClass:[TYExploreCell class]])
                cell = (TYExploreCell *) object;
        }
    }
    TYPage *page = [self.pages objectAtIndex:indexPath.row];
    [cell.pageNameLbl setText:page.pageName];
    [cell.pageCategoriesLbl setText:[self pageCategoriesTxtFromArray:page.categories]];
    if (page.coverPictureUrl) {
        __unsafe_unretained UIImageView *coverPictureView2 = cell.coverImg;
        [cell.coverImg setImageWithURL:[NSURL URLWithString:page.coverPictureUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            CGRect cropRect = CGRectMake(0.0f, page.coverOffSetY, 851.0f, 315.0f);
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
            // or use the UIImage wherever you like
            [coverPictureView2 setImage:[UIImage imageWithCGImage:imageRef]];
            CGImageRelease(imageRef);
        }];
    }
    else {
        UIImage *image = [UIImage imageWithColor:[UIColor dullWhite] frame:cell.coverImg.frame];
        [cell.coverImg setImage:image];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Display the page.
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYPage *page = [self.pages objectAtIndex:indexPath.row];
    TYPlaceProfileViewController *placeProfile = [[TYPlaceProfileViewController alloc] initWithPlace:page];
    [self.navigationController pushViewController:placeProfile animated:YES];
}

#pragma mark - Helpers

-(NSMutableArray *) filteredPages:(NSMutableArray *) pages {
    if ([self.filter isEqualToString:kTopPicksFilter]) {
        return [self topPages:pages];
    }
    else if ([self.filter isEqualToString:kFoodFilter]) {
        return [self restaurants:pages];
    }
    else if ([self.filter isEqualToString:kCoffeeFilter]) {
        return [self coffeeShops:pages];
    }
    else if ([self.filter isEqualToString:kNightLifeFilter]) {
        return [self nightLife:pages];
    }
    else if ([self.filter isEqualToString:kArtsFilter]) {
        return [self artsyPlaces:pages];
    }
    else if ([self.filter isEqualToString:kShoppingFilter]) {
        return [self shoppingMalls:pages];
    }
    else if ([self.filter isEqualToString:kSightsFilter]) {
        return [self sightSeeing:pages];
    }
    else if ([self.filter isEqualToString:kFriendsBeenToFilter]) {
        return [self friendsHaveBeenTo:pages];
    }
    return nil;
}

// What can you do? Return pages with the highest number of check-ins nearby? Is it possible to figure out Yelp! ratings? Maybe it would be worth it to add yelp ratings, but at a later point. What's a good v1?
-(NSMutableArray *) topPages:(NSMutableArray *) pages {
    [pages sortUsingComparator:^NSComparisonResult(TYPage *obj1, TYPage *obj2) {
        if (obj1.checkIns < obj2.checkIns) {
            return NSOrderedDescending;
        }
        else if(obj1.checkIns == obj2.checkIns) {
            return NSOrderedSame;
        }
        else {
            return NSOrderedDescending;
        }
    }];
    return ([pages count] < 10) ? [[pages subarrayWithRange:NSMakeRange(0, [pages count])] mutableCopy] : [[pages subarrayWithRange:NSMakeRange(0, 10)] mutableCopy];
}

-(NSMutableArray *) restaurants:(NSMutableArray *) pages {
    return [self pages:pages matchingCategories:[NSMutableArray arrayWithObjects:@"restaurant", @"food stand", @"cafe", @"pizza", @"steakhouse", @"sandwich", nil] exactMatch:NO];
}

-(NSMutableArray *) coffeeShops:(NSMutableArray *) pages {
    return [self pages:pages matchingCategories:[NSMutableArray arrayWithObjects:@"coffee", nil] exactMatch:NO];
}

-(NSMutableArray *) nightLife:(NSMutableArray *) pages {
    return [self pages:pages matchingCategories:[NSMutableArray arrayWithObjects:@"pub", @"gay bar", @"wine bar", @"Winery/Vineyard", @"karaoke", @"Dance Club", @"Sports Bar", @"Bar & Grill", @"Night Club", @"nightlife", @"night club", @"bar", nil] exactMatch:YES];
}

-(NSMutableArray *) artsyPlaces:(NSMutableArray *) pages {
    return [self pages:pages matchingCategories:[NSMutableArray arrayWithObjects:@"Art Gallery", @"Modern Art Museum", @"Art Museum", @"Museum/Art Gallery", @"Museum", nil] exactMatch:YES];
}

-(NSMutableArray *) shoppingMalls:(NSMutableArray *) pages {
    return [self pages:pages matchingCategories:[NSMutableArray arrayWithObjects:@"antique", @"shoe store", @"cosmetics", @"shopping", @"mall", @"clothing", nil] exactMatch:NO];
}

-(NSMutableArray *) sightSeeing:(NSMutableArray *) pages {
    return [self pages:pages matchingCategories:[NSMutableArray arrayWithObjects:@"tourist", @"attractions", @"public places", @"landmark", @"theme park", @"historical place", @"park", @"water park", @"outdoors", @"museum", @"Art Gallery", @"Winery/Vineyard", @"Sightseeing", nil] exactMatch:NO];
}

-(NSMutableArray *) friendsHaveBeenTo:(NSMutableArray *) pages {
    return pages;
}

-(NSMutableArray *) events:(NSMutableArray *) pages {
    return [self pages:pages matchingCategories:[NSMutableArray arrayWithObject:@"event"] exactMatch:NO];
}

-(NSMutableArray *) pages:(NSMutableArray *) pages matchingCategories:(NSMutableArray *) categories exactMatch:(BOOL) exactMatch {
    NSMutableArray *matchingPages = [NSMutableArray array];
    for (TYPage *page in pages) {
        BOOL brk = NO;
        for (NSString *pageCategory in page.categories) {
            NSLog(@"pageId = %@, pageCategory=%@", page.pageId, pageCategory);
            if (brk) {
                break;
            }
            for (NSString *category in categories) {
                if (!exactMatch && ([pageCategory.lowercaseString rangeOfString:category.lowercaseString].location != NSNotFound)) {
                    [matchingPages addObject:page];
                    brk = YES;
                    break;
                }
                else if(exactMatch && ([pageCategory.lowercaseString isEqualToString:category.lowercaseString])) {
                    [matchingPages addObject:page];
                    brk = YES;
                    break;
                }
            }
        }
    }
    return matchingPages;
}

-(NSString *) pageCategoriesTxtFromArray:(NSMutableArray *) categories {
    NSString *categoryStr = @"";
    for (NSString *category in categories) {
        categoryStr = [categoryStr stringByAppendingFormat:@"%@, ", category];
    }
    if ([categoryStr length] > 0) {
        categoryStr = [categoryStr substringToIndex:([categoryStr length] - 2)];
    }
    return categoryStr;
}
@end
