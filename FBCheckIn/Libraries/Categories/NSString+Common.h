//
//  NSString+Common.h
//  TYLib
//
//  Created by Tejaswi Y on 3/6/12.
//  Derived From : http://benscheirman.com/2010/04/handy-categories-on-nsstring

#import <Foundation/Foundation.h>
#import <libxml2/libxml/xmlstring.h>

@interface NSString (Common)

-(BOOL)isBlank;
-(BOOL)contains:(NSString *)string;
-(NSArray *)splitOnChar:(char)ch;
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
-(NSString *)stringByStrippingWhitespace;
-(NSString *) stringByStrippingLastCharacter;
- (const xmlChar *)xmlChar;
@end
