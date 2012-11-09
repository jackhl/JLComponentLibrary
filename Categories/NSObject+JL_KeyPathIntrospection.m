//  Created by Jack Lawrence on 10/28/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "NSObject+JL_KeyPathIntrospection.h"

#import <objc/runtime.h>

@interface NSObject (JL_KeyPathIntrospectionInternal)

+ (NSString *)JL_typeStringForProperty:(objc_property_t)property;
+ (Class)JL_classTypeForProperty:(objc_property_t)property;
+ (NSString *)JL_primitiveTypeForProperty:(objc_property_t)property;

+ (Class)JL_classForPropertyAtKeyPath:(NSArray *)keyArray onClass:(Class)class;

@end

@implementation NSObject (JL_KeyPathIntrospectionInternal)

+ (NSString *)JL_typeStringForProperty:(objc_property_t)property
{
    const char *attributes = property_getAttributes(property);
    NSString *attributesStringObj = [NSString stringWithUTF8String:attributes];
    if ([attributesStringObj rangeOfString:@"\""].length == 0) // primitive
    {
        NSRange range = NSMakeRange([attributesStringObj rangeOfString:@"T"].location+1, 1);
        return [attributesStringObj substringWithRange:range];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:attributesStringObj];
    [scanner scanUpToString:@"\"" intoString:NULL];
    [scanner setScanLocation:scanner.scanLocation + 1];
    NSString *objNameString = nil;
    [scanner scanUpToString:@"\"" intoString:&objNameString];
    
    return objNameString;
}

+ (NSString *)JL_primitiveTypeForProperty:(objc_property_t)property
{
    return [self JL_typeStringForProperty:property];
}

+ (Class)JL_classTypeForProperty:(objc_property_t)property
{
    return NSClassFromString([self JL_typeStringForProperty:property]);
}

+ (Class)JL_classForPropertyAtKeyPath:(NSArray *)keyArray onClass:(Class)class
{
    if ([keyArray count] == 0) return nil;
    
    objc_property_t theProperty;
    if ([keyArray count] == 1) {
        theProperty = class_getProperty(class, [[keyArray lastObject] UTF8String]);
        return NSClassFromString([self JL_typeStringForProperty:theProperty]);
    }
    else if ([keyArray count] > 1) {
        theProperty = class_getProperty(class, [[keyArray objectAtIndex:0] UTF8String]);
        Class propertyClass = [self JL_classTypeForProperty:theProperty];
        return [self JL_classForPropertyAtKeyPath:[keyArray subarrayWithRange:NSMakeRange(1, [keyArray count]-1)] onClass:propertyClass];
    }
    else {
        return nil;
    }
}

@end

@implementation NSObject (JL_KeyPathIntrospection)

+ (Class)JL_classForPropertyAtKeyPath:(NSString *)keyPath
{
    NSMutableArray *keyArr = [NSMutableArray arrayWithArray:[keyPath componentsSeparatedByString:@"."]];
    return [self JL_classForPropertyAtKeyPath:keyArr onClass:self];
}

- (Class)JL_classForPropertyAtKeyPath:(NSString *)keyPath
{
    return [[self class] JL_classForPropertyAtKeyPath:keyPath];
}

+ (NSString *)JL_primitiveTypeForPropertyAtKeyPath:(NSString *)keyPath
{
    NSMutableArray *keyArr = [NSMutableArray arrayWithArray:[keyPath componentsSeparatedByString:@"."]];
    if ([keyArr count] == 0) return nil;
    
    Class propertyClass;
    if ([keyArr count] == 1) {
        propertyClass = self;
    }
    else if ([keyArr count] > 1) {
        propertyClass = [self JL_classForPropertyAtKeyPath:[[keyArr subarrayWithRange:NSMakeRange(0, [keyArr count]-1)] componentsJoinedByString:@"."]];
    }
    else {
        return nil;
    }
    
    return [self JL_primitiveTypeForProperty:class_getProperty(propertyClass, [[keyArr lastObject] UTF8String])];
}

- (NSString *)JL_primitiveTypeForPropertyAtKeyPath:(NSString *)keyPath
{
    return [[self class] JL_primitiveTypeForPropertyAtKeyPath:keyPath];
}


@end
