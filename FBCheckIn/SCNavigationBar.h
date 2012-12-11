//
//  SCNavigationBar.h
//  ExampleNavBarBackground
//
//  Created by Sebastian Celis on 3/1/2012.
//  Copyright 2012-2012 Sebastian Celis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCNavigationBar : UINavigationBar

@property (nonatomic, strong) UIButton *checkInButton;

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics;
+(UINavigationController *)customizedNavigationController;
-(void) checkInButtonClicked:(id) sender;
-(void) hideCheckInButton;
@end
