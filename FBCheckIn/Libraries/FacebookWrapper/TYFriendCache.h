//
//  TYFriendCache.h
//  FBCheckIn
//
//  Created by Teja on 12/19/12.
//
//

#import <Foundation/Foundation.h>
#import "TYFBFacade.h"

extern NSString * const kFriendCacheUpdateComplete;
extern NSString * const kFriendCacheUpdateFailed;

@interface TYFriendCache : NSObject<TYFBFacadeDelegate>

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, assign) long lastUpdated;
@property (nonatomic, strong) TYFBFacade *facade;
@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) NSDate *lastRefreshDate;

+(TYFriendCache *) sharedInstance;
-(void) forceRefresh;
-(BOOL) isEmpty;
-(NSMutableArray *) cachedFriends;
-(void) clearCache;

@end
