//
//  UIColor+Convinience.m
//  Medikiosk
//
//  Created by Tejaswi Y on 3/3/12.
//  Derived From Micah's answer on Stackoverflow: http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string

#import "UIColor+HexString.h"

@interface UIColor()

#define DEFAULT_VOID_COLOR  [UIColor whiteColor]

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end

@implementation UIColor(HexString)

+(UIColor *) dullRed {
    return [UIColor colorWithHexString:@"E95147"];
}

+(UIColor *) tintedBlack {
    return [UIColor colorWithHexString:@"1E1C1B"];
}

+(UIColor *) bgColor {
    return [UIColor colorWithHexString:@"EAE5E1"];
}

+(UIColor *) tabBarTintColor {
    return [UIColor colorWithHexString:@"BBBBBB"];
}

+(UIColor *) dullWhite {
    return [UIColor colorWithHexString:@"F6F3F2"];
}

+(UIColor *) headerTextColor {
    return [UIColor colorWithHexString:@"3B3432"];
}

+(UIColor *) subtitleTextColor {
//    return [UIColor colorWithRed:(127.0f/255.0f) green:(127.0f/255.0f) blue:(127.0f/255.0f) alpha:1.0f];
    return [UIColor colorWithHexString:@"736560"];
}

+(UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	// String should be 6 or 8 characters
	if ([cString length] < 6) return DEFAULT_VOID_COLOR;
	
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	
	if ([cString length] != 6) return DEFAULT_VOID_COLOR;
    
	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];

	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}

@end
