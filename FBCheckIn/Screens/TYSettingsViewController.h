//
//  TYSettingsViewController.h
//  FBCheckIn
//
//  Created by Teja on 12/21/12.
//
//

#import "TYBaseViewController.h"

extern NSString * const kLogoutNotification;

@interface TYSettingsViewController : TYBaseViewController

@property (nonatomic, strong) IBOutlet UITextView *aboutTxtView;

-(IBAction)logout:(id)sender;
-(IBAction)supportButtonClicked:(id)sender;
@end
