//
//  TYExploreDetailViewController.h
//  FBCheckIn
//
//  Created by Teja on 12/31/12.
//
//

#import "TYBaseViewController.h"
#import "TYFBRequest.h"

@interface TYExploreDetailViewController : TYBaseViewController<TYFBRequestDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *filter;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) TYFBRequest *request;
@property (nonatomic, strong) TYFBRequest *pageDataRequest;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

-(id) initWithFilter:(NSString *) filter;

@end
