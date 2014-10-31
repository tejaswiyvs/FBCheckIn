//
//  TYOffer.h
//  FBCheckIn
//
//  Created by Teja on 1/3/13.
//
//

#import <Foundation/Foundation.h>

@interface TYOffer : NSObject<NSCoding>

@property (nonatomic, assign) int claimLimit;
@property (nonatomic, retain) NSString *offerId;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *pageId;
@property (nonatomic, retain) NSString *redemptionCode;
@property (nonatomic, retain) NSString *redemptionLink;
@property (nonatomic, retain) NSString *terms;
@property (nonatomic, retain) NSString *title;

@end
