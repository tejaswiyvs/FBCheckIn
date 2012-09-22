//
//  TYFBHelper.m
//  FBCheckIn
//
//  Created by Teja on 8/10/12.
//
//

#import "TYFBFacade.h"
#import "TYCheckInCache.h"
#import "TYFBManager.h"

@interface TYFBFacade ()
-(void) usersWithUserIds:(NSMutableArray *) userIds;
-(void) placesWithPlaceId:(NSMutableArray *) places;
@end

@implementation TYFBFacade

@synthesize requestType = _requestType;
@synthesize delegate = _delegate;

-(void) checkInsForUser:(TYUser *) user {
    self.requestType = TYFBFacadeRequestTypeGetCheckins;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql1 = @"";
    if(user) {
         fql1 = [NSString stringWithFormat:@"SELECT checkin_id, author_uid, page_id, coords, timestamp FROM checkin WHERE (author_uid IN (SELECT uid2 FROM friend WHERE uid1 = '%@') OR author_uid='%@') ORDER BY timestamp DESC LIMIT 50", user.userId, user.userId];
    }
    else {
        fql1 = @"SELECT checkin_id, author_uid, page_id, coords, timestamp FROM checkin WHERE (author_uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) OR author_uid=me()) ORDER BY timestamp DESC LIMIT 50";
    }
    NSString *fql2 = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me FROM user WHERE uid in (SELECT author_uid FROM #query1)";
    NSString *fql3 = @"SELECT page_id, name, description, categories, pic, fan_count, website, checkins, location FROM page WHERE page_id IN (SELECT page_id FROM #query1)";
    
    NSString* fql = [NSString stringWithFormat:
                     @"{\"query1\":\"%@\",\"query2\":\"%@\",\"query3\":\"%@\"}",fql1,fql2,fql3];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"queries"];
    [facebook requestWithMethodName:@"fql.multiquery" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

// TODO
-(void) placesNearLatitude:(CLLocationCoordinate2D) latitude longitude:(CLLocationCoordinate2D) longitude {

}

-(void) placesWithSearchString:(NSString *) searchString nearLatitude:(CLLocationCoordinate2D) latitude longitude:(CLLocationCoordinate2D) longitude {

}

-(void) usersWithUserIds:(NSMutableArray *) userIds {

}

-(void) placesWithPlaceId:(NSMutableArray *) places {

}

-(void) friendsForUser:(TYUser *) user {

}

#pragma mark - FBRequestDelegate

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [self.delegate fbHelper:self didFailWithError:error];
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    switch (self.requestType) {
        case TYFBFacadeRequestTypeGetCheckins:
            [self parseCheckins:result];
            break;
        case TYFBFacadeRequestTypeGetFriends:
            break;
        case TYFBFacadeRequestTypeGetPlaces1:
            break;
        case TYFBFacadeRequestTypeGetPlaces2:
            break;
        default:
            [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:result, @"data", nil]];
            break;
    }
}

#pragma mark - Parsers

-(void) parseCheckins:(id) result {
    NSMutableArray *checkIns = [NSMutableArray array];
    
    NSDictionary *checkinFqlDict = [(NSArray *) result objectAtIndex:0];
    NSDictionary *userFqlDict = [(NSArray *) result objectAtIndex:1];
    NSDictionary *pagesFqlDict = [(NSArray *) result objectAtIndex:2];
    
    NSArray *checkInDicts = [checkinFqlDict objectForKey:@"fql_result_set"];
    NSArray *userDicts = [userFqlDict objectForKey:@"fql_result_set"];
    NSArray *pageDicts = [pagesFqlDict objectForKey:@"fql_result_set"];
    
    NSMutableDictionary *userObjects = [NSMutableDictionary dictionary];
    NSMutableDictionary *pageObjects = [NSMutableDictionary dictionary];
    
    for (NSDictionary *userDictionary in userDicts) {
        TYUser *user = [[TYUser alloc] initWithDictionary:userDictionary];
        [userObjects setObject:user forKey:[NSString stringWithFormat:@"user_%@", user.userId]];
    }
    
    for (NSDictionary *pageDictionary in pageDicts) {
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDictionary];
        [pageObjects setObject:page forKey:[NSString stringWithFormat:@"page_%@", page.pageId]];
    }
    
    for (NSDictionary *checkInDictionary in checkInDicts) {
        TYCheckIn *checkIn = [[TYCheckIn alloc] initWithDictionary:checkInDictionary];
        TYUser *user = [userObjects objectForKey:[NSString stringWithFormat:@"user_%@", checkIn.user.userId]];
        TYPage *page = [pageObjects objectForKey:[NSString stringWithFormat:@"page_%@", checkIn.page.pageId]];
        if (user && page) {
            checkIn.user = user;
            checkIn.page = page;
            [checkIns addObject:checkIn];
        }
    }
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:checkIns, @"data", nil]];
}

@end
