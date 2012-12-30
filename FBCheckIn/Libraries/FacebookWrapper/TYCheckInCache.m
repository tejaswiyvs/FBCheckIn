//
//  TYCheckInCache.m
//  FBCheckIn
//
//  Created by Teja on 8/7/12.
//
//

#import "TYCheckInCache.h"
#import "TYCheckIn.h"
#import "TYFBRequest.h"
#import "TYSettingsViewController.h"

@interface TYCheckInCache ()
-(NSString *) applicationDocumentsDirectory;
-(BOOL) shouldRefresh;
-(void) loadFromFacebook;
-(void) notifyCacheUpdateStart;
-(void) notifyCacheUpdateComplete;
-(void) loadFromDisk;
-(void) commit;
@end

@implementation TYCheckInCache

@synthesize checkIns = _checkIns;
@synthesize lastRefreshDate = _lastRefreshDate;
@synthesize checkInsRequest = _helper;

static NSString * const kSaveFileName = @"check_in_cache";
static NSString * const kSaveTimeKey = @"check_in_cache_last_updated";

NSString * const kNotificationCacheRefreshStart = @"cache_refresh_started";
NSString * const kNotificationCacheRefreshEnd = @"cache_refresh_ended";

static long const kAutoRefreshInterval = 3600; // >60 minutes since last refresh, we auto pull.

+(TYCheckInCache *) sharedInstance {
    static dispatch_once_t onceToken;
    static TYCheckInCache *cache;
    dispatch_once(&onceToken, ^{
        cache = [[TYCheckInCache alloc] init];
        cache.loading = NO;
        cache.checkIns = [NSMutableArray array];
        [cache loadFromDisk];
    });
    return cache;
}

-(void) forceRefresh {
    DebugLog(@"Force refreshing cache");
    if (!self.loading) {
        [self loadFromFacebook];
    }
}

-(void) clearCache {
    self.checkIns = [NSMutableArray array];
    [[NSFileManager defaultManager] removeItemAtPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:kSaveFileName] error:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSaveTimeKey];
}

-(void) loadFromDisk {
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kSaveFileName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lastRefreshDate = (NSDate *) [defaults objectForKey:kSaveTimeKey];
    self.checkIns = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

-(void) commit {
    // Set last updated time.
    NSDate *now = [[NSDate alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:now forKey:kSaveTimeKey];
    [defaults synchronize];
    
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kSaveFileName];
    [NSKeyedArchiver archiveRootObject:self.checkIns toFile:filePath];
}

#pragma mark - Facebook

-(void) loadFromFacebook {
    [self notifyCacheUpdateStart];
    DebugLog(@"Cache update start Notification Posted.");
    self.loading = YES;
    self.checkInsRequest = [[TYFBRequest alloc] init];
    self.checkInsRequest.delegate = self;
    [self.checkInsRequest checkInsForUser:nil];    
}

-(void)fbHelper:(TYFBRequest *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    DebugLog(@"Cache update did Complete %@", self.checkIns);
    self.checkIns = [self sortedCheckIns:[results objectForKey:@"data"]];
    self.loading = NO;
    [self commit];
    [self notifyCacheUpdateComplete];
}

-(void)fbHelper:(TYFBRequest *)helper didFailWithError:(NSError *)err {
    [self notifyCacheUpdateComplete];
}

#pragma mark - Helpers

-(NSMutableArray *) sortedCheckIns:(NSMutableArray *) checkIns {
    [checkIns sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([((TYCheckIn *) obj1).checkInDate compare:((TYCheckIn *) obj2).checkInDate] == NSOrderedDescending) {
            return NSOrderedAscending;
        }
        else if ([((TYCheckIn *) obj1).checkInDate compare:((TYCheckIn *) obj2).checkInDate] == NSOrderedAscending) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    return checkIns;
}

-(NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(BOOL) shouldRefresh {
    NSDate *now = [[NSDate alloc] init];
    return (!self.lastRefreshDate || [now timeIntervalSinceDate:self.lastRefreshDate] > kAutoRefreshInterval);
}

-(void) notifyCacheUpdateStart {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationCacheRefreshStart object:nil]];
}

-(void) notifyCacheUpdateComplete {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationCacheRefreshEnd object:nil]];
}

@end
