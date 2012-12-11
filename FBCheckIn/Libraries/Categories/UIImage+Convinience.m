//
//  UIImage+Convinience.m
//  FBCheckIn
//
//  Created by Teja on 11/5/12.
//
//

#import "UIImage+Convinience.h"

@implementation UIImage (Convinience)

+(UIImage *) imageWithColor:(UIColor *) color frame:(CGRect) frame {
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, frame);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
