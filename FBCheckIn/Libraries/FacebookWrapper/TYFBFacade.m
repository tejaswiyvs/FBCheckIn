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
#import "TYPhoto.h"

@interface TYFBFacade ()
-(void) usersWithUserIds:(NSMutableArray *) userIds;
-(void) placesWithPlaceId:(NSMutableArray *) places;
-(void) parseUnlikeResult:(id) result;
@end

@implementation TYFBFacade

@synthesize requestType = _requestType;
@synthesize delegate = _delegate;
@synthesize tag = _tag;

-(id) init {
    self = [super init];
    if (self) {
        self.tag = -1;
    }
    return self;
}
    

-(void) currentUser {
    self.requestType = TYFBFacadeRequestTypeCurrentUser;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me FROM user WHERE uid=me()";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"query"];
    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) likeCheckIn:(TYCheckIn *) checkIn {
    self.requestType = TYFBFacadeRequestTypeLike;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/likes", checkIn.checkInId] andParams:[NSMutableDictionary dictionary] andHttpMethod:@"POST" andDelegate:self];
}

-(void) unlikeCheckIn:(TYCheckIn *) checkIn {
    self.requestType = TYFBFacadeRequestTypeUnlike;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/likes", checkIn.checkInId] andParams:[NSMutableDictionary dictionary] andHttpMethod:@"DELETE" andDelegate:self];
}

-(void) checkInsForUser:(TYUser *) user {
    self.requestType = TYFBFacadeRequestTypeGetCheckins;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;

    NSString *fql1 = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me()) OR uid=me()";
    NSString *fql2 = @"SELECT message, id, app_id, author_uid, timestamp, tagged_uids, page_id, page_type, coords, type FROM location_post WHERE author_uid IN (SELECT uid FROM #query1) ORDER BY timestamp DESC";
    NSString *fql3 = @"SELECT page_id, name, description, categories, pic, fan_count, website, checkins, location FROM page WHERE page_id IN (SELECT page_id FROM #query2)";
    NSString *fql4 = @"SELECT object_id, post_id, user_id, object_type FROM like WHERE object_id IN (SELECT id FROM #query2)";
    NSString *fql5 = @"SELECT object_id, post_id, fromid, time, text, likes, can_like, user_likes, text_tags FROM comment WHERE object_id IN (SELECT id FROM #query2)";
    NSString *fql6 = @"SELECT object_id, src_big, src_big_width, src_big_height, link FROM photo WHERE object_id IN (SELECT id FROM #query2 WHERE type='photo')";
    
//    NSString* fql = [NSString stringWithFormat:
//                     @"{\"query1\":\"%@\",\"query2\":\"%@\",\"query3\":\"%@\",\"query4\":\"%@\",\"query5\":\"%@\", \"query6\", \"%@\"}", fql1, fql2, fql3, fql4, fql5, fql6];
    NSString *fql = [NSString stringWithFormat:@"{\"query1\":\"%@\",\"query2\":\"%@\",\"query3\":\"%@\",\"query4\":\"%@\",\"query5\":\"%@\", \"query6\":\"%@\"}", fql1, fql2, fql3, fql4, fql5, fql6];
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
        case TYFBFacadeRequestTypeCurrentUser:
            [self parseCurrentUserResponse:result];
            break;
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
        case TYFBFacadeRequestTypeLike:
            [self parseLikeResult:result];
            break;
        case TYFBFacadeRequestTypeUnlike:
            [self parseUnlikeResult:result];
        default:
            [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:result, @"data", nil]];
            break;
    }
}

#pragma mark - Parsers

-(void) parseCurrentUserResponse:(id) result {
    NSArray *resultArray = (NSArray *) result;
    if (resultArray && [resultArray count] > 0) {
        NSDictionary *resultDict = [resultArray objectAtIndex:0];
        TYUser *user = [[TYUser alloc] initWithDictionary:resultDict];
        [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:user, @"data", nil]];
    }
    else {
        [self.delegate fbHelper:self didFailWithError:nil];
    }
}

-(void) parseLikeResult:(id) result {
    NSDictionary *resultDict = (NSDictionary *) result;
    BOOL resultValue = [[resultDict objectForKey:@"result"] boolValue];
    if (resultValue) {
        [self.delegate fbHelper:self didCompleteWithResults:nil];
    }
    else {
        [self.delegate fbHelper:self didFailWithError:nil];
    }
}

-(void) parseUnlikeResult:(id) result {
    NSDictionary *resultDict = (NSDictionary *) result;
    BOOL resultValue = [[resultDict objectForKey:@"result"] boolValue];
    if (resultValue) {
        [self.delegate fbHelper:self didCompleteWithResults:nil];
    }
    else {
        [self.delegate fbHelper:self didFailWithError:nil];
    }
}


-(void) parsePlaces:(id) result {
    NSMutableArray *allItems = [[NSMutableArray alloc] init];
    for (NSDictionary *pageDictionary in ((NSArray *) result)) {
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDictionary];
        [allItems addObject:page];
    }
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:allItems, @"data", nil]];
}

-(void) parseCheckins:(id) result {
    
    if (!result || [result count] < 6) {
        NSLog(@"%@", result);
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    
    NSMutableArray *checkIns = [NSMutableArray array];
    NSDictionary *checkinFqlDict = [(NSArray *) result objectAtIndex:1];
    NSDictionary *userFqlDict = [(NSArray *) result objectAtIndex:0];
    NSDictionary *pagesFqlDict = [(NSArray *) result objectAtIndex:2];
    NSDictionary *likesFqlDict = [(NSArray *) result objectAtIndex:3];
    NSDictionary *commentsFqlDict = [(NSArray *) result objectAtIndex:4];
    NSDictionary *photosFqlDict = [(NSArray *) result objectAtIndex:5];
    
    NSArray *checkInDicts = [checkinFqlDict objectForKey:@"fql_result_set"];
    NSArray *userDicts = [userFqlDict objectForKey:@"fql_result_set"];
    NSArray *pageDicts = [pagesFqlDict objectForKey:@"fql_result_set"];
    NSArray *likesDicts = [likesFqlDict objectForKey:@"fql_result_set"];
    NSArray *commentsDicts = [commentsFqlDict objectForKey:@"fql_result_set"];
    NSArray *photoDicts = [photosFqlDict objectForKey:@"fql_result_set"];
    
    NSMutableDictionary *userObjects = [NSMutableDictionary dictionary];
    NSMutableDictionary *pageObjects = [NSMutableDictionary dictionary];
    NSMutableDictionary *photoObjects = [NSMutableDictionary dictionary];
   
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
    
    for (NSDictionary *photoDict in photoDicts) {
        TYPhoto *photo = [[TYPhoto alloc] initWithDictionary:photoDict];
        [photoObjects setObject:photo forKey:[NSString stringWithFormat:@"photo_%@", photo.objectId]];
    }
    
    for (NSDictionary *checkInDictionary in checkInDicts) {
        TYCheckIn *checkIn = [[TYCheckIn alloc] initWithDictionary:checkInDictionary];
        TYUser *user = [userObjects objectForKey:[NSString stringWithFormat:@"user_%@", checkIn.user.userId]];
        TYPage *page = [pageObjects objectForKey:[NSString stringWithFormat:@"page_%@", checkIn.page.pageId]];
        TYPhoto *photo = [photoObjects objectForKey:[NSString stringWithFormat:@"photo_%@", checkIn.checkInId]];
        if (user && page) {
            checkIn.user = user;
            checkIn.page = page;
            [checkIns addObject:checkIn];
        }
        checkIn.photo = photo;
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
