//
//  TYExploreViewController.m
//  FBCheckIn
//
//  Created by Teja on 12/31/12.
//
//

#import "TYExploreViewController.h"
#import "TYExploreDetailViewController.h"
#import "UIColor+HexString.h"
#import "Constants.h"

// A private temp class to hold the current controller's model objects.
@interface TYExploreTblModel : NSObject
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryImg;
-(id) initWithCategoryName:(NSString *) name imageName:(NSString *) imageName;
@end

@implementation TYExploreTblModel

@synthesize categoryName, categoryImg;

-(id) initWithCategoryName:(NSString *) name imageName:(NSString *) imageName {
    self = [super init];
    if (self) {
        self.categoryName = name;
        self.categoryImg = imageName;
    }
    return self;
}

@end

// Default Impl
@interface TYExploreViewController ()
@end

@implementation TYExploreViewController

const int kNumberOfCategories = 7;

@synthesize tableView = _tableView;
@synthesize categories = _categories;

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
    self.view.backgroundColor = [UIColor bgColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    [self setupCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfCategories;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kReuseId = @"exploreCategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseId];
    }
    cell.backgroundColor = [UIColor dullWhite];
    TYExploreTblModel *model = [self.categories objectAtIndex:indexPath.row];
    [cell.textLabel setText:model.categoryName];
    [cell.imageView setImage:[UIImage imageNamed:model.categoryImg]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYExploreTblModel *category = [self.categories objectAtIndex:indexPath.row];
    TYExploreDetailViewController *exploreDetail = [[TYExploreDetailViewController alloc] initWithFilter:category.categoryName];
    [self.navigationController pushViewController:exploreDetail animated:YES];
}

#pragma mark - Helpers

-(NSString *) categoriesTxt {
    if (!self.categories || self.categories.count == 0) {
        return @"";
    }
    NSString *categoriesTxt = @"";
    for (NSString *categoryName in self.categories) {
        categoriesTxt = [categoriesTxt stringByAppendingFormat:@"%@,", categoryName];
    }
    if ([categoriesTxt length] > 0) {
        categoriesTxt = [categoriesTxt substringToIndex:(categoriesTxt.length - 1)];
    }
    return categoriesTxt;
}

-(void) setupCategories {
    TYExploreTblModel *model1 = [[TYExploreTblModel alloc] initWithCategoryName:kTopPicksFilter imageName:@""];
    TYExploreTblModel *model2 = [[TYExploreTblModel alloc] initWithCategoryName:kFoodFilter imageName:@""];
    TYExploreTblModel *model3 = [[TYExploreTblModel alloc] initWithCategoryName:kCoffeeFilter imageName:@""];
    TYExploreTblModel *model4 = [[TYExploreTblModel alloc] initWithCategoryName:kNightLifeFilter imageName:@""];
    TYExploreTblModel *model5 = [[TYExploreTblModel alloc] initWithCategoryName:kArtsFilter imageName:@""];
    TYExploreTblModel *model6 = [[TYExploreTblModel alloc] initWithCategoryName:kShoppingFilter imageName:@""];
    TYExploreTblModel *model7 = [[TYExploreTblModel alloc] initWithCategoryName:kSightsFilter imageName:@""];
//    TYExploreTblModel *model8 = [[TYExploreTblModel alloc] initWithCategoryName:kFriendsBeenToFilter imageName:@""];
    self.categories = [NSMutableArray arrayWithObjects:model1, model2, model3, model4, model5, model6, model7, nil];
}
@end
