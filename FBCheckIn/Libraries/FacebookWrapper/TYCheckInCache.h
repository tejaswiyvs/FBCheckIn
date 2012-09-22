//
//  TYCheckInCache.h
//  FBCheckIn
//
//  Created by Teja on 8/7/12.
//
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "TYFBFacade.h"

NSString * const kNotificationCacheRefreshStart;
NSString * const kNotificationCacheRefreshEnd;

@interface TYCheckInCache : NSObject<TYFBFacadeDelegate>

@property (nonatomic, retain) NSDate *lastRefreshDate;
@property (nonatomic, strong) NSMutableArray *checkIns;
@property (nonatomic, strong) TYFBFacade *helper;
@property (nonatomic, assign) BOOL loading;

+(TYCheckInCache *) sharedInstance;
-(void) forceRefresh;

@end