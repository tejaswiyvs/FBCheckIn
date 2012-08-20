//
//  PPCheckInViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "TYAppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface TYPlacePicker : UIViewController<FBRequestDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@property (nonatomic, strong) NSMutableArray *allItems;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end
