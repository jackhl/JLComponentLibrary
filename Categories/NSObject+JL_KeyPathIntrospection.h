//  Created by Jack Lawrence on 10/28/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Implements methods to simplify Objective-C runtime introspection on key paths.
 
 JL_KeyPathIntrospection is cool because instead of traveling a particular instance
 like `valueForKeyPath:` and related methods do, this category traverses the class
 definitions themselves.
 
 @note `id` is simply a typedef for a struct; It is not a full-fledged class.
 Therefore when checking for type `id`, use the primitive introspection methods
 which will return `@` for properties declared as type `id`.
 
 @warn Because the introspection is done on the class definition and not a particular
 instance, introspection will dead-end when the property is of type id. It will 
 also report the declared object type, so for example if you externally declare
 a property of type `NSArray` but internally you return an `NSMutableArray`, 
 property introspection will report it as an NSArray.
 
 @warn JL_KeyPathIntrospection does not look at private property (re)declarations.
 
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
 
 @warn Asking for the primitive type string for an object returns a string
 representation of the object's class. It does not raise an exception.
 
 @param keyPath The key path from the receiver to the property in question.
 
 @return The primitive type of the property at the specified key path.
 */
+ (NSString *)JL_primitiveTypeForPropertyAtKeyPath:(NSString *)keyPath;

/**
 Introspects the primitive type of the property at the specified key path on the
 receiver's class.
 
 @warn Asking for the primitive type string for an object returns a string
 representation of the object's class. It does not raise an exception.
 
 @param keyPath The key path from the receiver's class to the property in question.
 
 @return The primitive type of the property at the specified key path.
 */
- (NSString *)JL_primitiveTypeForPropertyAtKeyPath:(NSString *)keyPath;

@end
