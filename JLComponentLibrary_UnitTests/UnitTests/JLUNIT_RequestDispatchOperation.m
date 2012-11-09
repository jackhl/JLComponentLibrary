//
//  JLUNIT_RequestDispatchOperation.m
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 11/8/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLUNIT_RequestDispatchOperation.h"

#import "JLRequestDispatchOperation.h"

#define AssertCompleteData(_data, _error) \
    STAssertNotNil(data, @"Expected non-nil NSData object in completion block. Received nil NSData object in completion block."); \
    STAssertNil(error, @"Expected no NSError in completion block. Received NSError with description: %@.", [error localizedDescription]); \
    STAssertTrue([data length] > 0, @"Expected NSData object containing data. Received NSData object containing no data.");

#define kDefaultShortTimeout 10

typedef NS_ENUM(NSUInteger, JLRequestSize) {
    JLRequestSize5MB    =    5,
    JLRequestSize10MB   =   10,
    JLRequestSize20MB   =   20,
    JLRequestSize50MB   =   50,
    JLRequestSize100MB  =  100,
    JLRequestSize200MB  =  200,
    JLRequestSize512MB  =  512,
    JLRequestSize1000MB = 1000,
};

@interface NSURLRequest (SizedTestRequests)

+ (instancetype)JL_requestWithSize:(JLRequestSize)size;

@end

@implementation NSURLRequest (SizedTestRequests)

+ (instancetype)JL_requestWithSize:(JLRequestSize)size {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ipv4.download.thinkbroadband.com/%iMB.zip", size]]];
}

@end

