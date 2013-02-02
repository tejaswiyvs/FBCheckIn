//
//  TYFBHelper.m
//  FBCheckIn
//
//  Created by Teja on 8/10/12.
//
//

#import "TYFBRequest.h"
#import "TYCheckInCache.h"
#import "TYFBManager.h"
#import "TYComment.h"
#import "TYLike.h"
#import "TYPhoto.h"
#import "NSString+Common.h"

@interface TYFBRequest ()
-(void) parseUnlikeResult:(id) result;
-(NSMutableArray *) checkInsForPageId:(NSString *) pageId fromCheckins:(NSMutableArray *) checkIns;
@end

@implementation TYFBRequest

@synthesize requestType = _requestType;
@synthesize delegate = _delegate;
@synthesize tag = _tag;
@synthesize status = _status;
@synthesize request = _request;

-(id) init {
    self = [super init];
    if (self) {
        self.tag = -1;
        self.status = TYFBRequestStatusUnknown;
    }
    return self;
}

-(void) cancel {
    self.status = TYFBRequestStatusErrored;
    self.delegate = nil;
    self.request.delegate = nil;
}

-(void) currentUser {
    self.requestType = TYFBRequestTypeCurrentUser;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me, pic_cover, current_location FROM user WHERE uid=me()";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"query"];
    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) likeCheckIn:(TYCheckIn *) checkIn {
    self.requestType = TYFBRequestTypeLike;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    self.request = [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/likes", checkIn.checkInId] andParams:[NSMutableDictionary dictionary] andHttpMethod:@"POST" andDelegate:self];
}

-(void) unlikeCheckIn:(TYCheckIn *) checkIn {
    self.requestType = TYFBRequestTypeUnlike;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    self.request = [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/likes", checkIn.checkInId] andParams:[NSMutableDictionary dictionary] andHttpMethod:@"DELETE" andDelegate:self];
}

-(void) checkInsForUser:(TYUser *) user since:(NSDate *) date {
    self.requestType = TYFBRequestTypeGetCheckins;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    long since = [date timeIntervalSince1970];
    // Get friends
    NSString *fql1 = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me, pic_cover, pic_big, current_location FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me()) OR uid=me()";
    
    // Get checkins FROM location_post and checkin. Both sources because sometimes location_post gets spammed with a ton of photos.
    NSString *fql2 = @"";
    if (date) {
        fql2 = [NSString stringWithFormat:@"SELECT message, checkin_id, app_id, author_uid, timestamp, tagged_uids, page_id, coords FROM checkin WHERE author_uid IN (SELECT uid FROM #query1) AND timestamp > %ld ORDER BY timestamp DESC LIMIT 20", since];
    }
    else {
        // If no date is passed, we just load the last two weeks' worth of info
        long twoWeeksAgo = [self twoWeeksAgo];
        fql2 = [NSString stringWithFormat:@"SELECT message, checkin_id, app_id, author_uid, timestamp, tagged_uids, page_id, coords FROM checkin WHERE author_uid IN (SELECT uid FROM #query1) AND timestamp > %ld ORDER BY timestamp DESC LIMIT 20", twoWeeksAgo];
    }
    
    // Get checkins FROM location_post
    NSString *fql3 = @"";
    if (date) {
        fql3 = [NSString stringWithFormat:@"SELECT message, id, app_id, author_uid, timestamp, tagged_uids, page_id, page_type, coords, type FROM location_post WHERE author_uid IN (SELECT uid FROM #query1) AND type='photo' AND page_id != 'null' AND timestamp > %ld ORDER BY timestamp DESC LIMIT 20", since];
    }
    else {
        fql3 = @"SELECT message, id, app_id, author_uid, timestamp, tagged_uids, page_id, page_type, coords, type FROM location_post WHERE author_uid IN (SELECT uid FROM #query1) AND type='photo' AND page_id != 'null' ORDER BY timestamp DESC LIMIT 50";
    }
    
    // Get page details for all the check-ins
    NSString *fql4 = @"SELECT page_id, name, description, categories, phone, pic, fan_count, website, checkins, location, pic_cover FROM page WHERE page_id IN (SELECT page_id FROM #query2) OR page_id IN (SELECT page_id FROM #query3)";
    
    // Get likes
    NSString *fql5 = @"SELECT object_id, post_id, user_id, object_type FROM like WHERE object_id IN (SELECT checkin_id FROM #query2) OR object_id IN (SELECT id FROM #query3)";
    
    // Get comments
    NSString *fql6 = @"SELECT object_id, post_id, fromid, time, text, likes, can_like, user_likes, text_tags FROM comment WHERE object_id IN (SELECT checkin_id FROM #query2) OR object_id IN (SELECT id FROM #query3)";
    
    // Get photo info if the check-in is of type photo
    NSString *fql7 = @"SELECT object_id, src_big, src_big_width, src_big_height, link FROM photo WHERE object_id IN (SELECT id FROM #query3)";
    
    // Gets the users associated with comments and likes.
    NSString *fql8 = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me, pic_cover, pic_big, current_location FROM user WHERE uid IN (SELECT user_id FROM #query5) OR uid IN (SELECT fromid FROM #query6)";
    
    NSString *fql = [NSString stringWithFormat:@"{\"query1\":\"%@\",\"query2\":\"%@\",\"query3\":\"%@\",\"query4\":\"%@\",\"query5\":\"%@\", \"query6\":\"%@\", \"query7\":\"%@\", \"query8\":\"%@\"}", fql1, fql2, fql3, fql4, fql5, fql6, fql7, fql8];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"queries"];
    self.request = [facebook requestWithMethodName:@"fql.multiquery" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) loadMetaDataForPage:(TYPage *) page {
    if (!page) {
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    
    self.requestType = TYFBRequestTypeLoadPageMetaData;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = [NSString stringWithFormat:@"SELECT id, author_uid, type FROM location_post WHERE page_id = %@ AND page_id != 'null' AND author_uid IN (SELECT uid2 FROM friend WHERE uid1=me())", page.pageId];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    fql, @"query",
                                    nil];
    self.request = [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) loadMetaDataForUser:(TYUser *) user {
    if (!user) {
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    
    self.requestType = TYFBRequestTypeLoadUserMetaData;
    
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    // Get checkins from Checkin
    NSString *fql1 = [NSString stringWithFormat:@"SELECT message, checkin_id, app_id, author_uid, timestamp, tagged_uids, page_id, coords FROM checkin WHERE author_uid = '%@' ORDER BY timestamp DESC LIMIT 50", user.userId];
    
    // Get checkins FROM location_post
    NSString *fql2 = [NSString stringWithFormat:@"SELECT message, id, app_id, author_uid, timestamp, tagged_uids, page_id, page_type, coords, type FROM location_post WHERE author_uid = '%@' AND type='photo' AND page_id != 'null' ORDER BY timestamp DESC LIMIT 50", user.userId];
    
    NSString *fql = [NSString stringWithFormat:@"{\"query1\":\"%@\",\"query2\":\"%@\"}", fql1, fql2];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"queries"];
    self.request = [facebook requestWithMethodName:@"fql.multiquery" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) postComment:(TYComment *) comment {
    self.requestType = TYFBRequestTypePostComment;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    self.request = [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/comments", comment.checkInId] andParams:[NSMutableDictionary dictionaryWithObject:comment.text forKey:@"message"] andHttpMethod:@"POST" andDelegate:self];
}

-(void) deleteComment:(TYComment *) comment {
    self.requestType = TYFBRequestTypeDeleteComment;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    self.request = [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/comments", comment.checkInId] andParams:[NSMutableDictionary dictionary] andHttpMethod:@"DELETE" andDelegate:self];
}

-(void) loadPageData:(NSMutableArray *) pages {
    self.requestType = TYFBRequestTypeLoadPageData;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSMutableString *query = [[NSMutableString alloc] init];
    int i = 0;
    [query appendString:@"{"];
    for (TYPage *page in pages) {
        // "query1" : "SELECT .. FROM page WHERE page_id = $id
        [query appendFormat:@"\"query%d\" : \"SELECT page_id, name, description, categories, phone, pic, fan_count, website, checkins, location, pic_cover FROM page WHERE page_id = '%@'\",", i, page.pageId];
        i++;
    }
    if (query.length > 1) {
        query = [[query substringToIndex:([query length] - 1)] mutableCopy];
    }
    [query appendString:@"}"];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithString:query], @"queries",
                                    nil];
    self.request = [facebook requestWithMethodName:@"fql.multiquery" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) placesNearLocation:(CLLocationCoordinate2D) location withQuery:(NSString *) query limit:(int) limit {
    self.requestType = TYFBRequestTypePlacesNearLocation;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"place" forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    [params setObject:[NSString stringWithFormat:@"%.8lf,%.8lf", location.latitude, location.longitude] forKey:@"center"];
    [params setObject:@"id" forKey:@"fields"];
    [params setObject:@"2000" forKey:@"distance"];
    if (query && ![query isBlank]) {
        [params setObject:query forKey:@"q"];
    }
    self.request = [facebook requestWithGraphPath:@"search" andParams:params andDelegate:self];
}

-(void) placesVisitedByFriendsNearLocation:(CLLocationCoordinate2D) location {
    self.requestType = TYFBRequestTypePlacesNearLocationThatFriendsVisited;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    // Get checkins from Checkin
    NSString *fql1 = [NSString stringWithFormat:@"SELECT page_id, id FROM location_post WHERE author_uid IN (SELECT uid2 FROM friend WHERE uid1=me())"];
    // Get checkins FROM location_post
    NSString *fql2 = [NSString stringWithFormat:@"SELECT page_id, name FROM place WHERE page_id IN (SELECT page_id FROM #query1) AND distance(latitude, longitude, '%.5lf', '%.5lf') < 5000", location.latitude, location.longitude];
    NSString *fql = [NSString stringWithFormat:@"{\"query1\":\"%@\",\"query2\":\"%@\"}", fql1, fql2];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"queries"];
    self.request = [facebook requestWithMethodName:@"fql.multiquery" andParams:params andHttpMethod:@"POST" andDelegate:self];
}


-(void) checkInAtPage:(TYPage *) page message:(NSString *) message taggedUsers:(NSMutableArray *) taggedUsers {
    self.requestType = TYFBRequestTypeCheckIn;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (message && ![message isEqualToString:@""]) {
        [params setObject:message forKey:@"message"];
    }
    if (taggedUsers && [taggedUsers count] != 0) {
        NSString *tagsString = @"";
        for (TYUser *user in taggedUsers) {
            tagsString = [tagsString stringByAppendingString:user.userId];
            tagsString = [tagsString stringByAppendingString:@","];
        }
        // Snip the trailing comma
        if ([tagsString length] > 0) {
            tagsString = [tagsString substringToIndex:([tagsString length] - 1)];
        }
        
        [params setObject:tagsString forKey:@"tags"];
    }
    [params setObject:page.pageId forKey:@"place"];
    NSString *coordinatesString = [NSString stringWithFormat:@"{\"latitude\" : \"%f\", \"longitude\" : \"%f\"}", page.location.latitude, page.location.longitude];
    [params setObject:coordinatesString forKey:@"coordinates"];
    self.request = [facebook requestWithGraphPath:@"me/checkins" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) checkInAtPage:(TYPage *) page message:(NSString *) message taggedUsers:(NSMutableArray *) taggedUsers withPhoto:(UIImage *) photo {
    self.requestType = TYFBRequestTypePostPhoto;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (photo) {
        [params setObject:UIImageJPEGRepresentation(photo, 10) forKey:@"data"];
    }
    if (page.pageId && ![page.pageId isBlank]) {
        [params setObject:page.pageId forKey:@"place"];
    }
    if (message && ![message isBlank]) {
        [params setObject:message forKey:@"message"];
    }
    NSString *coordinates = [NSString stringWithFormat:@"{\"latitude\" : \"%.5lf\", \"longitude\" : \"%.5lf\"}", page.location.latitude, page.location.longitude];
    [params setObject:coordinates forKey:@"coordinates"];
    if ([taggedUsers count] > 0) {
        NSString *tags = @"[";
        for (TYUser *user in taggedUsers) {
            tags = [tags stringByAppendingFormat:@"{\"tag_uid\" : \"%@\"}", user.userId];
        }
        tags = [tags stringByAppendingString:@"]"];
        DebugLog(@"Tagged users: %@", tags);
    }
    self.request = [facebook requestWithGraphPath:@"/me/photos" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) friendsForUser:(TYUser *) user {
    self.requestType = TYFBRequestTypeGetFriends;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    // Get friends
    NSString *fql = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me, pic_cover, pic_big, current_location FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me()) OR uid=me()";
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fql, @"query", nil];
    self.request = [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

#pragma mark - FBRequestDelegate

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [self.delegate fbHelper:self didFailWithError:error];
    self.status = TYFBRequestStatusErrored;
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    self.status = TYFBRequestStatusCompleted;
    switch (self.requestType) {
        case TYFBRequestTypeCurrentUser:
            [self parseCurrentUserResponse:result];
            break;
        case TYFBRequestTypeGetCheckins:
            [self parseCheckins:result];
            break;
        case TYFBRequestTypeGetFriends:
            [self parseFriends:result];
            break;
        case TYFBRequestTypeLike:
            [self parseLikeResult:result];
            break;
        case TYFBRequestTypeUnlike:
            [self parseUnlikeResult:result];
            break;
        case TYFBRequestTypePostComment:
            [self parsePostCommentResult:result];
            break;
        case TYFBRequestTypeDeleteComment:
            [self parseDeleteCommentResult:result];
            break;
        case TYFBRequestTypeLoadPageMetaData:
            [self parseMetaDataResult:result];
            break;
        case TYFBRequestTypeLoadUserMetaData:
            [self parseUserMetaDataResult:result];
            break;
        case TYFBRequestTypeLoadPageData:
            [self parsePageDataResult:result];
            break;
        case TYFBRequestTypePlacesNearLocation:
            [self parsePlacesNearLocationResponse:result];
            break;
        case TYFBRequestTypeCheckIn:
            [self parsePostCheckInResponse:result];
            break;
        case TYFBRequestTypePostPhoto:
            [self parsePostPhotoResponse:result];
            break;
        case TYFBRequestTypePlacesNearLocationThatFriendsVisited:
            [self parsePlacesFriendsHaveBeenTo:result];
            break;
        default:
            [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:result, @"data", nil]];
            break;
    }
}

#pragma mark - Parsers

-(void) parsePlacesFriendsHaveBeenTo:(id) result {
    NSArray *resultArray = (NSArray *) result;
    
    if ([resultArray count] != 2) {
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    NSDictionary *pagesDict = [resultArray objectAtIndex:1];
    NSArray *pagesArray = [pagesDict objectForKey:@"fql_result_set"];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSDictionary *pageDict in pagesArray) {
        TYPage *page = [[TYPage alloc] init];
        page.pageId = [pageDict objectForKey:@"page_id"];
        [results addObject:page];
    }
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:results, @"data", nil]];
}

-(void) parseFriends:(id) result {
    NSArray *resultArray = (NSArray *) result;
    NSMutableArray *friends = [NSMutableArray array];
    for (NSDictionary *userDict in resultArray) {
        TYUser *user = [[TYUser alloc] initWithDictionary:userDict];
        [friends addObject:user];
    }
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:friends, @"data", nil]];
}

