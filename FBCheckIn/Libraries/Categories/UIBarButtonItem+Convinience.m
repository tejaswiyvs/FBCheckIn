//
//  UIBarButtonItem+Convinience.m
//  FBCheckIn
//
//  Created by Teja on 12/15/12.
//
//

#import "UIBarButtonItem+Convinience.h"

@implementation UIBarButtonItem (Convinience)

+(UIBarButtonItem*) barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action title:(NSString *) title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
    [v addSubview:button];
    return [[UIBarButtonItem alloc] initWithCustomView:v];
}

@end
