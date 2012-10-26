//
//  TYUtils.m
//  FBCheckIn
//
//  Created by Teja on 10/18/12.
//

#import "TYUtils.h"

//Constants
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

@interface TYUtils ()
@end

@implementation TYUtils

+(CGRect) setHeight:(float) height forRect:(CGRect) rect {
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height);
}

+(CGRect) setWidth:(float) width forRect:(CGRect) rect {
    return CGRectMake(rect.origin.x, rect.origin.y, width, rect.size.height);
}

+(void) displayAlertWithTitle:(NSString *) title message:(NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
