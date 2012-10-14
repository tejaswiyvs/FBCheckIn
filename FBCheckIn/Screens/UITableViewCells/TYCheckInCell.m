//
//  PPCheckInCell.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYCheckInCell.h"

@implementation TYCheckInCell

@synthesize picture = _picture;
@synthesize name = _name;
@synthesize checkInLocation = _checkInLocation;
@synthesize timestamp = _timestamp;
@synthesize address = _address;
@synthesize commentCountLbl = _checkInCountLbl;
@synthesize likeCountLbl = _likeCountLbl;
@synthesize likeImgView = _likeImgView;
@synthesize commentImgView = _commentImgView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void) setTime:(NSDate *) checkInTime {
    if (checkInTime) {
        [self.timestamp setText:[self timeIntervalWithStartDate:checkInTime withEndDate:[[NSDate alloc] init]]];        
    }
    else {
        [self.timestamp setText:@"Unknown time"];
    }
}

//Constants
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

- (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2
{
    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [d2 timeIntervalSinceDate:d1];
    
    if (delta < 1 * MINUTE)
    {
        return delta == 1 ? @"one second ago" : [NSString stringWithFormat:@"%d seconds ago", (int)delta];
    }
    if (delta < 2 * MINUTE)
    {
        return @"a minute ago";
    }
    if (delta < 45 * MINUTE)
    {
        int minutes = floor((double)delta/MINUTE);
        return [NSString stringWithFormat:@"over %d minutes ago", minutes];
    }
    if (delta < 90 * MINUTE)
    {
        return @"an hour ago";
    }
    if (delta < 24 * HOUR)
    {
        int hours = floor((double)delta/HOUR);
        return [NSString stringWithFormat:@"over %d hours ago", hours];
    }
    if (delta < 48 * HOUR)
    {
        return @"yesterday";
    }
    if (delta < 30 * DAY)
    {
        int days = floor((double)delta/DAY);
        return [NSString stringWithFormat:@"over %d days ago", days];
    }
    if (delta < 12 * MONTH)
    {
        int months = floor((double)delta/MONTH);
        return months <= 1 ? @"over a month ago" : [NSString stringWithFormat:@"over %d months ago", months];
    }
    else
    {
        int years = floor((double)delta/MONTH/12.0);
        return years <= 1 ? @"over a year ago" : [NSString stringWithFormat:@"over %d years ago", years];
    }
}
@end
