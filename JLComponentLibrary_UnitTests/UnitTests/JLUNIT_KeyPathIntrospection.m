//
//  UnitTests.m
//  UnitTests
//
//  Created by Jack Lawrence on 11/7/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLUNIT_KeyPathIntrospection.h"

#import "NSObject+JL_KeyPathIntrospection.h"

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;
@property (nonatomic, readonly, strong) NSObject *firstName;
@property (nonatomic, strong) id theGenericObject;

@end

@implementation Person

@end

// Takes selector, keyPath selector param, and expected class. Checks equality and nil.
#define AssertMethodReturnMatchesExpectedClass(selector, selParam, expectedClass) { \
    Class actualClass = (Class)[_person performSelector:selector withObject:selParam]; \
    STAssertNotNil(actualClass, @"-[NSObject %@] returned a null Class object.", NSStringFromSelector(selector)); \
    STAssertEqualObjects(actualClass, expectedClass, @"%@ did not return the correct Class object. Should have been %@, instead got %@.", NSStringFromSelector(selector), NSStringFromClass(expectedClass), NSStringFromClass(actualClass)); \
}

#define AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(classSelector, primitiveSelector, selParam, expectedPrimitive) { \
    Class primitiveClass = (Class)[_person performSelector:classSelector withObject:selParam]; \
    NSString *primitiveType = (NSString *)[_person performSelector:primitiveSelector withObject:selParam]; \
    STAssertNil(primitiveClass, @"-[NSObject %@] did not return a null Class for a primitive type. It instead returned %@.", NSStringFromSelector(classSelector), NSStringFromClass(primitiveClass)); \
    STAssertNotNil(primitiveType, @"-[NSObject %@] returned a nil NSString for a primitive type.", primitiveSelector); \
    STAssertEqualObjects(primitiveType, expectedPrimitive, @"-[NSObject %@] did not return @\"%@\". It instead returned @\"%@\".", expectedPrimitive, primitiveType); \
}

@implementation JLUNIT_KeyPathIntrospection {
    Person *_person;
}

- (void)setUp
{
    [super setUp];
    
    _person = [[Person alloc] init];
    
    STAssertNotNil(_person, @"Failed to initialize an object of type Person and set _person to it at setUp.");
}

- (void)tearDown
{
    _person = nil;
    
    STAssertNil(_person, @"Failed to set _person to nil at tearDown.");
    
    [super tearDown];
}

- (void)testSingleKeyOfObjectType {
    AssertMethodReturnMatchesExpectedClass(@selector(JL_classForPropertyAtKeyPath:), @"name", [NSString class]);
    
    NSString *namePrimitiveString = [_person JL_primitiveTypeForPropertyAtKeyPath:@"name"];
    
    STAssertNotNil(namePrimitiveString, @"-[NSObject JL_primitiveTypeForPropertyAtKeyPath] returned a nil NSString for an object type.");
    STAssertEqualObjects(namePrimitiveString, @"NSString", @"-[NSObject JL_primitiveTypeForPropertyAtKeyPath] did not return @\"NSString\". It instead returned @\"%@\".", namePrimitiveString);
}

- (void)testSingleKeyOfObjectTypePrivateRedeclaration {
    AssertMethodReturnMatchesExpectedClass(@selector(JL_classForPropertyAtKeyPath:), @"firstName", [NSObject class]);
    
    NSString *firstNamePrimitive = [_person JL_primitiveTypeForPropertyAtKeyPath:@"firstName"];
    
    STAssertNotNil(firstNamePrimitive, @"-[NSObject JL_primitiveTypeForPropertyAtKeyPath] returned a nil NSString for an object type.");
    STAssertEqualObjects(firstNamePrimitive, @"NSObject", @"-[NSObject JL_primitiveTypeForPropertyAtKeyPath] did not return @\"NSObject\". It instead returned @\"%@\".", firstNamePrimitive);
}

- (void)testSingleKeyOfPrimitiveType {
    AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(@selector(JL_classForPropertyAtKeyPath:), @selector(JL_primitiveTypeForPropertyAtKeyPath:), @"age", @"i");
}

- (void)testSingleKeyOfIDObjectType {
    
    AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(@selector(JL_classForPropertyAtKeyPath:), @selector(JL_primitiveTypeForPropertyAtKeyPath:), @"theGenericObject", @"@");
}

- (void)testKeyPathOfObjectType {
    STFail(@"Test not implemented.");
}

- (void)testKeyPathOfPrimitiveType {
    STFail(@"Test not implemented.");
}

@end
