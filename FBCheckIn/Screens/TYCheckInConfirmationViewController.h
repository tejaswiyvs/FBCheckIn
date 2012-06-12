//
//  TYCheckInConfirmationViewController.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYPage.h"
#import "Facebook.h"

@interface TYCheckInConfirmationViewController : UIViewController<FBRequestDelegate, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *userImgBtn;
@property (nonatomic, strong) IBOutlet UIImageView *placeImgView;
@property (nonatomic, strong) IBOutlet UILabel *placeName;
@property (nonatomic, strong) IBOutlet UILabel *placeAddress;
@property (nonatomic, strong) IBOutlet UITextView *statusText;
@property (nonatomic, strong) UIBarButtonItem *checkInButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIImage *placeImg;
@property (nonatomic, strong) TYPage *currentPage;
@property (nonatomic, strong) NSMutableArray *taggedUsers;
@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, assign) BOOL txtFieldUp;

-(IBAction)checkInButtonClicked:(id)sender;
-(IBAction)tagFriendsButtonClicked:(id)sender;
-(IBAction)imageTapped:(id)sender;
-(IBAction)backgroundTap:(id)sender;
-(void) textViewDoneBtnClicked:(id) sender;
@end
