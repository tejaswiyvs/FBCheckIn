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

// TODO Cleanup

typedef enum {
    TYFBFacadeRequestTypeCurrentUser,
    TYFBFacadeRequestTypeGetCheckins,
    TYFBFacadeRequestTypeGetPlaces1,
    TYFBFacadeRequestTypeGetPlaces2,
    TYFBFacadeRequestTypeGetFriends,
    TYFBFacadeRequestTypeLike,
    TYFBFacadeRequestTypeUnlike
} TYFBFacadeRequestType;

@protocol TYFBFacadeDelegate;
@interface TYFBFacade : NSObject<FBRequestDelegate>

@property (nonatomic, assign) int tag;
@property (nonatomic, assign) id<TYFBFacadeDelegate> delegate;
@property (nonatomic, assign) TYFBFacadeRequestType requestType;

-(void) currentUser;
-(void) checkInsForUser:(TYUser *) user;
-(void) placesNearLocation:(CLLocation *) location;
-(void) placesWithSearchString:(NSString *) searchString nearLatitude:(CLLocationDegrees) latitude longitude:(CLLocationDegrees) longitude;
-(void) friendsForUser:(TYUser *) user;
-(void) likeCheckIn:(TYCheckIn *) checkIn;
-(void) unlikeCheckIn:(TYCheckIn *) checkIn;
@end

@protocol TYFBFacadeDelegate
@required
-(void) fbHelper:(TYFBFacade *) helper didCompleteWithResults:(NSMutableDictionary *) results;
-(void) fbHelper:(TYFBFacade *) helper didFailWithError:(NSError *) err;
@end
