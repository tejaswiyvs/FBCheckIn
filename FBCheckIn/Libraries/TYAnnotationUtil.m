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
    picture = [TYAnnotationUtil resizeImage:picture newSize:CGSizeMake(18,17)];
    UIGraphicsBeginImageContextWithOptions(framedImage.size, FALSE, 0.0);
    CGPoint point = CGPointMake(7, 8);
    [framedImage drawInRect:CGRectMake(0, 0, framedImage.size.width, framedImage.size.height)];
    [picture drawInRect:CGRectMake(point.x, point.y, picture.size.width, picture.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
