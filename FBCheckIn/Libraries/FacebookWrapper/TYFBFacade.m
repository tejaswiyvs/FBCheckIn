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
#import "NSString+Common.h"

@interface TYFBFacade ()
-(void) parseUnlikeResult:(id) result;
-(NSMutableArray *) checkInsForPageId:(NSString *) pageId fromCheckins:(NSMutableArray *) checkIns;
@end

@implementation TYFBFacade

@synthesize requestType = _requestType;
@synthesize delegate = _delegate;
@synthesize tag = _tag;
@synthesize status = _status;

-(id) init {
    self = [super init];
    if (self) {
        self.tag = -1;
        self.status = TYFBFacadeStatusUnknown;
    }
    return self;
}
    

-(void) currentUser {
    self.requestType = TYFBFacadeRequestTypeCurrentUser;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me, pic_cover FROM user WHERE uid=me()";
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

    // Get friends
    NSString *fql1 = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me, pic_cover, pic_big FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me()) OR uid=me()";
    
    // Get checkins FROM location_post and checkin. Both sources because sometimes location_post gets spammed with a ton of photos.
    NSString *fql2 = @"SELECT message, id, app_id, author_uid, timestamp, tagged_uids, page_id, page_type, coords, type FROM location_post WHERE author_uid IN (SELECT uid FROM #query1) ORDER BY timestamp DESC LIMIT 500";
    
    // Get page details for all the check-ins
    NSString *fql3 = @"SELECT page_id, name, description, categories, phone, pic, fan_count, website, checkins, location FROM page WHERE page_id IN (SELECT page_id FROM #query2)";
    
    // Get likes
    NSString *fql4 = @"SELECT object_id, post_id, user_id, object_type FROM like WHERE object_id IN (SELECT id FROM #query2)";
    
    // Get comments
    NSString *fql5 = @"SELECT object_id, post_id, fromid, time, text, likes, can_like, user_likes, text_tags FROM comment WHERE object_id IN (SELECT id FROM #query2)";
    
    // Get photo info if the check-in is of type photo
    NSString *fql6 = @"SELECT object_id, src_big, src_big_width, src_big_height, link FROM photo WHERE object_id IN (SELECT id FROM #query2 WHERE type='photo')";
    
    // Gets the users associated with comments and likes.
    NSString *fql7 = @"SELECT uid, username, first_name, middle_name, last_name, name, pic, sex, about_me, pic_cover, pic_big FROM user WHERE (uid IN (SELECT user_id FROM #query4)) OR (uid IN (SELECT fromid FROM #query5))";
    
    NSString *fql = [NSString stringWithFormat:@"{\"query1\":\"%@\",\"query2\":\"%@\",\"query3\":\"%@\",\"query4\":\"%@\",\"query5\":\"%@\", \"query6\":\"%@\", \"query7\":\"%@\"}", fql1, fql2, fql3, fql4, fql5, fql6, fql7];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"queries"];
    [facebook requestWithMethodName:@"fql.multiquery" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) loadMetaDataForPage:(TYPage *) page {
    if (!page) {
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    
    self.requestType = TYFBFacadeRequestTypeLoadPageMetaData;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = [NSString stringWithFormat:@"SELECT id, author_uid FROM location_post WHERE page_id = %@ AND author_uid IN (SELECT uid2 FROM friend WHERE uid1=me())", page.pageId];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    fql, @"query",
                                    nil];
    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) loadMetaDataForUser:(TYUser *) user {
    if (!user) {
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    
    self.requestType = TYFBFacadeRequestTypeLoadUserMetaData;
    
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = [NSString stringWithFormat:@"SELECT id, author_uid, page_id, timestamp FROM location_post WHERE author_uid = %@", user.userId];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    fql, @"query",
                                    nil];
    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) postComment:(TYComment *) comment {
    self.requestType = TYFBFacadeRequestTypePostComment;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/comments", comment.checkInId] andParams:[NSMutableDictionary dictionary] andHttpMethod:@"POST" andDelegate:self];
}

-(void) deleteComment:(TYComment *) comment {
    self.requestType = TYFBFacadeRequestTypeDeleteComment;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/comments", comment.checkInId] andParams:[NSMutableDictionary dictionary] andHttpMethod:@"DELETE" andDelegate:self];
}

