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

@protocol TYFBHelperDelegate;
@interface TYFBHelper : NSObject

@property (nonatomic, assign) id<TYFBHelperDelegate> delegate;

-(void) checkInsForUser:(TYUser *) user forceRefresh:(BOOL) forceRefresh;

-(void) placesNearLatitude:(CLLocationCoordinate2D) latitude longitude:(CLLocationCoordinate2D) longitude;
-(void) placesWithSearchString:(NSString *) searchString nearLatitude:(CLLocationCoordinate2D) latitude longitude:(CLLocationCoordinate2D) longitude;

-(void) friendsForUser:(TYUser *) user;

@end

@protocol TYFBHelperDelegate
@required
-(void) fbHelper:(TYFBHelper *) helper didCompleteWithResults:(NSMutableDictionary *) results;
-(void) fbHelper:(TYFBHelper *) helper didFailWithError:(NSError *) err;
@end
