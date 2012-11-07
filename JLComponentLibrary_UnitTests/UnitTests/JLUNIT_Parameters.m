//
//  JLUNIT_Parameters.m
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 11/7/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLUNIT_Parameters.h"

#import "NSURL+JL_Parameters.h"

#define AssertExpectedHost(_URLObject, _host) { \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject host], _host, @"Expected host @\"%@\" but got @\"%@\"", _host, [_URLObject host]); \
}

#define AssertExpectedAbsoluteURLString(_URLObject, _URLString) { \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject absoluteString], _URLString, @"Expected absolute URL string @\"%@\" but got @\"%@\"", _URLString, [_URLObject absoluteString]); \
}

#define AssertExpectedBaseURL(_URLObject, _baseURL) { \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject baseURL], _baseURL, @"Expected base URL %@ but got %@", _baseURL, [_URLObject baseURL]); /* does this print nicely? */ \
}

#define AssertExpectedFragment(_URLObject, _fragment) { \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject fragment], _fragment, @"Expected fragment @\"%@\" but got @\"%@\"", _fragment, [_URLObject fragment]); \
}

#define AssertExpectedLastPathComponent(_URLObject, _lastPathComponent) { \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject lastPathComponent], _lastPathComponent, @"Expected last path component @\"%@\" but got @\"%@\"", _lastPathComponent, [_URLObject lastPathComponent]); \
}


#define AssertExpectedParameterString(_URLObject, _parameterString) { \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject parameterString], _parameterString, @"Expected parameter string @\"%@\" but got @\"%@\"", _parameterString, [_URLObject parameterString]); \
}



@implementation JLUNIT_Parameters

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSimpleURL {
    NSURL *simpleURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"google.com" endpoint:nil parameters:nil];
    AssertExpectedHost(simpleURL, @"google.com");
    AssertExpectedAbsoluteURLString(simpleURL, @"http://google.com");
    AssertExpectedBaseURL(simpleURL, nil);
    AssertExpectedFragment(simpleURL, nil);
    AssertExpectedLastPathComponent(simpleURL, @"");
    AssertExpectedParameterString(simpleURL, nil);
}

- (void)testURLWithEndpoint {
    NSURL *endpointURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"google.com" endpoint:@"webhp" parameters:nil];
    AssertExpectedHost(endpointURL, @"google.com");
    AssertExpectedAbsoluteURLString(endpointURL, @"http://google.com/webhp");
    AssertExpectedBaseURL(endpointURL, nil);
    AssertExpectedFragment(endpointURL, nil);
    AssertExpectedLastPathComponent(endpointURL, @"webhp");
    AssertExpectedParameterString(endpointURL, nil);
}

@end
