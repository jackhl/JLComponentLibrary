//  Created by Jack Lawrence on 10/28/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Implements methods to simplify Objective-C runtime introspection on key paths.
 */
@interface NSObject (JL_KeyPathIntrospection)

/** @name Property Type Introspection */

/** 
 Introspects the class type of the property at the specified key path on the 
 receiver.
 
 @param keyPath The key path from the receiver to the property in question.
 
 @return The class of the property at the specified key path.
 */
+ (Class)JL_classForPropertyAtKeyPath:(NSString *)keyPath;

/**
 Introspects the class type of the property at the specified key path on the 
 receiver's class.
 
 @param keyPath The key path from the receiver's class to the property in question.
 
 @return The class of the property at the specified key path.
 */
- (Class)JL_classForPropertyAtKeyPath:(NSString *)keyPath;

// TODO: use chart in docs to translate single character symbols into the full names/typedef enum

/**
 Introspects the primitive type of the property at the specified key path on the 
 receiver.
 
 @param keyPath The key path from the receiver to the property in question.
 
 @return The primitive type of the property at the specified key path.
 */
+ (NSString *)JL_primitiveTypeForPropertyAtKeyPath:(NSString *)keyPath;

/**
 Introspects the primitive type of the property at the specified key path on the
 receiver's class.
 
 @param keyPath The key path from the receiver's class to the property in question.
 
 @return The primitive type of the property at the specified key path.
 */
- (NSString *)JL_primitiveTypeForPropertyAtKeyPath:(NSString *)keyPath;

@end
