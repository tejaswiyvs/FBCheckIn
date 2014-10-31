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
#import "TYCurrentUser.h"
#import "UIColor+HexString.h"
#import "UIBarButtonItem+Convinience.h"
#import "SCNavigationBar.h"
#import "TYCheckInCache.h"

@interface TYCheckInViewController ()
-(void) doneButtonClicked:(id) sender;
-(void) updateCheckInImage:(UIImage *) checkInImage;
-(void) dismiss;
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
@synthesize postImageRequest = _postImageRequest;
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
    NSString *hasPic = @"";
    if ([self hasPicture]) {
        hasPic = @"yes";
    }
    else {
        hasPic = @"no";
    }
    NSString *hasTags = @"";
    if ([self hasTags]) {
        hasTags = @"yes";
    }
    else {
        hasTags = @"no";
    }
    NSString *aviaryUsed = @"";
    if (self.aviaryUsed) {
        aviaryUsed= @"yes";
    }
    else {
        aviaryUsed = @"no";
    }
    [mixpanel track:@"CheckInCompleted" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    currentUser.userId, @"userId",
                                                    currentUser.sex, @"sex",
                                                    self.currentPage.pageId, @"pageId",
                                                    [NSString stringWithFormat:@"%d", [self hasPicture]], @"hasPhoto",
                                                    [NSString stringWithFormat:@"%d", [self hasTags]], @"hasTags",
                                                    [NSString stringWithFormat:@"%d", self.aviaryUsed], @"aviaryUsed",
                                                    nil]];
    if ([self hasPicture]) {
        [self checkInWithPhoto];
    }
    else {
        [self checkInWithoutPhoto];
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
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum | UIImagePickerControllerSourceTypePhotoLibrary;
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

-(void) checkInWithPhoto {
    self.postCheckInRequest = [[TYFBRequest alloc] init];
    self.postCheckInRequest.delegate = self;
    [self.postCheckInRequest checkInAtPage:self.currentPage message:self.statusText.text taggedUsers:self.taggedUsers withPhoto:self.checkInImage];
}

-(void) checkInWithoutPhoto {
    self.postCheckInRequest = [[TYFBRequest alloc] init];
    self.postCheckInRequest.delegate = self;
    [self.postCheckInRequest checkInAtPage:self.currentPage message:self.statusText.text taggedUsers:self.taggedUsers];
}

-(void)fbHelper:(TYFBRequest *)helper didFailWithError:(NSError *)err {
    [SVProgressHUD showErrorWithStatus:@"Could not check-in. Please try again."];
}

-(void)fbHelper:(TYFBRequest *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    NSString *checkInId = [results objectForKey:@"data"];
    TYCheckIn *checkIn = [[TYCheckIn alloc] init];
    checkIn.checkInId = checkInId;
    checkIn.page = self.currentPage;
    checkIn.user = [TYCurrentUser sharedInstance].user;
    checkIn.checkInDate = [[NSDate alloc] init];
    if ([self hasPicture]) {
        TYPhoto *photo = [[TYPhoto alloc] init];
        photo.objectId = @"";
        photo.src = @"http://www.facebook.com";
        checkIn.type = @"photo";
    }
    if ([self hasTags]) {
        checkIn.taggedUsers = self.taggedUsers;
    }

    // Add object to cache directly. We'll refresh this from the server later.
    [[TYCheckInCache sharedInstance] addCheckInToCache:checkIn];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkedIn" object:nil];
    [self dismiss];
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
