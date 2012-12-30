//
//  TYCommentViewController.h
//  FBCheckIn
//
//  Created by Teja on 10/26/12.
//
//

#import <UIKit/UIKit.h>
#import "TYFBRequest.h"
#import "TYCheckIn.h"
#import "TYUser.h"
#import "HPGrowingTextView.h"
#import "TYFBRequest.h"
#import "TYBaseViewController.h"

@interface TYCommentViewController : TYBaseViewController<UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate, TYFBFacadeDelegate>

@property (nonatomic, strong) TYCheckIn *checkIn;
@property (nonatomic, strong) TYUser *user;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) NSMutableArray *requests;

-(void) resignTextView;

-(id) initWithCheckIn:(TYCheckIn *) checkIn user:(TYUser *) user;
@end

@protocol TYCommentViewControllerDelegate
@end
