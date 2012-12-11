//
//  TYFBHelper.h
//  FBCheckIn
//
//  Created by Teja on 8/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TYUser.h"
#import "TYPage.h"
#import "TYCheckIn.h"
#import "Facebook.h"
#import "TYComment.h"

// TODO Cleanup

typedef enum {
    TYFBFacadeRequestTypeCurrentUser,
    TYFBFacadeRequestTypeGetCheckins,
    TYFBFacadeRequestTypeGetPlaces1,
    TYFBFacadeRequestTypeGetPlaces2,
    TYFBFacadeRequestTypeGetFriends,
    TYFBFacadeRequestTypeLike,
    TYFBFacadeRequestTypeUnlike,
    TYFBFacadeRequestTypePostComment,
    TYFBFacadeRequestTypeDeleteComment,
    TYFBFacadeRequestTypeLoadPageMetaData,
    TYFBFacadeRequestTypeLoadUserMetaData,
    TYFBFacadeRequestTypeLoadPageData,
    TYFBFacadeRequestTypePlacesNearLocation
} TYFBFacadeRequestType;

@protocol TYFBFacadeDelegate;
@interface TYFBFacade : NSObject<FBRequestDelegate>

@property (nonatomic, assign) int tag;
@property (nonatomic, assign) id<TYFBFacadeDelegate> delegate;
@property (nonatomic, assign) TYFBFacadeRequestType requestType;

-(void) currentUser;
-(void) checkInsForUser:(TYUser *) user;
-(void) friendsForUser:(TYUser *) user;
-(void) likeCheckIn:(TYCheckIn *) checkIn;
-(void) unlikeCheckIn:(TYCheckIn *) checkIn;
-(void) postComment:(TYComment *) comment;
-(void) deleteComment:(TYComment *) comment;
-(void) loadMetaDataForPage:(TYPage *) page;
-(void) loadMetaDataForUser:(TYUser *) user;
-(void) loadPageData:(NSString *) pageId;
-(void) placesNearLocation:(CLLocationCoordinate2D) location;
@end

@protocol TYFBFacadeDelegate
@required
-(void) fbHelper:(TYFBFacade *) helper didCompleteWithResults:(NSMutableDictionary *) results;
-(void) fbHelper:(TYFBFacade *) helper didFailWithError:(NSError *) err;
@end
