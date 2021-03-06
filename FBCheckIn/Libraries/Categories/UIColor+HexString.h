//
//  UIColor+Convinience.h
//  Medikiosk
//
//  Created by Tejaswi Y on 3/3/12.
//  Copyright (c) 2012 Patient Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)
+(UIColor *) colorWithHexString: (NSString *) hexString;
+(UIColor *) headerTextColor;
+(UIColor *) subtitleTextColor;
+(UIColor *) bgColor;
+(UIColor *) dullWhite;
+(UIColor *) dullRed;
+(UIColor *) tintedBlack;
+(UIColor *) tabBarTintColor;
@end
