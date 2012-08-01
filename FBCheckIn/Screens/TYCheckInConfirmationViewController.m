//
//  TYCheckInConfirmationViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYCheckInConfirmationViewController.h"
#import "TYTagFriendsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TYFBManager.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>

@interface TYCheckInConfirmationViewController ()
-(void) doneButtonClicked:(id) sender;
-(void) updateCheckInImage:(UIImage *) checkInImage;
@end

@implementation TYCheckInConfirmationViewController

@synthesize placeImg = _placeImg;
@synthesize placeImgView = _placeImgView;
@synthesize userImgBtn = _userImgBtn;
@synthesize placeName = _placeName;
@synthesize placeAddress = _placeAddress;
@synthesize currentPage = _currentPage;
@synthesize taggedUsers = _taggedUsers;
@synthesize facebook = _facebook;
@synthesize statusText = _statusText;
@synthesize txtFieldUp = _txtFieldUp;
@synthesize checkInButton = _checkInButton;
@synthesize doneButton = _doneButton;
@synthesize checkInImage = _checkInImage;

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
    
    // Create a check-in button.
    self.checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check-in" style:UIBarButtonItemStyleDone target:self action:@selector(checkInButtonClicked:)];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    
    [self.navigationItem setRightBarButtonItem:self.checkInButton];
    
    // Initialize facebook.
    TYFBManager *fbMbr = [TYFBManager sharedInstance];
    self.facebook = fbMbr.facebook;
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(IBAction)checkInButtonClicked:(id)sender {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    if (self.statusText && ![self.statusText.text isEqualToString:@""]) {
        [params setObject:self.statusText.text forKey:@"message"];        
    }
    
    if (self.taggedUsers && [self.taggedUsers count] != 0) {
        
    }
    
    [params setObject:self.currentPage.pageId forKey:@"place"];
    
    NSString *coordinatesString = [NSString stringWithFormat:@"{\"latitude\" : \"%f\", \"longitude\" : \"%f\"}", self.currentPage.location.latitude, self.currentPage.location.longitude];
    [params setObject:coordinatesString forKey:@"coordinates"];
    
    [self.facebook requestWithGraphPath:@"me/checkins" andParams:params andHttpMethod:@"POST" andDelegate:self];
    [SVProgressHUD showWithStatus:@"Checking in..."];
}

-(IBAction)tagFriendsButtonClicked:(id)sender {
    TYTagFriendsViewController *tagScreen = [[TYTagFriendsViewController alloc] initWithNibName:@"TYTagFriends" bundle:nil];
    [self.navigationController pushViewController:tagScreen animated:YES];
}

-(IBAction)imageTapped:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    [picker setDelegate:self];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentModalViewController:picker animated:YES];
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"Couldn't check-in. Please try again"];
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    [SVProgressHUD dismiss]; 
    NSLog(@"%@", result);
}

#pragma mark - Text Field Stuff

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self.navigationItem setRightBarButtonItem:self.doneButton];
    [self animateTextField:textView up:YES];
	self.txtFieldUp = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self animateTextField:textView up:NO];
    self.txtFieldUp = NO;
}

- (void) animateTextField: (UITextView*) textView up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
	
    int movement = (up ? -movementDistance : movementDistance);
	
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void) textViewDoneBtnClicked:(id) sender {

}

-(IBAction)backgroundTap:(id)sender {
    [self.statusText resignFirstResponder];
}

-(void) doneButtonClicked:(id) sender {
    [self.statusText resignFirstResponder];
    [self.navigationItem setRightBarButtonItem:self.checkInButton];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissModalViewControllerAnimated:YES];
    self.checkInImage = image;
    [self.userImgBtn setBackgroundImage:image forState:UIControlStateNormal];
}

#pragma mark - Helpers

-(void) updateCheckInImage:(UIImage *) checkInImage {
    if (self.checkInImage) {
        [self.userImgBtn setBackgroundImage:self.checkInImage forState:UIControlStateNormal];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"add-photo-placeholder.png"];
        [self.userImgBtn setBackgroundImage:image forState:UIControlStateNormal];
    }
}
@end
