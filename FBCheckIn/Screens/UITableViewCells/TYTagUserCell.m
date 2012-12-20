//
//  TYTagUserCell.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYTagUserCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"

@implementation TYTagUserCell

@synthesize fullName = _fullName;
@synthesize profilePicture = _profilePicture;
@synthesize checkMark = _checkMark;

-(void) awakeFromNib {
    [self.profilePicture.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [self.profilePicture.layer setBorderWidth:3.0f];
    [self.profilePicture.layer setCornerRadius:3.0f];
    [self.profilePicture.layer setMasksToBounds:YES];
    [self.profilePicture setContentMode:UIViewContentModeScaleAspectFill];
}

-(void) setProfilePictureWithURL:(NSString *) imageUrl {
    [self.profilePicture setImageWithURL:[NSURL URLWithString:imageUrl]];
}

@end
