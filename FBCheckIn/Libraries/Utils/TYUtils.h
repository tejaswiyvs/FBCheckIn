//
//  TYUtils.h
//  FBCheckIn
//
//  Created by Teja on 10/18/12.
//
//  A collection of static helper methods that I commonly seem to need.

#import <Foundation/Foundation.h>

@interface TYUtils : NSObject

+(id) nullSafeObjectFromDictionary:(NSDictionary *) dictionary withKey:(NSString *) key;
+(CGRect) setHeight:(float) height forRect:(CGRect) rect;
+(CGRect) setWidth:(float) width forRect:(CGRect) rect;
+(void) displayAlertWithTitle:(NSString *) title message:(NSString *) message;
+(CGFloat) heightForText:(NSString *) text withFont:(UIFont *) font forWidth:(float) width;
@end
