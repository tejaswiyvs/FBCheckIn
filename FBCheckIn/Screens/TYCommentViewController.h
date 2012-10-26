//
//  TYCommentViewController.h
//  FBCheckIn
//
//  Created by Teja on 10/26/12.
//
//

#import <UIKit/UIKit.h>
#import "TYFBFacade.h"
#import "TYCheckIn.h"
#import "TYUser.h"

@interface TYCommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) TYCheckIn *checkIn;
@property (nonatomic, strong) TYUser *user;

-(id) initWithCheckIn:(TYCheckIn *) checkIn user:(TYUser *) user;
@end
