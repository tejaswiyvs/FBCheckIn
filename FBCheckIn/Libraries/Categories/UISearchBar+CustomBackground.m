//
//  UISearchBar+CustomBackground.m
//  FBCheckIn
//
//  Created by Teja on 8/10/12.
//  Credits to : http://forrst.com/posts/Customize_a_UISearchBar_background-7UD

#import "UISearchBar+CustomBackground.h"

@implementation UISearchBar (CustomBackground)

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIImage *searchBarBg = [UIImage imageNamed:@"search-bar-bg.png"];
    CGContextTranslateCTM(ctx, 0, searchBarBg.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextDrawTiledImage(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), searchBarBg.CGImage);
}
@end
