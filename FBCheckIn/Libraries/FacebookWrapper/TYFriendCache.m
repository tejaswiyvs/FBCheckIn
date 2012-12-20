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

NSString * const kFriendCacheUpdateComplete = @"friendCacheUpdateComplete";
NSString * const kFriendCacheUpdateFailed = @"friendCacheUpdateFailed";

@synthesize friends = _friends;
@synthesize lastUpdated = _lastUpdated;
@synthesize facade = _facade;
@synthesize refreshing = _refreshing;

const long kCacheRefreshDuration = -1;

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

-(BOOL) shouldRefresh {
    long timestamp = [NSDate timeIntervalSinceReferenceDate];
    return ((timestamp - self.lastUpdated) > kCacheRefreshDuration);
}

-(BOOL) isEmpty {
    return (!self.friends || [self.friends count] == 0);
}

-(void)fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kFriendCacheUpdateFailed object:nil]];
}

-(void)fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    self.friends = [results objectForKey:@"data"];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kFriendCacheUpdateComplete object:nil]];
}

@end
