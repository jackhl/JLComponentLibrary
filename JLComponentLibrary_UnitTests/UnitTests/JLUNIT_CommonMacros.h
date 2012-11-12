//
//  JLUNIT_CommonMacros.h
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 11/9/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#ifndef JLComponentLibrary_UnitTests_JLUNIT_CommonMacros_h
#define JLComponentLibrary_UnitTests_JLUNIT_CommonMacros_h

/* 
 * Basically the problem is that STAssertThrowsSpecificNamed(...) prints a big assertion warning
 * when an assertion does not pass, even though in this case I'm specifically trying to check
 * to make sure that the expression does in fact throw an exception. It leads to some confusing
 * logs where OCUnit says that the test passed but immediately before that it says an assertion
 * failed. This leads to some confusion over whether the assertion failure was related to the
 * test or other code. Eventually I should try to make this cleaner.
 */
#define JLUNIT_AssertThrowsSpecificNamed(_expr, _specificException, _aName, _description, ...) \
    NSLog(@"EXPECT RAISE ASSERTION"); \
    STAssertThrowsSpecificNamed(_expr, _specificException, _aName, _description, ##__VA_ARGS__)
#endif
