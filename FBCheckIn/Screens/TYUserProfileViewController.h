//
//  TYUserProfileViewController.h
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import <UIKit/UIKit.h>
#import "TYUser.h"
#import "TYFBFacade.h"
#import "TYBaseViewController.h"

@interface TYUserProfileViewController : TYBaseViewController<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, TYFBFacadeDelegate>

@property (nonatomic, strong) TYUser *user;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MKMapView *mapView;

// Fetches all the checkIns of a user.
@property (nonatomic, strong) TYFBFacade *userCheckInsRequest;

// Array of TYFBFacades that fetch page data from pageId
@property (nonatomic, strong) NSMutableArray *pageMetaDataRequests;

@property (nonatomic, strong) NSMutableArray *topVisitedPlaces;
@property (nonatomic, strong) NSMutableArray *topVisitedPlacesCount;
@property (nonatomic, strong) NSMutableArray *last3CheckIns;

-(id) initWithUser:(TYUser *) user;
-(void)fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results;
-(void)fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err;
@end
