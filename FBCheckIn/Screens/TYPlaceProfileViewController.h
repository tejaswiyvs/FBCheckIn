//
//  TYPlaceProfileViewController.h
//  FBCheckIn
//
//  Created by Teja on 10/14/12.
//
//

#import <UIKit/UIKit.h>
#import "TYPage.h"
#import <MapKit/MapKit.h>
#import "TYFBFacade.h"
#import "TYBaseViewController.h"

@interface TYPlaceProfileViewController : TYBaseViewController<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIAlertViewDelegate, TYFBFacadeDelegate>

@property (nonatomic, strong) TYPage *place;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TYFBFacade *metaDataRequest;

-(void)fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results;
-(void)fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err;

-(id) initWithPlace:(TYPage *) place;
@end
