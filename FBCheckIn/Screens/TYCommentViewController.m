//
//  TYCommentViewController.m
//  FBCheckIn
//
//  Created by Teja on 10/26/12.
//
//

#import "TYCommentViewController.h"
#import "TYUtils.h"
#import "TYComment.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HexString.h"
#import "NSString+Common.h"

@interface TYCommentViewController ()
-(float) heightForComment:(TYComment *) comment;
-(void) doneButtonClicked:(id) sender;
-(void) forceRefresh;
-(void) postComment:(TYComment *) comment;
@end

@implementation TYCommentViewController

static float kDefaultFontSize = 17.0f;
static float kDefaultPadding = 5.0f;

@synthesize checkIn = _checkIn;
@synthesize user = _user;
@synthesize tableView = _tableView;
@synthesize containerView = _containerView;
@synthesize textView = _textView;
@synthesize requests = _requests;

-(id) initWithCheckIn:(TYCheckIn *) checkIn user:(TYUser *) user {
    self = [super initWithNibName:@"TYCommentView" bundle:nil];
    if (self) {
        self.checkIn = checkIn;
        self.user = user;
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
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
    DebugLog(@"CommentView viewDidLoad. Setting up UI.");
    [super viewDidLoad];
    [self.tableView reloadData];
    
    // Create a "Done" button to dismiss the modal view.
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:doneItem];
    [self setTitle:@"Comments"];
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    // HPGrowingTextView Setup
    [self makeTextView];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.checkIn.comments.count == 0) {
        DebugLog(@"No comments for this check-in. Displaying keyboard automatically");
        [self.textView becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *comments = [self.checkIn comments];
    TYComment *comment = [comments objectAtIndex:indexPath.row];
    return [self heightForComment:comment];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.checkIn.comments count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kReuseId = @"comment_cell";
    // TODO: Add code to use dequeueReusableCell
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseId];
    UITableViewCell *cell = nil;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseId];
    }
    
    TYComment *comment = [self.checkIn.comments objectAtIndex:indexPath.row];
    
    // Init variable sized cell
    float height = [self heightForComment:comment];
    CGRect rect = CGRectMake(0.0f, 0.0f, 320.0f, height);
    [cell setFrame:rect];
    
    // Set background
    UIImageView *backgroundImgView = [[UIImageView alloc] initWithFrame:rect];
    [backgroundImgView setImage:[UIImage imageNamed:@"table-cell-bg.png"]];
    [cell addSubview:backgroundImgView];
    
    
    // Configure the UI.
    UIImageView *profilePictureImgView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0f, 8.0f, 57.0f, 57.0f)];
    [profilePictureImgView setImageWithURL:[NSURL URLWithString:comment.user.profilePictureUrl]];
    [profilePictureImgView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [profilePictureImgView.layer setBorderWidth:3.0f];
    [profilePictureImgView.layer setCornerRadius:3.0f];
    [profilePictureImgView.layer setMasksToBounds:YES];
    [cell addSubview:profilePictureImgView];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0f, 8.0f, 226.0f, 21.0f)];
    [nameLabel setText:comment.user.shortName];
    [nameLabel setTextColor:[UIColor headerTextColor]];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:kDefaultFontSize]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:nameLabel];

    float textHeight = [TYUtils heightForText:comment.text withFont:[UIFont systemFontOfSize:kDefaultFontSize] forWidth:226.0f];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0f, 37.0f, 226.0f, textHeight)];
    [textLabel setText:comment.text];
    [textLabel setTextColor:[UIColor subtitleTextColor]];
    [textLabel setFont:[UIFont systemFontOfSize:kDefaultFontSize]];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:textLabel];
    
    return cell;
}

-(float) heightForComment:(TYComment *) comment {
    float textHeight = [TYUtils heightForText:comment.text withFont:[UIFont systemFontOfSize:kDefaultFontSize] forWidth:226.0f];
    return (textHeight < 75.0f) ? 75.0f : (textHeight + 2 * kDefaultPadding);
}

#pragma mark - Event Handlers

-(void) doneButtonClicked:(id) sender {
    DebugLog(@"Dismissed CommentView");
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - TYFBFacadeDelegate

-(void) postComment:(TYComment *) comment {
    DebugLog(@"Posted Comment : %@", comment.text);
    if (!self.requests) {
        self.requests = [NSMutableArray array];
    }
    if (!self.checkIn.comments) {
        self.checkIn.comments = [NSMutableArray array];
    }
    [self.checkIn.comments addObject:comment];
    TYFBFacade *request = [[TYFBFacade alloc] init];
    [self.requests addObject:request];
    [request postComment:comment];
}

-(void) forceRefresh {

}

-(void) fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    DebugLog(@"Comment posted to facebook succesfully");
    [self.requests removeObject:helper];
}

-(void) fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err {
    DebugLog(@"Comment post to facebook failed");
}

#pragma mark - HPTextView

-(void) makeTextView {
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
	self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
	self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
	self.textView.font = [UIFont systemFontOfSize:15.0f];
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor whiteColor];
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:self.containerView];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self.containerView addSubview:imageView];
    [self.containerView addSubview:self.textView];
    [self.containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(self.containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"Post" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[self.containerView addSubview:doneBtn];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

-(void)resignTextView {
	[self.textView resignFirstResponder];
    if (!self.textView.text || [self.textView.text isBlank]) {
        return;
    }
    TYComment *comment = [[TYComment alloc] init];
    comment.user = self.user;
    comment.checkInId = self.checkIn.checkInId;
    comment.text = self.textView.text;
    self.textView.text = @"";
    [self postComment:comment];
    [self forceRefresh];
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
//    containerFrame.origin.y = self.view.bounds.size.height - (166 + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.containerView.frame = r;
}

@end
