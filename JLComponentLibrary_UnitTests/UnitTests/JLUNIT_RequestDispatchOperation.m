//
//  JLUNIT_RequestDispatchOperation.m
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 11/8/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLUNIT_RequestDispatchOperation.h"

#import "JLUNIT_CommonMacros.h"

#import "JLRequestDispatchOperation.h"

@implementation JLUNIT_RequestDispatchOperation

// TODO use OCMock to mock network requests so everything always works regardless
// of actual network status, we can have controlled network failure/degration,
// and we can check received data sizes against expected actuals.

- (void)testParameterValidation {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    JLUNIT_AssertThrowsSpecificNamed([[JLRequestDispatchOperation alloc]
                                 initWithURLRequest:nil
                                 progress:nil
                                 completion:nil], NSException, NSInternalInconsistencyException, @"Passing nil for the first parameter (the URL request) should throw an exception when building for debug.");
    #pragma clang diagnostic pop
}

- (void)testSimpleURLRequestCompletion {
    __block BOOL finished = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
    JLRequestDispatchOperation *netOperation = [[JLRequestDispatchOperation alloc]
                                                initWithURLRequest:request
                                                progress:nil
                                                completion:^(NSData *data, NSError *error) {
                                                    JLUNIT_AssertCompleteData(data, error)
                                                    
                                                    finished = YES;
                                                }];
    [netOperation start];
    
    [self spinUntilTrue:^BOOL {
        return finished;
    }
            withTimeout:JLUNIT_kDefaultShortTimeout];
}

- (void)testRequestProgressAndCompletion {
    __block BOOL finished = NO;
    __block int numProgressExecute = 0;
    __block NSInteger expectedTotal = 0;
    NSURLRequest *request = [NSURLRequest JL_requestWithSize:JLUNIT_RequestSize20MB];
    JLRequestDispatchOperation *netOperation = [[JLRequestDispatchOperation alloc]
                                                initWithURLRequest:request
                                                progress:^(JLRequestDispatchOperation *operation, NSUInteger currBytes, NSInteger expectedTotalBytes) {
                                                    expectedTotal = expectedTotalBytes;
                                                    [self receivedData];
                                                    numProgressExecute++;
                                                    // doesn't print 100% :(
                                                    if (100.0f*(currBytes/(expectedTotalBytes*1.0f) > 98.0f) || numProgressExecute%500 == 0) {
                                                        NSLog(@"Progress: %i of %i bytes (%.2f%%).", currBytes, expectedTotalBytes, 100.0f*(currBytes/(expectedTotalBytes*1.0f)));
                                                    }
                                                }
                                                completion:^(NSData *data, NSError *error) {
                                                    JLUNIT_AssertCompleteData(data, error)
                                                    
                                                    NSLog(@"Complete: %i of expected %i bytes downloaded (%.2f%%).", [data length], expectedTotal, 100.0f*([data length]/(expectedTotal*1.0f)));
                                                    
                                                    finished = YES;
                                                }];
    [netOperation start];
    
    [self spinUntilTrue:^BOOL {
        return finished;
    }
            withTimeout:JLUNIT_kDefaultShortTimeout];
}

- (void)testLargeRequestProgressAndCompletion {
    __block BOOL finished = NO;
    __block int numProgressExecute = 0;
    __block NSInteger expectedTotal = 0;
    NSURLRequest *request = [NSURLRequest JL_requestWithSize:JLUNIT_RequestSize50MB];
    JLRequestDispatchOperation *netOperation = [[JLRequestDispatchOperation alloc]
                                                initWithURLRequest:request
                                                progress:^(JLRequestDispatchOperation *operation, NSUInteger currBytes, NSInteger expectedTotalBytes) {
                                                    expectedTotal = expectedTotalBytes;
                                                    [self receivedData];
                                                    numProgressExecute++;
                                                    // doesn't print 100% :(
                                                    if (100.0f*(currBytes/(expectedTotalBytes*1.0f) > 98.0f) || numProgressExecute%1000 == 0) {
                                                        NSLog(@"Progress: %i of %i bytes (%.2f%%).", currBytes, expectedTotalBytes, 100.0f*(currBytes/(expectedTotalBytes*1.0f)));
                                                    }
                                                }
                                                completion:^(NSData *data, NSError *error) {
                                                    JLUNIT_AssertCompleteData(data, error)
                                                    
                                                    NSLog(@"Complete: %i of expected %i bytes downloaded (%.2f%%).", [data length], expectedTotal, 100.0f*([data length]/(expectedTotal*1.0f)));
                                                    
                                                    finished = YES;
                                                }];
    [netOperation start];
    
    [self spinUntilTrue:^BOOL {
        return finished;
    }
            withTimeout:JLUNIT_kDefaultShortTimeout];
}

- (void)testMultipleRequestExecution {
    __block BOOL oneFinished = NO;
    __block BOOL twoFinished = NO;
    __block BOOL threeFinished = NO;
    NSURLRequest *requestOne = [NSURLRequest JL_requestWithSize:JLUNIT_RequestSize10MB];
    JLRequestDispatchOperation *netOperationOne = [[JLRequestDispatchOperation alloc]
                                                   initWithURLRequest:requestOne
                                                   progress:JLUNIT_ProgressReceivedData
                                                   completion:^(NSData *data, NSError *error) {
                                                       JLUNIT_AssertCompleteData(data, error)
                                                       
                                                       oneFinished = YES;
                                                       NSLog(@"Request one finished (%i/3).", oneFinished+twoFinished+threeFinished);
                                                   }];
    
    NSURLRequest *requestTwo = [NSURLRequest JL_requestWithSize:JLUNIT_RequestSize5MB];
    JLRequestDispatchOperation *netOperationTwo = [[JLRequestDispatchOperation alloc]
                                                   initWithURLRequest:requestTwo
                                                   progress:JLUNIT_ProgressReceivedData
                                                   completion:^(NSData *data, NSError *error) {
                                                       JLUNIT_AssertCompleteData(data, error)
                                                       
                                                       twoFinished = YES;
                                                       NSLog(@"Request two finished (%i/3).", oneFinished+twoFinished+threeFinished);
                                                   }];
    
    NSURLRequest *requestThree = [NSURLRequest JL_requestWithSize:JLUNIT_RequestSize20MB];
    JLRequestDispatchOperation *netOperationThree = [[JLRequestDispatchOperation alloc]
                                                     initWithURLRequest:requestThree
                                                     progress:JLUNIT_ProgressReceivedData
                                                     completion:^(NSData *data, NSError *error) {
                                                         JLUNIT_AssertCompleteData(data, error)
                                                         
                                                         threeFinished = YES;
                                                         NSLog(@"Request three finished (%i/3).", oneFinished+twoFinished+threeFinished);
                                                     }];
    [netOperationTwo start];
    [netOperationThree start];
    [netOperationOne start];
    
    [self spinUntilTrue:^BOOL {
        return (oneFinished && twoFinished && threeFinished);
    }
            withTimeout:JLUNIT_kDefaultShortTimeout];
}

@end
