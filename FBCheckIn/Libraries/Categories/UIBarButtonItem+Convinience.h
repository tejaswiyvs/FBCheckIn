//
//  UIBarButtonItem+Convinience.h
//  FBCheckIn
//
//  Created by Teja on 12/15/12.
//
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Convinience)

+(UIBarButtonItem*) barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action title:(NSString *) title;

@end
