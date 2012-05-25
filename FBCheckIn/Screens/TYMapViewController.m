//
//  TYMapViewController.m
//  FBCheckIn
//
//  Created by Tejaswi Y on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TYMapViewController.h"

@interface TYMapViewController ()

@end

@implementation TYMapViewController

-(id) initWithTabBar {
    self = [super initWithNibName:@"TYMapViewController" bundle:nil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"map.png"];
        self.tabBarItem.title = @"Map";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
