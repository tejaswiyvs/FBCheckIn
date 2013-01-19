//
//  TYCheckInCache.h
//  FBCheckIn
//
//  Created by Teja on 8/7/12.
//
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "TYFBRequest.h"

NSString * const kNotificationCacheRefreshStart;
NSString * const kNotificationCacheRefreshEnd;

@interface TYCheckInCache : NSObject<TYFBRequestDelegate>

@property (nonatomic, retain) NSDate *lastRefreshDate;
@property (nonatomic, strong) NSMutableArray *checkIns;
@property (nonatomic, strong) TYFBRequest *checkInsRequest;
@property (nonatomic, strong) TYFBRequest *photoCheckInsRequest;
@property (nonatomic, assign) BOOL loading;

+(TYCheckInCache *) sharedInstance;
-(void) forceRefresh;
-(void) clearCache;
-(void) commit;

@end