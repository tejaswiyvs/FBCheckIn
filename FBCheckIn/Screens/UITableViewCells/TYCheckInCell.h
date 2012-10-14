//
//  PPCheckInCell.h
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

@interface TYCheckInCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *checkInLocation;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UIImageView *picture;
@property (nonatomic, strong) IBOutlet UILabel *address;
@property (nonatomic, strong) IBOutlet UILabel *timestamp;
@property (nonatomic, strong) IBOutlet UILabel *commentCountLbl;
@property (nonatomic, strong) IBOutlet UILabel *likeCountLbl;
@property (nonatomic, strong) IBOutlet UIImageView *likeImgView;
@property (nonatomic, strong) IBOutlet UIImageView *commentImgView;

-(void) setTime:(NSDate *) checkInTime;

@end
