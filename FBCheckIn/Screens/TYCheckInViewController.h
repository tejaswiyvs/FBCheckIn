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
#import "AFPhotoEditorController.h"
#import "TYFBRequest.h"

@protocol TYTagFriendsDelegate;
@interface TYCheckInViewController : TYBaseViewController<TYFBRequestDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TYTagFriendsDelegate, AFPhotoEditorControllerDelegate>

// UI
@property (nonatomic, strong) IBOutlet UIButton *userImgBtn;
@property (nonatomic, strong) IBOutlet UIImageView *placeImgView;
@property (nonatomic, strong) IBOutlet UILabel *placeName;
@property (nonatomic, strong) IBOutlet UILabel *placeAddress;
@property (nonatomic, strong) IBOutlet UITextView *statusText;
@property (nonatomic, strong) IBOutlet UIButton *tagFriendsBtn;
@property (nonatomic, strong) UIImage *placeImg;
@property (nonatomic, strong) UIImage *checkInImage;
@property (nonatomic, strong) AFPhotoEditorController *aviaryController;

// Data
@property (nonatomic, strong) TYPage *currentPage;
@property (nonatomic, strong) NSMutableArray *taggedUsers;
@property (nonatomic, assign) BOOL txtFieldUp;
@property (nonatomic, assign) BOOL aviaryUsed;

@property (nonatomic, strong) TYFBRequest *postCheckInRequest;
@property (nonatomic, strong) TYFBRequest *postImageRequest;

-(IBAction)checkInButtonClicked:(id)sender;
-(IBAction)tagFriendsButtonClicked:(id)sender;
-(IBAction)imageTapped:(id)sender;
-(IBAction)backgroundTap:(id)sender;
-(void) taggedUsers:(NSArray *) users;
-(void) tagUsersCancelled;
@end
