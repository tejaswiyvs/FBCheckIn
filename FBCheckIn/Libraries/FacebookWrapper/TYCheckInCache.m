//
//  TYCheckInCache.m
//  FBCheckIn
//
//  Created by Teja on 8/7/12.
//
//

#import "TYCheckInCache.h"
#import "TYCheckIn.h"

@implementation TYCheckInCache

@synthesize checkIns = _checkIns;
@synthesize lastRefreshDate = _lastRefreshDate;

+(TYCheckInCache *) sharedInstance {
    static dispatch_once_t onceToken;
    static TYCheckInCache *cache;
    dispatch_once(&onceToken, ^{
        cache = [[TYCheckInCache alloc] init];
        [cache loadFromDisk];
    });
    return cache;
}

-(NSMutableArray *) checkIns {
    // Load from cache and return. Refresh in background.
    [self refreshCache];
    return self.checkIns;
}

-(void) loadFromDisk {
    
}

-(void) loadFromFacebook {

}

@end
