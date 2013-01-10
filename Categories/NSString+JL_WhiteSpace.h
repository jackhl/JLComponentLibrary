//
//  NSString+WhiteSpace.h
//
//  Created by Jack Lawrence on 7/31/12.
//
//

#import <Foundation/Foundation.h>

/** Extends NSString to provide support for detecting whitespace. */
@interface NSString (JL_WhiteSpace)

/**
 Determines whether or not the receiver does not only contain whitespace or is nil.
 
 White space includes spaces, tabs, and new line characters.
 
 @note JL_isNotWhiteSpaceOrNil treats an empty string (`@""`) the same as a string
 containing only whitespace.
 
 @note This method doesn't actually check for nil. It's worded awkwardly as such
 (i.e. the absence of certain content results in TRUE instead of the presence) to
 accommodate for the fact that method calls on nil objects return nil.
 
 @return Whether or not the receiver does not only contain whitespace or is nil.
 */
- (BOOL)JL_isNotWhiteSpaceOrNil;

@end
