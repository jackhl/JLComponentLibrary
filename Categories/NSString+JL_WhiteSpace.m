//
//  NSString+WhiteSpace.m
//
//  Created by Jack Lawrence on 7/31/12.
//
//

#import "NSString+JL_WhiteSpace.h"

@implementation NSString (JL_WhiteSpace)

- (BOOL)JL_isNotWhiteSpaceOrNil
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self stringByTrimmingCharactersInSet:whitespace];
    return [trimmed length] != 0;
}

@end
