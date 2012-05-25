//
//  NSString+Common.m
//  TYLib
//
//  Created by Tejaswi Y on 3/6/12.
//  Derived From: http://benscheirman.com/2010/04/handy-categories-on-nsstring

#import "NSString+Common.h"

@implementation NSString (Common)

- (const xmlChar *)xmlChar
{
	return (const xmlChar *)[self UTF8String];
}

-(BOOL) isBlank {
    if([[self stringByStrippingWhitespace] isEqualToString:@""])
        return YES;
    return NO;
}

-(BOOL) contains:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

-(NSString *) stringByStrippingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *) stringByStrippingLastCharacter {
    if([self length] > 0) {
        return [self substringToIndex:[self length] - 1];
    }
    return @"";
}

-(NSArray *) splitOnChar:(char)ch {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    int start = 0;
    for(int i=0; i<[self length]; i++) {
        
        BOOL isAtSplitChar = [self characterAtIndex:i] == ch;
        BOOL isAtEnd = i == [self length] - 1;
        
        if(isAtSplitChar || isAtEnd) {
            //take the substring &amp; add it to the array
            NSRange range;
            range.location = start;
            range.length = i - start + 1;
            
            if(isAtSplitChar)
                range.length -= 1;
            
            [results addObject:[self substringWithRange:range]];
            start = i + 1;
        }
        
        //handle the case where the last character was the split char.  we need an empty trailing element in the array.
        if(isAtEnd && isAtSplitChar)
            [results addObject:@""];
    }
    
#if !__has_feature(objc_arc)
    return [results autorelease];
#endif
    return results;
}

-(NSString *) substringFrom:(NSInteger)from to:(NSInteger)to {
    NSString *rightPart = [self substringFromIndex:from];
    return [rightPart substringToIndex:to-from];
}

@end
