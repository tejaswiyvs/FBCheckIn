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
@synthesize checkInsRequest = _checkInsRequest;
@synthesize checkInsRequest2 = _checkInsRequest2;

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
    if (!self.checkIns || [self.checkIns count] == 0) {
        [self.checkInsRequest checkInsForUser:nil since:nil];
    }
    else {
        [self.checkInsRequest checkInsForUser:nil since:self.lastRefreshDate];
    }
}

-(void)fbHelper:(TYFBRequest *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    DebugLog(@"Cache update did Complete %@", self.checkIns);
    NSArray *updatedCheckIns = [self sortedCheckIns:[results objectForKey:@"data"]];
    @synchronized(self.checkIns) {
        self.checkIns = [self checkInsByAppendingResults:updatedCheckIns toCheckIns:self.checkIns];
    }
    self.loading = NO;
    [self commit];
    [self notifyCacheUpdateComplete];
    if (helper == self.checkInsRequest) {
        [self refreshInBg];
    }
}

-(void)fbHelper:(TYFBRequest *)helper didFailWithError:(NSError *)err {
    self.loading = NO;
    [self notifyCacheUpdateComplete];
}

#pragma mark - Helpers

-(void) refreshInBg {
    // Been more than a minute? Go refresh the whole thing also. But in the background.
//    long now = [NSDate timeIntervalSinceReferenceDate];
//    long lastRefreshDate = [self.lastRefreshDate timeIntervalSinceReferenceDate];
//    if ((now - lastRefreshDate) > 6) {
        self.checkInsRequest2 = [[TYFBRequest alloc] init];
        self.checkInsRequest2.delegate = self;
        [self.checkInsRequest2 checkInsForUser:nil since:nil];
//    }
}

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

-(NSMutableArray *) checkInsByAppendingResults:(NSArray *) results toCheckIns:(NSMutableArray *) checkIns {
    if (!checkIns) {
        checkIns = [NSMutableArray array];
    }
    
    NSMutableArray *checkInsCopy = [checkIns mutableCopy];
    
    // Remove any duplicate checkins
    NSMutableArray *objectsToBeRemoved = [NSMutableArray array];
    for (TYCheckIn *checkIn in results) {
        for (TYCheckIn *checkIn2 in checkInsCopy) {
            if ([checkIn.checkInId isEqualToString:checkIn2.checkInId]) {
                [objectsToBeRemoved addObject:checkIn2];
            }
        }
    }
    [checkInsCopy removeObjectsInArray:objectsToBeRemoved];
    
    NSMutableArray *tempArr = [NSMutableArray array];
    [tempArr addObjectsFromArray:results];
    [tempArr addObjectsFromArray:checkIns];
    
    // If length of the check-in array is > 50, we remove the oldest check-ins.
    if (tempArr.count > 50) {
        tempArr = [[tempArr subarrayWithRange:NSMakeRange(0, 50)] mutableCopy];
    }

    return tempArr;
}

@end
