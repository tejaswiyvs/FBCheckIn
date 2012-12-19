//
//  TYCurrentUser.m
//  FBCheckIn
//
//  Created by Teja on 10/21/12.
//
//

#import "TYCurrentUser.h"
#import "TYFBManager.h"
#import "TYUtils.h"
#import "UIImageView+AFNetworking.h"

@interface TYCurrentUser ()

-(void) loadFromCache;
-(void) commitToCache;
-(void) loadCurrentUser;
-(void) clearCache;
-(void) postSuccessNotification;
-(void) postFailureNotification;
-(NSString *) applicationDocumentsDirectory;

@end

@implementation TYCurrentUser

NSString * const kCurrentUserDidLoadNotification = @"current_user_did_load";
NSString * const kCurrentUserDidErrorNotification = @"current_user_did_error";

@synthesize user = _user;
@synthesize refreshing = _refreshing;
@synthesize facade = _facade;

static NSString * const kCacheFileName = @"current_user";

-(id) init {
    self = [super init];
    if (self) {
        [self loadFromCache];
    }
    return self;
}

+(TYCurrentUser *) sharedInstance {
    static TYCurrentUser *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TYCurrentUser alloc] init];
    });
    return instance;
}

-(void) loadFromCache {
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kCacheFileName];
    self.user = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

-(void) commitToCache {
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kCacheFileName];
    [NSKeyedArchiver archiveRootObject:self.user toFile:filePath];
}

-(void) loadCurrentUser {
    self.refreshing = YES;
    [self loadFromCache];
    self.facade = [[TYFBFacade alloc] init];
    self.facade.delegate = self;
    [self.facade currentUser];
}

-(void) clearCache {
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kCacheFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

#pragma mark - Delegate

-(void) fbHelper:(TYFBFacade *)helper didCompleteWithResults:(NSMutableDictionary *)results {
    TYUser *user = (TYUser *) [results objectForKey:@"data"];
    if (!user) {
        [self postFailureNotification];
        return;
    }
    self.user = user;
    [self clearCache];
    [self commitToCache];
    [self postSuccessNotification];
}

-(void) fbHelper:(TYFBFacade *)helper didFailWithError:(NSError *)err {
    DebugLog(@"%@", err);
    [self postFailureNotification];
}

#pragma mark - Notifications

-(void) postSuccessNotification {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCurrentUserDidLoadNotification object:nil]];
}

-(void) postFailureNotification {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCurrentUserDidErrorNotification object:nil]];
}

#pragma mark - Helpers

-(NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
