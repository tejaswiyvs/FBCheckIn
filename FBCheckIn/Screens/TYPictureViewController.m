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
    __unsafe_unretained TYPictureViewController *weakSelf = self;
    if (self.hiResImageUrl) {
        [self.pictureImgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.hiResImageUrl]] placeholderImage:nil
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [SVProgressHUD dismiss];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)dismissButtonClicked:(id)sender {
    [self dismissScreen];
}

-(void) dismissScreen {
    [self dismissModalViewControllerAnimated:YES];
}
@end
