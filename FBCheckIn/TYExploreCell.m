//
//  TYExploreCell.m
//  FBCheckIn
//
//  Created by Teja on 1/1/13.
//
//

#import "TYExploreCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TYExploreCell

@synthesize coverImg = _coverImg;
@synthesize pageNameLbl = _pageNameLbl;
@synthesize pageCategoriesLbl = _pageCategoriesLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
