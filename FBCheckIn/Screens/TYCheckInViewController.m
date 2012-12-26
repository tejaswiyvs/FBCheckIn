//
//  TYCheckInConfirmationViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYCheckInViewController.h"
#import "TYTagFriendsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TYFBManager.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>
#import "TYUser.h"
#import "SCNavigationBar.h"
#import "TYCurrentUser.h"
#import "UIColor+HexString.h"
#import "UIBarButtonItem+Convinience.h"
#import "SCNavigationBar.h"

@interface TYCheckInViewController ()
-(void) doneButtonClicked:(id) sender;
-(void) updateCheckInImage:(UIImage *) checkInImage;
-(void) dismiss;
-(void) addPageForPhotoId:(NSString *) photoId;
@end

@implementation TYCheckInViewController

@synthesize placeImg = _placeImg;
@synthesize placeImgView = _placeImgView;
@synthesize userImgBtn = _userImgBtn;
@synthesize placeName = _placeName;
@synthesize placeAddress = _placeAddress;
@synthesize currentPage = _currentPage;
@synthesize taggedUsers = _taggedUsers;
@synthesize statusText = _statusText;
@synthesize txtFieldUp = _txtFieldUp;
@synthesize checkInImage = _checkInImage;
@synthesize aviaryController = _aviaryController;
@synthesize aviaryUsed = _aviaryUsed;
@synthesize postCheckInRequest = _postCheckInRequest;
@synthesize postPhotoRequest = _postPhotoRequest;
@synthesize postTagsRequest = _postTagsRequest;
@synthesize postPageInfoRequest = _postPageInfoRequest;
@synthesize tagFriendsBtn = _tagFriendsBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hide the existing check-in button.
    [(SCNavigationBar *) self.navigationController.navigationBar hideCheckInButton];
    self.view.backgroundColor = [UIColor tintedBlack];
    
    // Create a done button.
    UIBarButtonItem *cancelButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"red-button.png"] target:self action:@selector(cancelButtonClicked:) title:@"Cancel"];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    self.title = @"Check-in";
    
    // Populate values.
    [self.placeImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [self.placeImgView.layer setBorderWidth:3.0f];
    [self.placeImgView.layer setCornerRadius:3.0f];
    [self.placeImgView.layer setMasksToBounds:YES];
    [self.placeImgView setImageWithURL:[NSURL URLWithString:self.currentPage.pagePictureUrl]];
    [self.placeName setText:self.currentPage.pageName];
    [self.placeAddress setText:[self.currentPage shortAddress]];
    [self.statusText.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [self.statusText.layer setBorderWidth:1.0f];
    [self.statusText.layer setCornerRadius:3.0f];
    [self.statusText.layer setMasksToBounds:YES];    
}

-(IBAction)checkInButtonClicked:(id)sender {
    [SVProgressHUD showWithStatus:@"Checking in..."];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    TYUser *currentUser = [TYCurrentUser sharedInstance].user;
    [mixpanel track:@"CheckInCompleted" properties:[NSDictionary dictionaryWithObjectsAndKeys:currentUser.userId, @"userId", currentUser.sex, @"sex", self.currentPage.pageId, @"pageId", [NSNumber numberWithBool:[self hasTags]], "hasTags", [NSNumber numberWithBool:[self hasPicture]], @"hasPhoto", self.aviaryUsed, @"aviaryUsed", nil]];

    if (self.checkInImage) {
        self.postPhotoRequest = [[TYFBFacade alloc] init];
        self.postPhotoRequest.delegate = self;
        [self.postPhotoRequest postPhoto:self.checkInImage withMessage:self.statusText.text];
    }
    else {
        self.postCheckInRequest = [[TYFBFacade alloc] init];
        self.postCheckInRequest.delegate = self;
        [self.postCheckInRequest checkInAtPage:self.currentPage message:self.statusText.text taggedUsers:self.taggedUsers];
    }
}

-(IBAction)tagFriendsButtonClicked:(id)sender {
    TYTagFriendsViewController *tagScreen = [[TYTagFriendsViewController alloc] initWithNibName:@"TYTagFriends" bundle:nil];
    tagScreen.delegate = self;
    tagScreen.taggedUsers = self.taggedUsers;
    UINavigationController *navigationController = [SCNavigationBar customizedNavigationController];
    [navigationController setViewControllers:[NSArray arrayWithObject:tagScreen]];
    [self presentModalViewController:navigationController animated:YES];
}

-(void) cancelButtonClicked:(id) sender {
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark - Text Field Stuff

-(IBAction)backgroundTap:(id)sender {
    [self.statusText resignFirstResponder];
}

-(void) doneButtonClicked:(id) sender {
    [self.statusText resignFirstResponder];
}

#pragma mark - Aviary

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    self.aviaryController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [self.aviaryController setDelegate:self];
    [self presentViewController:self.aviaryController animated:YES completion:nil];
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [self.aviaryController dismissModalViewControllerAnimated:YES];
    self.checkInImage = image;
    self.aviaryUsed = editor.session.modified;
    [self.userImgBtn setImage:self.checkInImage forState:UIControlStateNormal];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self.aviaryController dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIImagePickerControllerDelegate

-(IBAction)imageTapped:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentModalViewController:picker animated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissModalViewControllerAnimated:NO];
    [self displayEditorForImage:image];
}

