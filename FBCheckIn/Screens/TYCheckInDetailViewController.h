//
//  TYCheckInDetailViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYCheckIn.h"
#import "HPGrowingTextView.h"

@interface TYCheckInDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate>

@property (nonatomic, strong) TYCheckIn *checkIn;
@property (nonatomic, strong) IBOutlet UIImageView *pagePictureView;
@property (nonatomic, strong) IBOutlet UILabel *pageNameLbl;
@property (nonatomic, strong) IBOutlet UILabel *pageAddressLbl;
@property (nonatomic, strong) IBOutlet UILabel *userNameLbl;
@property (nonatomic, strong) IBOutlet UITextView *statusTextView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) HPGrowingTextView *textView;

-(void)resignTextView;

-(IBAction)likeButtonClicked:(id)sender;
-(IBAction)commentButtonClicked:(id)sender;
@end
