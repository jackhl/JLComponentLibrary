//
//  UnitTests.m
//  UnitTests
//
//  Created by Jack Lawrence on 11/7/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLUNIT_KeyPathIntrospection.h"

#import "NSObject+JL_KeyPathIntrospection.h"

@class Pet, AquaticPet;

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;
@property (nonatomic, readonly, strong) NSObject *firstName;
@property (nonatomic, strong) id theGenericObject;
@property (nonatomic, strong) Pet *pet;
@property (nonatomic, strong) AquaticPet *fish;

@end

@implementation Person

@end

typedef NS_ENUM(NSUInteger, JLUNIT_PetType) {
    JLUNIT_PetTypeDog,
    JLUNIT_PetTypeCat,
    JLUNIT_PetTypeFish
};

@interface Pet : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) JLUNIT_PetType petType;

@end

@implementation Pet

@end

@interface AquaticPet : Pet

@end

@implementation AquaticPet

@end

// Takes selector, keyPath selector param, and expected class. Checks equality and nil.
#define AssertMethodReturnMatchesExpectedClass(selector, keyPath, expectedClass) { \
    Class actualClass = (Class)[_person performSelector:selector withObject:keyPath]; \
    STAssertNotNil(actualClass, @"-[NSObject %@] returned a null Class object.", NSStringFromSelector(selector)); \
    STAssertEqualObjects(actualClass, expectedClass, @"%@ did not return the correct Class object. Should have been %@, instead got %@.", NSStringFromSelector(selector), NSStringFromClass(expectedClass), NSStringFromClass(actualClass)); \
}

#define AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(classSelector, primitiveSelector, keyPath, expectedPrimitive) { \
    Class primitiveClass = (Class)[_person performSelector:classSelector withObject:keyPath]; \
    NSString *primitiveType = (NSString *)[_person performSelector:primitiveSelector withObject:keyPath]; \
    STAssertNil(primitiveClass, @"-[NSObject %@] did not return a null Class for a primitive type. It instead returned %@.", NSStringFromSelector(classSelector), NSStringFromClass(primitiveClass)); \
    STAssertNotNil(primitiveType, @"-[NSObject %@] returned a nil NSString for a primitive type.", NSStringFromSelector(primitiveSelector)); \
    STAssertEqualObjects(primitiveType, expectedPrimitive, @"-[NSObject %@] did not return @\"%@\". It instead returned @\"%@\".", NSStringFromSelector(primitiveSelector), expectedPrimitive, primitiveType); \
}

#define AssertStringFromClassReturnForPrimitiveCallOnObjectType(keyPath, expectedClassString) \
    NSString *primitiveString = [_person JL_primitiveTypeForPropertyAtKeyPath:keyPath]; \
    STAssertNotNil(primitiveString, @"-[NSObject JL_primitiveTypeForPropertyAtKeyPath:] returned a nil NSString for an object type."); \
    STAssertEqualObjects(primitiveString, expectedClassString, @"-[NSObject JL_primitiveTypeForPropertyAtKeyPath:] did not return @\"%@\". It instead returned @\"%@\".", expectedClassString, primitiveString);

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
    
    AssertStringFromClassReturnForPrimitiveCallOnObjectType(@"name", @"NSString");
}

- (void)testSingleKeyOfObjectTypePrivateRedeclaration {
    AssertMethodReturnMatchesExpectedClass(@selector(JL_classForPropertyAtKeyPath:), @"firstName", [NSObject class]);
    
    AssertStringFromClassReturnForPrimitiveCallOnObjectType(@"firstName", @"NSObject");
}

- (void)testSingleKeyOfPrimitiveType {
    AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(@selector(JL_classForPropertyAtKeyPath:), @selector(JL_primitiveTypeForPropertyAtKeyPath:), @"age", @"i");
}

- (void)testSingleKeyOfIDObjectType {
    
    AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(@selector(JL_classForPropertyAtKeyPath:), @selector(JL_primitiveTypeForPropertyAtKeyPath:), @"theGenericObject", @"@");
}

- (void)testKeyPathOfObjectType {
    AssertMethodReturnMatchesExpectedClass(@selector(JL_classForPropertyAtKeyPath:), @"pet.name", [NSString class]);
    
    AssertStringFromClassReturnForPrimitiveCallOnObjectType(@"pet.name", @"NSString");
}

- (void)testKeyPathOfPrimitiveType {
    AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(@selector(JL_classForPropertyAtKeyPath:), @selector(JL_primitiveTypeForPropertyAtKeyPath:), @"pet.age", @"i");
}

- (void)testKeyPathOfTypedefPrimitiveType {
#if TARGET_OS_IPHONE
    NSString *primitiveTypeString = @"I";
#else
    NSString *primitiveTypeString = @"Q";
#endif

    AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(@selector(JL_classForPropertyAtKeyPath:), @selector(JL_primitiveTypeForPropertyAtKeyPath:), @"pet.petType", primitiveTypeString);
}

- (void)testInheritedProperty {
    AssertMethodReturnMatchesExpectedClass(@selector(JL_classForPropertyAtKeyPath:), @"fish.name", [NSString class]);
    
    AssertStringFromClassReturnForPrimitiveCallOnObjectType(@"fish.name", @"NSString");
    
    AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(@selector(JL_classForPropertyAtKeyPath:), @selector(JL_primitiveTypeForPropertyAtKeyPath:), @"fish.age", @"i");
#if TARGET_OS_IPHONE
    NSString *primitiveTypeString = @"I";
#else
    NSString *primitiveTypeString = @"Q";
#endif
    AssertClassMethodReturnNilAndPrimitiveMethodMatchesExpectedPrimitive(@selector(JL_classForPropertyAtKeyPath:), @selector(JL_primitiveTypeForPropertyAtKeyPath:), @"fish.petType", primitiveTypeString);
}

@end