-(void) parsePostCheckInResponse:(id) result {
    NSDictionary *resultDict = (NSDictionary *) result;
    NSString *checkInId = [resultDict objectForKey:@"id"];
    if (checkInId && ![checkInId isBlank]) {
        [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:checkInId, @"data", nil]];
    }
    else {
        [self.delegate fbHelper:self didFailWithError:nil];
    }
}

-(void) parsePostPhotoResponse:(id) result {
    NSDictionary *resultDict = (NSDictionary *) result;
    NSString *photoId = [resultDict objectForKey:@"id"];
    if (photoId && ![photoId isBlank]) {
        [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:photoId, @"data", nil]];
    }
    else {
        [self.delegate fbHelper:self didFailWithError:nil];
    }
}

-(void) parsePlacesNearLocationResponse:(id) result {
    NSArray *resultArray = [(NSDictionary *) result objectForKey:@"data"];
    NSMutableArray *pages = [NSMutableArray array];
    for (NSDictionary *pageDict in resultArray) {
        TYPage *page = [[TYPage alloc] init];
        NSString *pageId = [pageDict objectForKey:@"id"];
        if (pageId && ![pageId isBlank]) {
            page.pageId = pageId;
            [pages addObject:page];
        }
    }
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:pages, @"data", nil]];
}