#pragma mark - Facebook

-(void)fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err {
    if (helper == self.postCheckInRequest) {
        [SVProgressHUD showErrorWithStatus:@"Could not check-in. Please try again."];
    }
    else if (helper == self.postPhotoRequest) {
        [SVProgressHUD showErrorWithStatus:@"Could not check-in. Please try again"];
    }
    else if(helper == self.postTagsRequest) {
        [SVProgressHUD showSuccessWithStatus:@"Checked in, but could not tag your friends with this check-in"];
        if ([self.postPageInfoRequest status] == TYFBFacadeStatusCompleted) {
            [self dismiss];
        }
    }
    else if(helper == self.postPageInfoRequest) {
        [SVProgressHUD showErrorWithStatus:@"Could not check-in. Please try again"];
    }
}

-(void)fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    if (helper == self.postCheckInRequest) {
        [self dismiss];
    }
    else if(helper == self.postPhotoRequest) {
        NSString *photoId = [results objectForKey:@"data"];
        if (self.taggedUsers && [self.taggedUsers count] > 0) {
            [self addTagsForPhotoId:photoId];
        }
        [self addPageForPhotoId:photoId];
    }
    else if(helper == self.postTagsRequest) {
        if (self.postPageInfoRequest.status == TYFBFacadeStatusCompleted) {
            [self dismiss];
        }
    }
    else if(helper == self.postPageInfoRequest) {
        if (self.postTagsRequest && self.postTagsRequest.status == TYFBFacadeStatusCompleted) {
            [self dismiss];
        }
    }
}

-(void) addTagsForPhotoId:(NSString *) photoId {
    self.postTagsRequest = [[TYFBFacade alloc] init];
    self.postTagsRequest.delegate = self;
    [self.postTagsRequest tagUsers:self.taggedUsers forObjectId:photoId];
}

-(void) addPageForPhotoId:(NSString *) photoId {
    self.postPageInfoRequest = [[TYFBFacade alloc] init];
    self.postPageInfoRequest.delegate = self;
    [self.postPageInfoRequest postPage:self.currentPage forObjectId:photoId];
}

#pragma mark - Helpers

-(void) refreshTagUsersButton {
    if ([self hasTags]) {
        [self.tagFriendsBtn setBackgroundImage:[UIImage imageNamed:@"tag_friends_green.png"] forState:UIControlStateNormal];
    }
    else {
        [self.tagFriendsBtn setBackgroundImage:[UIImage imageNamed:@"tag_friends.png"] forState:UIControlStateNormal];
    }
}

-(void) dismiss {
    [SVProgressHUD dismiss];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) updateCheckInImage:(UIImage *) checkInImage {
    if (self.checkInImage) {
        [self.userImgBtn setImage:self.checkInImage forState:UIControlStateNormal];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"add-photo-placeholder.png"];
        [self.userImgBtn setImage:image forState:UIControlStateNormal];
    }
}

#pragma mark - Tag User Delegate

-(void) taggedUsers:(NSArray *) users {
    self.taggedUsers = [NSMutableArray arrayWithArray:users];
    [self refreshTagUsersButton];
}

-(void) tagUsersCancelled {
    [self refreshTagUsersButton];
}

-(BOOL) hasTags {
    return self.taggedUsers && [self.taggedUsers count] > 0;
}

-(BOOL) hasPicture {
    return self.checkInImage != nil;
}

@end
