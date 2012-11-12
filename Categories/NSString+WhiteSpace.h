//
//  NSString+WhiteSpace.h
//  EcoCr
//
//  Created by Jack Lawrence on 7/31/12.
//
//

#import <Foundation/Foundation.h>

/** Extends NSString to provide support for detecting whitespace. */
@interface NSString (WhiteSpace)

/**
 Determines whether or not the receiver does not only contain whitespace or is nil.
 
 @note This method doesn't actually check for nil. It's worded awkwardly as such
 (ie the absence of certain content results in TRUE instead of the presence) to
 accomidate the fact that method calls on nil objects return nil.
 
 @return Whether or not the receiver does not only contain whitespace or is nil.
 */
- (BOOL)isNotWhiteSpaceOrNil;

@end
