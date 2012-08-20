//
//  TYCheckInCache.h
//  FBCheckIn
//
//  Created by Teja on 8/7/12.
//
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

@interface TYCheckInCache : NSObject<FBRequestDelegate>

@property (nonatomic, assign) long lastRefreshDate;
@property (nonatomic, strong) NSMutableArray *checkIns;

+(TYCheckInCache *) sharedInstance;
-(NSMutableArray *) checkIns;
-(void) refreshCache;
@end