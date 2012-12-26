//
//  TYFriendCache.m
//  FBCheckIn
//
//  Created by Teja on 12/19/12.
//
//

#import "TYFriendCache.h"
#import "TYCurrentUser.h"

@implementation TYFriendCache

static NSString * const kSaveFileName = @"friend_cache";
static NSString * const kSaveTimeKey = @"friend_cache_last_updated";

NSString * const kFriendCacheUpdateComplete = @"friendCacheUpdateComplete";
NSString * const kFriendCacheUpdateFailed = @"friendCacheUpdateFailed";

@synthesize friends = _friends;
@synthesize lastUpdated = _lastUpdated;
@synthesize facade = _facade;
@synthesize refreshing = _refreshing;
@synthesize lastRefreshDate = _lastRefreshDate;

static long const kAutoRefreshInterval = 12 * 3600; // >60 minutes since last refresh, we auto pull.

+(TYFriendCache *) sharedInstance {
    static dispatch_once_t onceToken;
    static TYFriendCache *cache;
    dispatch_once(&onceToken, ^{
        cache = [[TYFriendCache alloc] init];
        cache.refreshing = NO;
    });
    return cache;
}

-(NSMutableArray *) cachedFriends {
    if ([self shouldRefresh]) {
        [self forceRefresh];
    }
    return self.friends;
}

-(void) forceRefresh {
    if (!self.refreshing) {
        self.refreshing = YES;
        self.facade = [[TYFBFacade alloc] init];
        self.facade.delegate = self;
        TYCurrentUser *user = [TYCurrentUser sharedInstance];
        [self.facade friendsForUser:user.user];
    }    
}

-(void) clearCache {
    self.friends = [NSMutableArray array];
    [[NSFileManager defaultManager] removeItemAtPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:kSaveFileName] error:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSaveTimeKey];
}

-(BOOL) shouldRefresh {
    NSDate *now = [[NSDate alloc] init];
    return (!self.lastRefreshDate || [now timeIntervalSinceDate:self.lastRefreshDate] > kAutoRefreshInterval);
}

-(BOOL) isEmpty {
    return (!self.friends || [self.friends count] == 0);
}

-(void)fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kFriendCacheUpdateFailed object:nil]];
}

-(void)fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    self.friends = [results objectForKey:@"data"];
    [self.friends sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TYUser *user1 = (TYUser *) obj1;
        TYUser *user2 = (TYUser *) obj2;
        return ([user1.firstName compare:user2.firstName]);
    }];
    [self commit];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kFriendCacheUpdateComplete object:nil]];
}

-(void) loadFromDisk {
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kSaveFileName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lastRefreshDate = (NSDate *) [defaults objectForKey:kSaveTimeKey];
    self.friends = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

-(void) commit {
    // Set last updated time.
    NSDate *now = [[NSDate alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:now forKey:kSaveTimeKey];
    [defaults synchronize];
    
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kSaveFileName];
    [NSKeyedArchiver archiveRootObject:self.friends toFile:filePath];
}

-(NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
