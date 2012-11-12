//
//  NSString+WhiteSpace.m
//  EcoCr
//
//  Created by Jack Lawrence on 7/31/12.
//
//

#import "NSString+WhiteSpace.h"

@implementation NSString (WhiteSpace)

- (BOOL)isNotWhiteSpaceOrNil
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self stringByTrimmingCharactersInSet:whitespace];
    return [trimmed length] != 0;
}

@end
