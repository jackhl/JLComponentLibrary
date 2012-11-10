//
//  JLUNIT_RequestDispatchCommon.m
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 11/9/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLUNIT_RequestDispatchCommon.h"

@implementation NSURLRequest (SizedTestRequests)

+ (instancetype)JL_requestWithSize:(JLUNIT_RequestSize)size {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ipv4.download.thinkbroadband.com/%iMB.zip", size]]];
}

@end

@implementation JLUNIT_RequestDispatchCommon {
    BOOL _receivedData;
}

- (void)receivedData {
    _receivedData = YES;
}

- (void)tearDown {
    _receivedData = NO;
    
    [super tearDown];
}

// Inspired by http://www.mikeash.com/pyblog/friday-qa-2011-07-22-writing-unit-tests.html
- (void)spinUntilTrue:(BOOL (^)(void))block withTimeout:(NSTimeInterval)timeout {
    NSParameterAssert(block);
    
    NSTimeInterval start = [[NSProcessInfo processInfo] systemUptime];
    while (!block() && [[NSProcessInfo processInfo] systemUptime] - start <= timeout) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        if (_receivedData && [[NSProcessInfo processInfo] systemUptime] - start > 5) {
            timeout+=5;
            _receivedData = NO;
        }
    }
    STAssertTrue(block(), @"The network request timed out before completion.");
}

@end
