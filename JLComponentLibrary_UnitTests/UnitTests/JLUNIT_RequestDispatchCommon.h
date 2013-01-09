//
//  JLUNIT_RequestDispatchCommon.h
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 11/9/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#ifndef JLUNIT_RequestDispatchCommon_h
#define JLUNIT_RequestDispatchCommon_h

#define JLUNIT_AssertCompleteData(_data, _error) \
    STAssertNotNil(data, @"Expected non-nil NSData object in completion block. Received nil NSData object in completion block."); \
    STAssertNil(error, @"Expected no NSError in completion block. Received NSError with description: %@.", [error localizedDescription]); \
    STAssertTrue([data length] > 0, @"Expected NSData object containing data. Received NSData object containing no data.");

#define JLUNIT_ProgressReceivedData ^(JLRequestDispatchOperation *op, NSUInteger a, NSInteger b) { \
    [self receivedData]; \
}

#define JLUNIT_kDefaultShortTimeout 10

#endif

typedef NS_ENUM(NSUInteger, JLUNIT_RequestSize) {
    JLUNIT_RequestSize5MB    =    5,
    JLUNIT_RequestSize10MB   =   10,
    JLUNIT_RequestSize20MB   =   20,
    JLUNIT_RequestSize50MB   =   50,
    JLUNIT_RequestSize100MB  =  100,
    JLUNIT_RequestSize200MB  =  200,
    JLUNIT_RequestSize512MB  =  512,
    JLUNIT_RequestSize1000MB = 1000,
};

@interface NSURLRequest (SizedTestRequests)

+ (instancetype)JL_requestWithSize:(JLUNIT_RequestSize)size;

@end

@interface JLUNIT_RequestDispatchCommon : SenTestCase

/* Call wheneever you receive data in a progress update in a long running process (or use the `JLUNIT_ProgressReceivedData` block) so that the thread doesn't time out. */
- (void)receivedData;
- (void)spinUntilTrue:(BOOL (^)(void))block withTimeout:(NSTimeInterval)timeout;
// use the confirmation block to test any state that should be true at the end of execution or at timeout. Confirmation executes after the completion evaluation block.
- (void)spinUntilTrue:(BOOL (^)(void))block withTimeout:(NSTimeInterval)timeout confirmation:(void (^)(void))confirmation;

@end
