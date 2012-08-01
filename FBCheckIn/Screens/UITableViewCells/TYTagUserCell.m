//
//  TYTagUserCell.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYTagUserCell.h"

@implementation TYTagUserCell

@synthesize fullName = _fullName;
@synthesize profilePicture = _profilePicture;
@synthesize checkMark = _checkMark;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
