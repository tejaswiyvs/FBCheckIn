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
    TYFBFacadeRequestTypeGetCheckins,
    TYFBFacadeRequestTypeGetPlaces1,
    TYFBFacadeRequestTypeGetPlaces2,
    TYFBFacadeRequestTypeGetFriends
} TYFBFacadeRequestType;

@protocol TYFBFacadeDelegate;
@interface TYFBFacade : NSObject<FBRequestDelegate>

@property (nonatomic, assign) id<TYFBFacadeDelegate> delegate;
@property (nonatomic, assign) TYFBFacadeRequestType requestType;

-(void) checkInsForUser:(TYUser *) user;
-(void) placesNearLatitude:(CLLocationCoordinate2D) latitude longitude:(CLLocationCoordinate2D) longitude;
-(void) placesWithSearchString:(NSString *) searchString nearLatitude:(CLLocationCoordinate2D) latitude longitude:(CLLocationCoordinate2D) longitude;
-(void) friendsForUser:(TYUser *) user;

@end

@protocol TYFBFacadeDelegate
@required
-(void) fbHelper:(TYFBFacade *) helper didCompleteWithResults:(NSMutableDictionary *) results;
-(void) fbHelper:(TYFBFacade *) helper didFailWithError:(NSError *) err;
@end
