//
//  TYPictureViewController.h
//  FBCheckIn
//
//  Created by Teja on 11/9/12.
//
//

#import <UIKit/UIKit.h>
#import "TYBaseViewController.h"

@interface TYPictureViewController : TYBaseViewController

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *hiResImageUrl;
@property (nonatomic, strong) IBOutlet UIImageView *pictureImgView;

-(id) initWithImageUrl:(NSString *) imageUrl hiResUrl:(NSString *) hiResImageUrl;
-(IBAction)dismissButtonClicked:(id)sender;
@end