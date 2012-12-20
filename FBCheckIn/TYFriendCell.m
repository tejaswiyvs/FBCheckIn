//
//  TYFriendCell.m
//  FBCheckIn
//
//  Created by Teja on 12/17/12.
//
//

#import "TYFriendCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TYFriendCell

@synthesize profilePictureImg = _profilePictureImg;
@synthesize userNameLbl = _userNameLbl;

-(void) awakeFromNib {
    [self.profilePictureImg.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [self.profilePictureImg.layer setBorderWidth:3.0f];
    [self.profilePictureImg.layer setCornerRadius:3.0f];
    [self.profilePictureImg.layer setMasksToBounds:YES];
    [self.profilePictureImg setContentMode:UIViewContentModeScaleAspectFill];
}

@end
