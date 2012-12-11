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

@interface TYCheckInViewController ()
-(void) doneButtonClicked:(id) sender;
-(void) updateCheckInImage:(UIImage *) checkInImage;
-(void) postImageToAlbum;
@end

@implementation TYCheckInViewController

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
@synthesize postCheckInRequest = _postCheckInRequest;
@synthesize postImageRequest = _postImageRequest;

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
    
    // Create a done button.
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
    if (self.checkInImage) {
        [self postImageToAlbum];
        return;
    }
    [self checkInWithImage:nil];
}

-(IBAction)tagFriendsButtonClicked:(id)sender {
    TYTagFriendsViewController *tagScreen = [[TYTagFriendsViewController alloc] initWithNibName:@"TYTagFriends" bundle:nil];
    tagScreen.delegate = self;
    tagScreen.taggedUsers = self.taggedUsers;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tagScreen];
    [self presentModalViewController:navController animated:YES];
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
    if (request == self.postImageRequest) {
        NSString *otherId = [(NSDictionary *) result objectForKey:@"id"];
        NSString *pictureUrl = [NSString stringWithFormat:@"http://www.facebook.com/%@", otherId];
        [self checkInWithImage:pictureUrl];
        return;
    }
    else if(request == self.postCheckInRequest) {
        [self dismissModalViewControllerAnimated:YES];
    }
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
    [self.navigationItem setRightBarButtonItem:self.checkInButton];
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
    [self.userImgBtn setImage:image forState:UIControlStateNormal];
    [[self.userImgBtn imageView] setContentMode:UIViewContentModeScaleAspectFill];
}

#pragma mark - Helpers

-(void) updateCheckInImage:(UIImage *) checkInImage {
    if (self.checkInImage) {
        [self.userImgBtn setImage:self.checkInImage forState:UIControlStateNormal];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"add-photo-placeholder.png"];
        [self.userImgBtn setImage:image forState:UIControlStateNormal];
    }
}

-(void) postImageToAlbum {
    if (self.checkInImage) {
        [SVProgressHUD showWithStatus:@"Checking in..."];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:self.checkInImage forKey:@"source"];
        self.postImageRequest = [self.facebook requestWithGraphPath:[NSString stringWithFormat:@"/me/photos"] andParams:params andHttpMethod:@"POST" andDelegate:self];
    }
}

-(void) checkInWithImage:(NSString *) postId {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (self.statusText && ![self.statusText.text isEqualToString:@""]) {
        [params setObject:self.statusText.text forKey:@"message"];
    }
    
    if (self.taggedUsers && [self.taggedUsers count] != 0) {
        NSString *tagsString = @"";
        for (TYUser *user in self.taggedUsers) {
            tagsString = [tagsString stringByAppendingString:user.userId];
            tagsString = [tagsString stringByAppendingString:@","];
        }
        
        // Snip the trailing comma
        if ([tagsString length] > 0) {
            tagsString = [tagsString substringToIndex:([tagsString length] - 1)];
        }
        
        [params setObject:tagsString forKey:@"tags"];
    }
    
    if (self.checkInImage) {
        [params setObject:postId forKey:@"picture"];
    }
    
    [params setObject:self.currentPage.pageId forKey:@"place"];
    NSString *coordinatesString = [NSString stringWithFormat:@"{\"latitude\" : \"%f\", \"longitude\" : \"%f\"}", self.currentPage.location.latitude, self.currentPage.location.longitude];
    [params setObject:coordinatesString forKey:@"coordinates"];
    
    self.postCheckInRequest = [self.facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
    [SVProgressHUD showWithStatus:@"Checking in..."];
}

#pragma mark - Tag User Delegate

-(void) taggedUsers:(NSArray *) users {
    self.taggedUsers = [NSMutableArray arrayWithArray:users];
}

-(void) tagUsersCancelled {
}

@end
