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
#import "TYTagFriendsViewController.h"
#import "TYBaseViewController.h"

@protocol TYTagFriendsDelegate;
@interface TYCheckInViewController : TYBaseViewController<FBRequestDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TYTagFriendsDelegate>

@property (nonatomic, strong) IBOutlet UIButton *userImgBtn;
@property (nonatomic, strong) IBOutlet UIImageView *placeImgView;
@property (nonatomic, strong) IBOutlet UILabel *placeName;
@property (nonatomic, strong) IBOutlet UILabel *placeAddress;
@property (nonatomic, strong) IBOutlet UITextView *statusText;
@property (nonatomic, strong) UIBarButtonItem *checkInButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIImage *placeImg;
@property (nonatomic, strong) UIImage *checkInImage;
@property (nonatomic, strong) TYPage *currentPage;
@property (nonatomic, strong) NSMutableArray *taggedUsers;
@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, strong) FBRequest *postCheckInRequest;
@property (nonatomic, strong) FBRequest *postImageRequest;
@property (nonatomic, assign) BOOL txtFieldUp;

-(IBAction)checkInButtonClicked:(id)sender;
-(IBAction)tagFriendsButtonClicked:(id)sender;
-(IBAction)imageTapped:(id)sender;
-(IBAction)backgroundTap:(id)sender;
-(void) textViewDoneBtnClicked:(id) sender;
-(void) taggedUsers:(NSArray *) users;
-(void) tagUsersCancelled;
@end