-(void) parsePageDataResult:(id) result {
    NSArray *resultArray = (NSArray *) result;
    NSMutableArray *pages = [NSMutableArray array];
    for (NSDictionary *resultDictionary in resultArray) {
        NSArray *tempArr = [resultDictionary objectForKey:@"fql_result_set"];
        if (tempArr && [tempArr count] > 0) {
            NSDictionary *pageDict = [[resultDictionary objectForKey:@"fql_result_set"] objectAtIndex:0];
            TYPage *page = [[TYPage alloc] initWithDictionary:pageDict];
            [pages addObject:page];
        }
    }
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObject:pages forKey:@"data"]];
}

-(void) parseUserMetaDataResult:(id) result {
    NSArray *resultArray = (NSArray *) result;
    
    if ([resultArray count] != 2) {
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    
    NSDictionary *checkIn1Dict = [resultArray objectAtIndex:0];
    NSDictionary *checkIn2Dict = [resultArray objectAtIndex:1];
    
    NSArray *checkIn1Array = [checkIn1Dict objectForKey:@"fql_result_set"];
    NSArray *checkIn2Array = [checkIn2Dict objectForKey:@"fql_result_set"];
    
    NSMutableArray *checkInArray = [NSMutableArray array];
    
    for (NSDictionary *resultDict in checkIn1Array) {
        TYCheckIn *checkIn = [[TYCheckIn alloc] initWithDictionary:resultDict];
        [checkInArray addObject:checkIn];
    }
    for (NSDictionary *resultDict in checkIn2Array) {
        TYCheckIn *checkIn = [[TYCheckIn alloc] initWithDictionary:resultDict];
        checkIn.photo = [[TYPhoto alloc] init];
        [checkInArray addObject:checkIn];
    }
    
    // Cleans up any album data that we have.
    // TODO : If the user uploads a 100 picture album and tags all the places at the same location, this method might fail?
    NSMutableArray *filteredCheckins = [self filteredCheckInsFromCheckIns:checkInArray];
    if (filteredCheckins) {
        NSMutableDictionary *response = [NSMutableDictionary dictionaryWithObjectsAndKeys:filteredCheckins, @"data", nil];
        [self.delegate fbHelper:self didCompleteWithResults:response];
    }
    else {
        [self.delegate fbHelper:self didCompleteWithResults:nil];
    }

}

-(void) parseMetaDataResult:(id) result {
    NSArray *resultArry = (NSArray *) result;
    NSNumber *count = [NSNumber numberWithInt:resultArry.count];
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:count, @"data", nil]];
}

