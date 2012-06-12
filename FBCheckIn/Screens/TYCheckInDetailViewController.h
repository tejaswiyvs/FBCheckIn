//
//  TYCheckInDetailViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYCheckIn.h"

@interface TYCheckInDetailViewController : UIViewController

@property (nonatomic, strong) TYCheckIn *checkIn;
@property (nonatomic, strong) IBOutlet UIImageView *pagePictureView;
@property (nonatomic, strong) IBOutlet UILabel *pageNameLbl;
@property (nonatomic, strong) IBOutlet UILabel *pageAddressLbl;
@property (nonatomic, strong) IBOutlet UITextView *pageDescriptionTxtView;

@property (nonatomic, strong) IBOutlet UILabel *userNameLbl;
@end
