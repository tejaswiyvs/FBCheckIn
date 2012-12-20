//
//  TYTagUserCell.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYTagUserCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *fullName;
@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UIImageView *checkMark;

-(void) setProfilePictureWithURL:(NSString *) imageUrl;
@end
