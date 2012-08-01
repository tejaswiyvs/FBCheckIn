//
//  PPCheckInViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYCheckInViewController.h"
#import "Facebook.h"
#import "SVProgressHUD.h"
#import "TYFBManager.h"
#import "TYPageCell.h"
#import "TYPage.h"
#import "UIImageView+AFNetworking.h"
#import "TYCheckInConfirmationViewController.h"

@interface TYCheckInViewController ()
-(void) cancelButtonClicked:(id) sender;
-(void) loadNearbyPages;
@end

@implementation TYCheckInViewController

@synthesize searchDisplayController;
@synthesize searchBar = _searchBar;
@synthesize allItems = _allItems;
@synthesize searchResults = _searchResults;
@synthesize tableView = _tableView;
@synthesize facebook = _facebook;
@synthesize currentLocation = _currentLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    TYFBManager *manager = [TYFBManager sharedInstance];
    self.facebook = manager.facebook;
    [self loadNearbyPages];
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
    [cell setPageDistanceWithCoorindate1:page.location andCoordinate2:self.currentLocation];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TYPage *selectedPage = [self.allItems objectAtIndex:indexPath.row];
    TYCheckInConfirmationViewController *confirmationScreen = [[TYCheckInConfirmationViewController alloc] initWithNibName:@"TYCheckInConfirmation" bundle:nil];
    confirmationScreen.currentPage = selectedPage;
    [self.navigationController pushViewController:confirmationScreen animated:YES];
}

#pragma mark - Location

#pragma mark - Facebook

-(void) loadNearbyPages {
    [SVProgressHUD showWithStatus:@"Please wait ..."];
    NSString *fql = @"SELECT page_id, name, description, categories, pic, fan_count, website, checkins, location FROM page WHERE page_id IN (SELECT page_id FROM place WHERE distance(latitude, longitude, \"28.492965\", \"-81.507847\") < 1000)";
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    fql, @"query",
                                    nil];
    [self.facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"Could not load check-ins"];
    // TODO: Add a #if DEBUG condition.
    NSLog(@"%@", error);
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    self.allItems = [[NSMutableArray alloc] init];
    for (NSDictionary *pageDictionary in ((NSArray *) result)) {
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDictionary];
        [self.allItems addObject:page];
    }
    
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
}


@end
