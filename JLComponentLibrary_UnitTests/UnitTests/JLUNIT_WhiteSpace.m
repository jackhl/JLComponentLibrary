//
//  JLUNIT_WhiteSpace.m
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 11/12/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLUNIT_WhiteSpace.h"

#import "NSString+JL_WhiteSpace.h"

#define AssertWhiteSpaceOrNil(_string) \
    STAssertFalse([(NSString *)_string JL_isNotWhiteSpaceOrNil], @"Expected -[NSString JL_isNotWhiteSpaceOrNil] to return false for string '%@' but got true.", _string);

#define AssertNotWhiteSpaceOrNil(_string) \
    STAssertTrue([(NSString *)_string JL_isNotWhiteSpaceOrNil], @"Expected -[NSString JL_isNotWhiteSpaceOrNil] to return true for string '%@' but got false.", _string);

static char RandomChar() {
    // random spaces dispersed to increase white space occurence.
    static const char *kCharacterSet = "!\"#$%&'()*+,-./01234 56789  :;<=>?@ABCD  EFGHIJKLMNOP        QRSTUVWXYZ[\\]^_`abc    defghijklmnopqrstuvwxyz{|}   ~\n\t";
    static const int kCharacterSetLength = 116;
    u_int32_t r = arc4random() % kCharacterSetLength;
    return kCharacterSet[r];
}

static BOOL CharIsWhiteSpace(char character) {
    return (character == ' ' || character == '\n' || character == '\t');
}

@implementation JLUNIT_WhiteSpace

// random string of length returns a random string and ensures that at least one character is not whitespace.
- (NSString *)randomStringOfLength:(NSUInteger)len {
    if (len == 0) return @"";
    
    BOOL hasUsedNotWhitespaceCharacter = NO;
    NSMutableString *randomString = [[NSMutableString alloc] initWithCapacity:len];
    for (int i = 0; i < len-1; i++) {
        char c = RandomChar();
        [randomString appendFormat:@"%c", c];
        if (!CharIsWhiteSpace(c)) {
            hasUsedNotWhitespaceCharacter = YES;
        }
    }
    
    char ensureNotAllWhiteSpaceChar = RandomChar();
    while (!hasUsedNotWhitespaceCharacter && CharIsWhiteSpace(ensureNotAllWhiteSpaceChar)) {
        ensureNotAllWhiteSpaceChar = RandomChar();
    }
    [randomString appendFormat:@"%c", ensureNotAllWhiteSpaceChar];
    
    return randomString;
}


// At some point we're just testing that foundation methods are working so I'm
// not going to go overboard.


- (void)testNilString {
    AssertWhiteSpaceOrNil(nil);
}

- (void)testEmptyString {
    AssertWhiteSpaceOrNil(@"");
}

- (void)testOneCharNoWhiteSpaceString {
    AssertNotWhiteSpaceOrNil(@"a");
    AssertNotWhiteSpaceOrNil(@"™");
}

- (void)testCharWhiteSpaceMixString {
    for (int i = 0; i < 10000; i++) {
        NSString *testString = [self randomStringOfLength:MAX(2,arc4random()%200)];
        AssertNotWhiteSpaceOrNil(testString);
    }
}

@end
