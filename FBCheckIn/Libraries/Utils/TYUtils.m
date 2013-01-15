//
//  TYUtils.m
//  FBCheckIn
//
//  Created by Teja on 10/18/12.
//

#import "TYUtils.h"
#import "NSString+Common.h"

//Constants
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

@interface TYUtils ()
@end

@implementation TYUtils

+(id) nullSafeObjectFromDictionary:(NSDictionary *) dictionary withKey:(NSString *) key {
    id value = [dictionary objectForKey:key];
    if ([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return value;
}

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

+(CGFloat) heightForText:(NSString *) text withFont:(UIFont *) font forWidth:(float) width {
    if (!text || [text isBlank]) {
        return 0.0f;
    }
    CGSize size = [text sizeWithFont:font forWidth:width lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
}

@end
