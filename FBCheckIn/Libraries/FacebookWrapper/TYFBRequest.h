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
    TYFBRequestTypeCurrentUser,
    TYFBRequestTypeGetCheckins,
    TYFBRequestTypeGetFriends,
    TYFBRequestTypeLike,
    TYFBRequestTypeUnlike,
    TYFBRequestTypePostComment,
    TYFBRequestTypeDeleteComment,
    TYFBRequestTypeLoadPageMetaData,
    TYFBRequestTypeLoadUserMetaData,
    TYFBRequestTypeLoadPageData,
    TYFBRequestTypePlacesNearLocation,
    TYFBRequestTypeCheckIn,
    TYFBRequestTypePostPhoto
} TYFBRequestType;

typedef enum {
    TYFBRequestStatusUnknown,
    TYFBRequestStatusCompleted,
    TYFBRequestStatusErrored
} TYFBRequestStatus;

@protocol TYFBRequestDelegate;
@interface TYFBRequest : NSObject<FBRequestDelegate>

@property (nonatomic, assign) int tag;
@property (nonatomic, assign) id<TYFBRequestDelegate> delegate;
@property (nonatomic, assign) TYFBRequestType requestType;
@property (nonatomic, assign) TYFBRequestStatus status;
@property (nonatomic, strong) FBRequest *request;

-(void) cancel;
-(void) currentUser;
-(void) checkInsForUser:(TYUser *) user since:(NSDate *) date;
-(void) likeCheckIn:(TYCheckIn *) checkIn;
-(void) unlikeCheckIn:(TYCheckIn *) checkIn;
-(void) postComment:(TYComment *) comment;
-(void) deleteComment:(TYComment *) comment;
-(void) loadMetaDataForPage:(TYPage *) page;
-(void) loadMetaDataForUser:(TYUser *) user;
-(void) loadPageData:(NSMutableArray *) pages;
-(void) placesNearLocation:(CLLocationCoordinate2D) location;
-(void) checkInAtPage:(TYPage *) page message:(NSString *) message taggedUsers:(NSMutableArray *) taggedUsers withPhotoId:(NSString *) photoId;
-(void) postPhoto:(UIImage *) image;
-(void) friendsForUser:(TYUser *) user;
@end

@protocol TYFBRequestDelegate
@required
-(void) fbHelper:(TYFBRequest *) helper didCompleteWithResults:(NSMutableDictionary *) results;
-(void) fbHelper:(TYFBRequest *) helper didFailWithError:(NSError *) err;
@end