-(void) parsePostCommentResult:(id) result {
    [self.delegate fbHelper:self didCompleteWithResults:nil];
}

-(void) parseDeleteCommentResult:(id) result {
    NSDictionary *resultDict = (NSDictionary *) result;
    BOOL resultValue = [[resultDict objectForKey:@"result"] boolValue];
    if (resultValue) {
        [self.delegate fbHelper:self didCompleteWithResults:nil];
    }
    else {
        [self.delegate fbHelper:self didFailWithError:nil];
    }
}

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
    
    if (!result || [result count] != 8) {
        DebugLog(@"%@", result);
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    
    NSMutableArray *checkIns = [NSMutableArray array];
    // Friends
    NSDictionary *userFqlDict = [(NSArray *) result objectAtIndex:0];
    // SELECT * FROM checkin
    NSDictionary *checkinFqlDict = [(NSArray *) result objectAtIndex:1];
    // SELECT * FROM location_post
    NSDictionary *photoCheckInsFqlDict = [(NSArray *) result objectAtIndex:2];
    // All the pages referenced by the two checkInDicts
    NSDictionary *pagesFqlDict = [(NSArray *) result objectAtIndex:3];
    // All the likes referenced by the two checkInDicts
    NSDictionary *likesFqlDict = [(NSArray *) result objectAtIndex:4];
    // All the comments referenced by the two checkInDicts
    NSDictionary *commentsFqlDict = [(NSArray *) result objectAtIndex:5];
    // All the photo objects
    NSDictionary *photosFqlDict = [(NSArray *) result objectAtIndex:6];
    // All the users referenced by the two checkInDicts
    NSDictionary *commentsAndLikesUsersFqlDict = [(NSArray *) result objectAtIndex:7];
    
    NSArray *checkInDicts = [checkinFqlDict objectForKey:@"fql_result_set"];
    NSArray *photoCheckInDicts = [photoCheckInsFqlDict objectForKey:@"fql_result_set"];
    NSArray *userDicts = [userFqlDict objectForKey:@"fql_result_set"];
    NSArray *pageDicts = [pagesFqlDict objectForKey:@"fql_result_set"];
    NSArray *likesDicts = [likesFqlDict objectForKey:@"fql_result_set"];
    NSArray *commentsDicts = [commentsFqlDict objectForKey:@"fql_result_set"];
    NSArray *photoDicts = [photosFqlDict objectForKey:@"fql_result_set"];
    NSArray *commentsAndLikesUserDicts = [commentsAndLikesUsersFqlDict objectForKey:@"fql_result_set"];
    
    NSMutableDictionary *userObjects = [NSMutableDictionary dictionary];
    NSMutableDictionary *pageObjects = [NSMutableDictionary dictionary];
    NSMutableDictionary *photoObjects = [NSMutableDictionary dictionary];
    NSMutableArray *likeObjects = [NSMutableArray array];
    NSMutableArray *commentObjects = [NSMutableArray array];
    
    for (NSDictionary *userDictionary in userDicts) {
        TYUser *user = [[TYUser alloc] initWithDictionary:userDictionary];
        [userObjects setObject:user forKey:[NSString stringWithFormat:@"user_%@", user.userId]];
    }
    
    for (NSDictionary *userDictionary in commentsAndLikesUserDicts) {
        TYUser *user = [[TYUser alloc] initWithDictionary:userDictionary];
        [userObjects setObject:user forKey:[NSString stringWithFormat:@"user_%@", user.userId]];
    }
    
    for (NSDictionary *pageDictionary in pageDicts) {
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDictionary];
        [pageObjects setObject:page forKey:[NSString stringWithFormat:@"page_%@", page.pageId]];
    }
    
    for (NSDictionary *likesDict in likesDicts) {
        TYLike *like = [[TYLike alloc] initWithDictionary:likesDict];
        TYUser *user = [userObjects objectForKey:[NSString stringWithFormat:@"user_%@", like.user.userId]];
        if (user) {
            like.user = user;
        }
        [likeObjects addObject:like];
    }
    
    for (NSDictionary *commentsDict in commentsDicts) {
        TYComment *comment = [[TYComment alloc] initWithDictionary:commentsDict];
        TYUser *user = [userObjects objectForKey:[NSString stringWithFormat:@"user_%@", comment.user.userId]];
        if (user) {
            comment.user = user;
        }
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
        checkIn.comments = [self commentsForCheckIn:checkIn.checkInId fromArray:commentObjects];
        checkIn.likes = [self likesForCheckIn:checkIn.checkInId fromArray:likeObjects];
        checkIn.type = @"checkin";
        if (user && page) {
            checkIn.user = user;
            checkIn.page = page;
            [checkIns addObject:checkIn];
        }
    }
    
    for (NSDictionary *checkInDictionary in photoCheckInDicts) {
        TYCheckIn *checkIn = [[TYCheckIn alloc] initWithDictionary:checkInDictionary];
        TYUser *user = [userObjects objectForKey:[NSString stringWithFormat:@"user_%@", checkIn.user.userId]];
        TYPage *page = [pageObjects objectForKey:[NSString stringWithFormat:@"page_%@", checkIn.page.pageId]];
        TYPhoto *photo = [photoObjects objectForKey:[NSString stringWithFormat:@"photo_%@", checkIn.checkInId]];
        checkIn.photo = photo;
        checkIn.comments = [self commentsForCheckIn:checkIn.checkInId fromArray:commentObjects];
        checkIn.likes = [self likesForCheckIn:checkIn.checkInId fromArray:likeObjects];
        if (user && page) {
            checkIn.user = user;
            checkIn.page = page;
            checkIn.type = @"photo";
            [checkIns addObject:checkIn];
        }
    }

    checkIns = [self filteredCheckInsFromCheckIns:checkIns];
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:checkIns, @"data", nil]];
}

