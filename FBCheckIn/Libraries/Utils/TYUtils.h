//
//  TYUtils.h
//  FBCheckIn
//
//  Created by Teja on 10/18/12.
//
//  A collection of static helper methods that I commonly seem to need.

#import <Foundation/Foundation.h>

@interface TYUtils : NSObject

+(CGRect) setHeight:(float) height forRect:(CGRect) rect;
+(CGRect) setWidth:(float) width forRect:(CGRect) rect;
+(void) displayAlertWithTitle:(NSString *) title message:(NSString *) message;
@end
