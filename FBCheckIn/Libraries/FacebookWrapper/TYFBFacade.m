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
#import "TYComment.h"
#import "TYLike.h"

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
    
    NSString *fql4 = @"SELECT user_id, object_id, post_id FROM like WHERE object_id IN (SELECT checkin_id FROM #query1)";
    NSString *fql5 = @"SELECT object_id, post_id, fromid, time, text FROM comment WHERE object_id IN (SELECT checkin_id FROM #query1)";
    
    NSString* fql = [NSString stringWithFormat:
                     @"{\"query1\":\"%@\",\"query2\":\"%@\",\"query3\":\"%@\",\"query4\":\"%@\",\"query5\":\"%@\"}", fql1, fql2, fql3, fql4, fql5];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"queries"];
    [facebook requestWithMethodName:@"fql.multiquery" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

// TODO
-(void) placesNearLocation:(CLLocation *) location {
    self.requestType = TYFBFacadeRequestTypeGetPlaces1;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = @"SELECT page_id, name, description, categories, pic, fan_count, website, checkins, location FROM page WHERE page_id IN (SELECT page_id FROM place WHERE distance(latitude, longitude, \"28.492965\", \"-81.507847\") < 1000)";
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    fql, @"query",
                                    nil];
    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) placesWithSearchString:(NSString *) searchString nearLatitude:(CLLocationDegrees) latitude longitude:(CLLocationDegrees) longitude {

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
            [self parsePlaces:result];
            break;
        case TYFBFacadeRequestTypeGetPlaces2:
            break;
        default:
            [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:result, @"data", nil]];
            break;
    }
}

#pragma mark - Parsers

-(void) parsePlaces:(id) result {
    NSMutableArray *allItems = [[NSMutableArray alloc] init];
    for (NSDictionary *pageDictionary in ((NSArray *) result)) {
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDictionary];
        [allItems addObject:page];
    }
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:allItems, @"data", nil]];
}

-(void) parseCheckins:(id) result {
    NSMutableArray *checkIns = [NSMutableArray array];
    
    NSDictionary *checkinFqlDict = [(NSArray *) result objectAtIndex:0];
    NSDictionary *userFqlDict = [(NSArray *) result objectAtIndex:1];
    NSDictionary *pagesFqlDict = [(NSArray *) result objectAtIndex:2];
    NSDictionary *likesFqlDict = [(NSArray *) result objectAtIndex:3];
    NSDictionary *commentsFqlDict = [(NSArray *) result objectAtIndex:4];
    
    NSArray *checkInDicts = [checkinFqlDict objectForKey:@"fql_result_set"];
    NSArray *userDicts = [userFqlDict objectForKey:@"fql_result_set"];
    NSArray *pageDicts = [pagesFqlDict objectForKey:@"fql_result_set"];
    NSArray *likesDicts = [likesFqlDict objectForKey:@"fql_result_set"];
    NSArray *commentsDicts = [commentsFqlDict objectForKey:@"fql_result_set"];
    
    NSMutableDictionary *userObjects = [NSMutableDictionary dictionary];
    NSMutableDictionary *pageObjects = [NSMutableDictionary dictionary];
   
    NSMutableArray *likeObjects = [NSMutableArray array];
    NSMutableArray *commentObjects = [NSMutableArray array];
    
    for (NSDictionary *userDictionary in userDicts) {
        TYUser *user = [[TYUser alloc] initWithDictionary:userDictionary];
        [userObjects setObject:user forKey:[NSString stringWithFormat:@"user_%@", user.userId]];
    }
    
    for (NSDictionary *pageDictionary in pageDicts) {
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDictionary];
        [pageObjects setObject:page forKey:[NSString stringWithFormat:@"page_%@", page.pageId]];
    }
    
    for (NSDictionary *likesDict in likesDicts) {
        TYLike *like = [[TYLike alloc] initWithDictionary:likesDict];
        [likeObjects addObject:like];
    }
    
    for (NSDictionary *commentsDict in commentsDicts) {
        TYComment *comment = [[TYComment alloc] initWithDictionary:commentsDict];
        [commentObjects addObject:comment];
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
        checkIn.comments = [self commentsForCheckIn:checkIn.checkInId fromArray:commentObjects];
        checkIn.likes = [self likesForCheckIn:checkIn.checkInId fromArray:likeObjects];
    }
    
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:checkIns, @"data", nil]];
}

#pragma mark - Helpers

-(NSMutableArray *) commentsForCheckIn:(NSString *) checkInId fromArray:(NSMutableArray *) comments {
    NSMutableArray *results = [NSMutableArray array];
    for (TYComment *comment in comments) {
        if ([comment.checkInId isEqualToString:checkInId]) {
            [results addObject:comment];
        }
    }
    return results;
}

-(NSMutableArray *) likesForCheckIn:(NSString *) checkInId fromArray:(NSMutableArray *) likes {
    NSMutableArray *results = [NSMutableArray array];
    for (TYLike *like in likes) {
        if ([like.checkInId isEqualToString:checkInId]) {
            [results addObject:like];
        }
    }
    return results;
}
@end
