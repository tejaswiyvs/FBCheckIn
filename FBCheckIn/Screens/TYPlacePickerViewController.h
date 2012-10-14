//
//  PPCheckInViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "TYFBFacade.h"
#import "EGORefreshTableHeaderView.h"

@interface TYPlacePickerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, TYFBFacadeDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, strong) TYFBFacade *facade;
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSMutableArray *allItems;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end