-(void) loadPageData:(NSString *) pageId {
    self.requestType = TYFBFacadeRequestTypeLoadPageData;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = [NSString stringWithFormat:@"SELECT page_id, name, description, categories, phone, pic, fan_count, website, checkins, location FROM page WHERE page_id = %@", pageId];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    fql, @"query",
                                    nil];
    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) placesNearLocation:(CLLocationCoordinate2D) location {
    self.requestType = TYFBFacadeRequestTypePlacesNearLocation;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSString *fql = [NSString stringWithFormat:@"SELECT page_id, name, description, categories, pic, fan_count, website, checkins, location FROM page WHERE page_id IN (SELECT page_id FROM place WHERE distance(latitude, longitude, \"%.5f\", \"%.5f\") < 1000)", location.latitude, location.longitude];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    fql, @"query",
                                    nil];
    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) checkInAtPage:(TYPage *) page message:(NSString *) message taggedUsers:(NSMutableArray *) taggedUsers {
    self.requestType = TYFBFacadeRequestTypeCheckIn;
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
    [facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) postPhoto:(UIImage *) image withMessage:(NSString *) message {
    self.requestType = TYFBFacadeRequestTypePostPhoto;
    Facebook *facebook = [TYFBManager sharedInstance].facebook;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:UIImageJPEGRepresentation(image, 10) forKey:@"data"];
    if (message && ![message isBlank]) {
        [params setObject:message forKey:@"message"];
    }
    [facebook requestWithGraphPath:@"/me/photos" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

-(void) tagUsers:(NSMutableArray *) users forObjectId:(NSString *) objectId {
    self.requestType = TYFBFacadeRequestTypePostTags;
    if (!users || !objectId || [objectId isBlank]) {
        [self.delegate fbHelper:self didFailWithError:nil];
        return;
    }
    
}

-(void) postPage:(TYPage *) page forObjectId:(NSString *) objectId {
    self.requestType = TYFBFacadeRequestTypePostPageInfo;
}

#pragma mark - FBRequestDelegate

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [self.delegate fbHelper:self didFailWithError:error];
    self.status = TYFBFacadeStatusErrored;
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    self.status = TYFBFacadeStatusCompleted;
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
            break;
        case TYFBFacadeRequestTypePostComment:
            [self parsePostCommentResult:result];
            break;
        case TYFBFacadeRequestTypeDeleteComment:
            [self parseDeleteCommentResult:result];
            break;
        case TYFBFacadeRequestTypeLoadPageMetaData:
            [self parseMetaDataResult:result];
            break;
        case TYFBFacadeRequestTypeLoadUserMetaData:
            [self parseUserMetaDataResult:result];
            break;
        case TYFBFacadeRequestTypeLoadPageData:
            [self parsePageDataResult:result];
            break;
        case TYFBFacadeRequestTypePlacesNearLocation:
            [self parsePlacesNearLocationResponse:result];
            break;
        case TYFBFacadeRequestTypeCheckIn:
            [self parsePostCheckInResponse:result];
            break;
        case TYFBFacadeRequestTypePostPageInfo:
            [self parseAddPageInfoResponse:result];
            break;
        case TYFBFacadeRequestTypePostPhoto:
            [self parsePostPhotoResponse:result];
            break;
        case TYFBFacadeRequestTypePostTags:
            [self parseTagUsersResponse:result];
            break;
        default:
            [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:result, @"data", nil]];
            break;
    }
}

#pragma mark - Parsers

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

-(void) parseTagUsersResponse:(id) result {
    DebugLog(@"%@", result);
}

-(void) parseAddPageInfoResponse:(id) result {
    DebugLog(@"%@", result);
}

-(void) parsePlacesNearLocationResponse:(id) result {
    NSArray *resultArray = (NSArray *) result;
    NSMutableArray *pages = [NSMutableArray array];
    for (NSDictionary *pageDict in resultArray) {
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDict];
        if (page) {
            [pages addObject:page];
        }
    }
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:pages, @"data", nil]];
}

-(void) parsePageDataResult:(id) result {
    NSArray *resultArray = (NSArray *) result;
    if ([resultArray count] == 1) {
        NSDictionary *pageDict = [resultArray objectAtIndex:0];
        TYPage *page = [[TYPage alloc] initWithDictionary:pageDict];
        if (page) {
            [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:page, @"data", nil]];
            return;
        }
    }
    [self.delegate fbHelper:self didCompleteWithResults:nil];
}

-(void) parseUserMetaDataResult:(id) result {
    NSArray *resultArray = (NSArray *) result;
    NSMutableArray *checkInArray = [NSMutableArray array];
    for (NSDictionary *resultDict in resultArray) {
        TYCheckIn *checkIn = [[TYCheckIn alloc] initWithDictionary:resultDict];
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
    NSDictionary *resultDict = (NSDictionary *) result;
    BOOL resultValue = [[resultDict objectForKey:@"result"] boolValue];
    if (resultValue) {
        [self.delegate fbHelper:self didCompleteWithResults:nil];
    }
    else {
        [self.delegate fbHelper:self didFailWithError:nil];
    }
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
    
    if (!result || [result count] < 6) {
        DebugLog(@"%@", result);
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
    NSDictionary *commentsAndLikesUsersFqlDict = [(NSArray *) result objectAtIndex:6];
    
    NSArray *checkInDicts = [checkinFqlDict objectForKey:@"fql_result_set"];
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
    
    checkIns = [self filteredCheckInsFromCheckIns:checkIns];
    [self.delegate fbHelper:self didCompleteWithResults:[NSMutableDictionary dictionaryWithObjectsAndKeys:checkIns, @"data", nil]];
}

#pragma mark - Helpers

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
            if (checkIn2 != checkIn && [checkIn2.page.pageId isEqualToString:checkIn.page.pageId] && [checkIn.user.userId isEqualToString:checkIn2.user.userId] && fabs(([checkIn2.checkInDate timeIntervalSince1970] - [checkIn.checkInDate timeIntervalSince1970])) < 25 * 60 * 60 * 1000) {
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