#pragma mark - Helpers

-(long) twoWeeksAgo {
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    [components setHour:(-24 * 14)];
    return [[cal dateByAddingComponents:components toDate:today options:0] timeIntervalSince1970];
}

-(NSMutableArray *) checkInsForPageId:(NSString *) pageId fromCheckins:(NSMutableArray *) checkIns {
    NSMutableArray *checkInsForPageId = [NSMutableArray array];
    for (TYCheckIn *checkIn in checkIns) {
        if ([checkIn.page.pageId isEqualToString:pageId]) {
            [checkInsForPageId addObject:checkIn];
        }
    }
    return checkInsForPageId;
}


-(NSMutableArray *) filteredCheckInsFromCheckIns:(NSMutableArray *) checkIns {
    NSMutableArray *filteredCheckins = [NSMutableArray array];
    for (TYCheckIn *checkIn in checkIns) {
        // If no photo, always add.
        if (![checkIn hasPhoto]) {
            [filteredCheckins addObject:checkIn];
            continue;
        }
        
        // If checkIn has photo, verify if it's just an album with a ton of photos the user uploaded. If it is, skip it.
        // We do this by comparing if the same user checked in at the same place multiple times.
        BOOL flag = YES;
        for (TYCheckIn *checkIn2 in checkIns) {
            NSTimeInterval difference = [checkIn2.checkInDate timeIntervalSinceDate:checkIn.checkInDate];
            if (difference < 0) {
                difference = difference * -1;
            }
            if (checkIn2 != checkIn && [checkIn2.page.pageId isEqualToString:checkIn.page.pageId] && [checkIn.user.userId isEqualToString:checkIn2.user.userId] && difference < 24 * 60 * 60 * 1000) {
//                DebugLog(@"Should not add checkIn");
                flag = NO;
            }
        }
        if (flag) {
            [filteredCheckins addObject:checkIn];
        }
    }
    return filteredCheckins;
}

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
