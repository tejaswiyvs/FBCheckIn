//
//  TYCommentViewController.m
//  FBCheckIn
//
//  Created by Teja on 10/26/12.
//
//

#import "TYCommentViewController.h"

@interface TYCommentViewController ()

@end

@implementation TYCommentViewController

@synthesize checkIn = _checkIn;
@synthesize user = _user;

-(id) initWithCheckIn:(TYCheckIn *) checkIn user:(TYUser *) user {
    self = [super initWithNibName:@"TYCommentView" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
