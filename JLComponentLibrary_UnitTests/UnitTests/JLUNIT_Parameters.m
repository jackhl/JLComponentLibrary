//
//  JLUNIT_Parameters.m
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 11/7/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLUNIT_Parameters.h"

#import "NSURL+JL_Parameters.h"

#define AssertExpectedHost(_URLObject, _host) \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject host], _host, @"Expected host @\"%@\" but got @\"%@\"", _host, [_URLObject host]);

#define AssertExpectedAbsoluteURLString(_URLObject, _URLString) \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject absoluteString], _URLString, @"Expected absolute URL string @\"%@\" but got @\"%@\"", _URLString, [_URLObject absoluteString]);

#define AssertExpectedBaseURL(_URLObject, _baseURL) \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject baseURL], _baseURL, @"Expected base URL %@ but got %@", _baseURL, [_URLObject baseURL]);

#define AssertExpectedFragment(_URLObject, _fragment) \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject fragment], _fragment, @"Expected fragment @\"%@\" but got @\"%@\"", _fragment, [_URLObject fragment]);

#define AssertExpectedLastPathComponent(_URLObject, _lastPathComponent) \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject lastPathComponent], _lastPathComponent, @"Expected last path component @\"%@\" but got @\"%@\"", _lastPathComponent, [_URLObject lastPathComponent]);


#define AssertExpectedParameterString(_URLObject, _parameterString) \
    STAssertNotNil(_URLObject, @"-[NSURL JL_URLWithProtocol:domain:endpoint:parameters:] returned a nil object."); \
    STAssertEqualObjects([_URLObject parameterString], _parameterString, @"Expected parameter string @\"%@\" but got @\"%@\"", _parameterString, [_URLObject parameterString]);

#define AssertExpected(_URLObject, _host, _URLString, _baseURL, _fragment, _lastPathComponent, _parameterString) \
    AssertExpectedHost(_URLObject, _host) \
    AssertExpectedAbsoluteURLString(_URLObject, _URLString) \
    AssertExpectedBaseURL(_URLObject, _baseURL) \
    AssertExpectedFragment(_URLObject, _fragment) \
    AssertExpectedLastPathComponent(_URLObject, _lastPathComponent) \
    AssertExpectedParameterString(_URLObject, _parameterString)

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

- (void)testParameterValidation {
    // nil domain
    NSLog(@"EXPECT ASSERTION FAILURE");
    STAssertThrowsSpecificNamed([NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:nil endpoint:nil parameters:nil],
                                NSException, NSInternalInconsistencyException,
                                @"+[NSURL JL_URLWithProtocol:domain:endpoint:parameters] did not bail when a nil domain parameter was specified.");
    // protocol out of bounds
    NSLog(@"EXPECT ASSERTION FAILURE");
    STAssertThrowsSpecificNamed([NSURL JL_URLWithProtocol:5 domain:@"example.com" endpoint:nil parameters:nil],
                                NSException, NSInternalInconsistencyException,
                                @"+[NSURL JL_URLWithProtocol:domain:endpoint:parameters] did not bail when an out of bounds protocol was specified.");
}

- (void)testSimpleURL {
    NSURL *simpleURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"example.com" endpoint:nil parameters:nil];
    AssertExpected(simpleURL, @"example.com", @"http://example.com", nil, nil, @"", nil);
}

- (void)testURLWithEndpoint {
    NSURL *endpointURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"example.com" endpoint:@"webhp" parameters:nil];
    AssertExpected(endpointURL, @"example.com", @"http://example.com/webhp", nil, nil, @"webhp", nil);
}

- (void)testURLWithParameterNoEndpoint {
    NSURL *paramURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"example.com" endpoint:nil parameters:@{@"query": @"cats"}];
    AssertExpected(paramURL, @"example.com", @"http://example.com?query=cats", nil, nil, @"", nil);
}

- (void)testURLWithParameterAndEndpoint {
    NSURL *paramURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"example.com" endpoint:@"images" parameters:@{@"query": @"cats"}];
    AssertExpected(paramURL, @"example.com", @"http://example.com/images?query=cats", nil, nil, @"images", nil);

}

- (void)testURLWithParametersNoEndpoint {
    NSURL *paramURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"example.com" endpoint:nil parameters:@{@"query": @"cats", @"imageSize": @"500px"}];
    AssertExpected(paramURL, @"example.com", @"http://example.com?query=cats&imageSize=500px", nil, nil, @"", nil);
}

- (void)testURLWithParametersAndEndpoint {
    NSURL *paramURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"example.com" endpoint:@"images" parameters:@{@"query": @"cats", @"imageSize": @"500px"}];
    AssertExpected(paramURL, @"example.com", @"http://example.com/images?query=cats&imageSize=500px", nil, nil, @"images", nil);
}

- (void)testURLWithParametersAndLongEndpoint {
    NSURL *paramURL = [NSURL JL_URLWithProtocol:JL_URLProtocolHTTP domain:@"example.com" endpoint:@"api/v1/images" parameters:@{@"query": @"cats", @"imageSize": @"500px"}];
    AssertExpected(paramURL, @"example.com", @"http://example.com/api/v1/images?query=cats&imageSize=500px", nil, nil, @"images", nil);
}

@end
