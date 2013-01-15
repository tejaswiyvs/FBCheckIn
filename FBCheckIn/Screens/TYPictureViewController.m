//
//  TYPictureViewController.m
//  FBCheckIn
//
//  Created by Teja on 11/9/12.
//
//

#import "TYPictureViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TYUtils.h"
#import "SVProgressHUD.h"

@interface TYPictureViewController ()
-(void) dismissScreen;
@end

@implementation TYPictureViewController

@synthesize imageUrl = _imageUrl;
@synthesize hiResImageUrl = _hiResImageUrl;

-(id) initWithImageUrl:(NSString *) imageUrl hiResUrl:(NSString *) hiResImageUrl {
    self = [super initWithNibName:@"TYPictureView" bundle:nil];
    if (self) {
        self.imageUrl = imageUrl;
        self.hiResImageUrl = hiResImageUrl;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SVProgressHUD show];
    [self hideDoneButton];
    __unsafe_unretained TYPictureViewController *weakSelf = self;
    if (self.hiResImageUrl) {
        [self.pictureImgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.hiResImageUrl]] placeholderImage:nil
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [SVProgressHUD dismiss];
                [weakSelf scheduleTimer];
            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [SVProgressHUD dismiss];
                [weakSelf dismissScreen];
            }
         ];
    }
    else if (self.imageUrl) {
        [self.pictureImgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.imageUrl]] placeholderImage:nil
          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
              [SVProgressHUD dismiss];
              [weakSelf scheduleTimer];
          }
          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
              [SVProgressHUD dismiss];
              [weakSelf dismissScreen];
          }
        ];
    }
    else {
        [TYUtils displayAlertWithTitle:@"Oops!" message:@"Something went wrong while loading this picture. Please try again"];
        [self dismissScreen];
    }
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    recognizer.numberOfTapsRequired = 1;
    recognizer.numberOfTouchesRequired = 1;
    [self.pictureImgView setUserInteractionEnabled:YES];
    [self.pictureImgView addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) scheduleTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerExpired:) userInfo:nil repeats:NO];
}

-(void) timerExpired:(id) sender {
    [self presentDoneButton];
}

-(IBAction)dismissButtonClicked:(id)sender {
    [self dismissScreen];
}

-(void) dismissScreen {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) backgroundTapped:(UITapGestureRecognizer *) recognizer {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    [self presentDoneButton];
}

-(void) presentDoneButton {
    [self.dismissItem setEnabled:YES];
    [UIView animateWithDuration:0.5f animations:^{
        [self.dismissItem setAlpha:0.8f];
    }];
}

-(void) hideDoneButton {
    [self.dismissItem setAlpha:0.0f];
    [self.dismissItem setEnabled:NO];
}
@end
