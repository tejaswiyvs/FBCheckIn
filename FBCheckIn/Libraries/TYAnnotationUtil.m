//
//  TYAnnotationUtil.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYAnnotationUtil.h"

@implementation TYAnnotationUtil

+(UIImage *) pinImageForImage:(UIImage *) picture { 
    UIImage *framedImage = [UIImage imageNamed:@"pin.png"];
    UIGraphicsBeginImageContextWithOptions(framedImage.size, FALSE, 0.0);
    CGPoint point = CGPointMake(5.0, 5.0);
    [framedImage drawInRect:CGRectMake( 0, 0, framedImage.size.width, framedImage.size.height)];
    [picture drawInRect:CGRectMake(point.x, point.y, picture.size.width, picture.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
