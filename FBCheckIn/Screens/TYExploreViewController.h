//
//  TYExploreViewController.h
//  FBCheckIn
//
//  Created by Teja on 12/31/12.
//
//

#import "TYBaseViewController.h"

@interface TYExploreViewController : TYBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