@implementation JLUNIT_RequestDispatchOperation {
    BOOL _receivedData;
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

// TODO use OCMock to mock network requests so everything always works regardless
// of actual network status, we can have controlled network failure/degration,
// and we can check received data sizes against expected actuals.

- (void)testParameterValidation {

    NSLog(@"EXPECT ASSERTION FAILURE");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    STAssertThrowsSpecificNamed([[JLRequestDispatchOperation alloc]
                                 initWithURLRequest:nil
                                 progress:nil
                                 completion:nil], NSException, NSInternalInconsistencyException, @"");
    #pragma clang diagnostic pop
}

- (void)testSimpleURLRequestCompletion {
    __block BOOL finished = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
    JLRequestDispatchOperation *netOperation = [[JLRequestDispatchOperation alloc]
                                                initWithURLRequest:request
                                                progress:nil
                                                completion:^(NSData *data, NSError *error) {
                                                    AssertCompleteData(data, error)
                                                    
                                                    finished = YES;
                                                }];
    [netOperation start];
    
    [self spinUntilTrue:^BOOL {
        return finished;
    }
            withTimeout:kDefaultShortTimeout];
}

- (void)testRequestProgressAndCompletion {
    __block BOOL finished = NO;
    __block int numProgressExecute = 0;
    __block NSInteger expectedTotal = 0;
    NSURLRequest *request = [NSURLRequest JL_requestWithSize:JLRequestSize20MB];
    JLRequestDispatchOperation *netOperation = [[JLRequestDispatchOperation alloc]
                                                initWithURLRequest:request
                                                progress:^(JLRequestDispatchOperation *operation, NSUInteger currBytes, NSInteger expectedTotalBytes) {
                                                    expectedTotal = expectedTotalBytes;
                                                    _receivedData = YES;
                                                    numProgressExecute++;
                                                    // doesn't print 100% :(
                                                    if (100.0f*(currBytes/(expectedTotalBytes*1.0f) > 98.0f) || numProgressExecute%500 == 0) {
                                                        NSLog(@"Progress: %i of %i bytes (%.2f%%).", currBytes, expectedTotalBytes, 100.0f*(currBytes/(expectedTotalBytes*1.0f)));
                                                    }
                                                }
                                                completion:^(NSData *data, NSError *error) {
                                                    AssertCompleteData(data, error)
                                                    
                                                    NSLog(@"Complete: %i of expected %i bytes downloaded (%.2f%%).", [data length], expectedTotal, 100.0f*([data length]/(expectedTotal*1.0f)));
                                                    
                                                    finished = YES;
                                                }];
    [netOperation start];
    
    [self spinUntilTrue:^BOOL {
        return finished;
    }
            withTimeout:kDefaultShortTimeout];
}

- (void)testLargeRequestProgressAndCompletion {
    __block BOOL finished = NO;
    __block int numProgressExecute = 0;
    __block NSInteger expectedTotal = 0;
    NSURLRequest *request = [NSURLRequest JL_requestWithSize:JLRequestSize50MB];
    JLRequestDispatchOperation *netOperation = [[JLRequestDispatchOperation alloc]
                                                initWithURLRequest:request
                                                progress:^(JLRequestDispatchOperation *operation, NSUInteger currBytes, NSInteger expectedTotalBytes) {
                                                    expectedTotal = expectedTotalBytes;
                                                    _receivedData = YES;
                                                    numProgressExecute++;
                                                    // doesn't print 100% :(
                                                    if (100.0f*(currBytes/(expectedTotalBytes*1.0f) > 98.0f) || numProgressExecute%1000 == 0) {
                                                        NSLog(@"Progress: %i of %i bytes (%.2f%%).", currBytes, expectedTotalBytes, 100.0f*(currBytes/(expectedTotalBytes*1.0f)));
                                                    }
                                                }
                                                completion:^(NSData *data, NSError *error) {
                                                    AssertCompleteData(data, error)
                                                    
                                                    NSLog(@"Complete: %i of expected %i bytes downloaded (%.2f%%).", [data length], expectedTotal, 100.0f*([data length]/(expectedTotal*1.0f)));
                                                    
                                                    finished = YES;
                                                }];
    [netOperation start];
    
    [self spinUntilTrue:^BOOL {
        return finished;
    }
            withTimeout:kDefaultShortTimeout];
}

- (void)testMultipleRequestExecution {
    __block BOOL oneFinished = NO;
    __block BOOL twoFinished = NO;
    __block BOOL threeFinished = NO;
    NSURLRequest *requestOne = [NSURLRequest JL_requestWithSize:JLRequestSize10MB];
    JLRequestDispatchOperation *netOperationOne = [[JLRequestDispatchOperation alloc]
                                                   initWithURLRequest:requestOne
                                                   progress:^(JLRequestDispatchOperation *op, NSUInteger a, NSInteger b) {
                                                       _receivedData = YES;
                                                   }
                                                   completion:^(NSData *data, NSError *error) {
                                                       AssertCompleteData(data, error)
                                                       
                                                       oneFinished = YES;
                                                       NSLog(@"Request one finished (%i/3).", oneFinished+twoFinished+threeFinished);
                                                   }];
    
    NSURLRequest *requestTwo = [NSURLRequest JL_requestWithSize:JLRequestSize5MB];
    JLRequestDispatchOperation *netOperationTwo = [[JLRequestDispatchOperation alloc]
                                                   initWithURLRequest:requestTwo
                                                   progress:^(JLRequestDispatchOperation *op, NSUInteger a, NSInteger b) {
                                                       _receivedData = YES;
                                                   }
                                                   completion:^(NSData *data, NSError *error) {
                                                       AssertCompleteData(data, error)
                                                       
                                                       twoFinished = YES;
                                                       NSLog(@"Request two finished (%i/3).", oneFinished+twoFinished+threeFinished);
                                                   }];
    
    NSURLRequest *requestThree = [NSURLRequest JL_requestWithSize:JLRequestSize20MB];
    JLRequestDispatchOperation *netOperationThree = [[JLRequestDispatchOperation alloc]
                                                     initWithURLRequest:requestThree
                                                     progress:^(JLRequestDispatchOperation *op, NSUInteger a, NSInteger b) {
                                                         _receivedData = YES;
                                                     }
                                                     completion:^(NSData *data, NSError *error) {
                                                         AssertCompleteData(data, error)
                                                         
                                                         threeFinished = YES;
                                                         NSLog(@"Request three finished (%i/3).", oneFinished+twoFinished+threeFinished);
                                                     }];
    [netOperationTwo start];
    [netOperationThree start];
    [netOperationOne start];
    
    [self spinUntilTrue:^BOOL {
        return (oneFinished && twoFinished && threeFinished);
    }
            withTimeout:kDefaultShortTimeout];
}

@end
