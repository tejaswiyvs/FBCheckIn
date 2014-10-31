//
//  TYSettingsViewController.h
//  FBCheckIn
//
//  Created by Teja on 12/21/12.
//
//

#import "TYBaseViewController.h"
#import "TYFBRequest.h"

extern NSString * const kLogoutNotification;

@interface TYSettingsViewController : TYBaseViewController<UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView *aboutTxtView;
@property (nonatomic, strong) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;

-(IBAction)logout:(id)sender;
-(IBAction)supportButtonClicked:(id)sender;
-(IBAction)likeButtonClicked:(id)sender;
-(IBAction)shareButtonClicked:(id)sender;
@end
