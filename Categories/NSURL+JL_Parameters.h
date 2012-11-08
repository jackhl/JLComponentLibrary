//  Created by Jack Lawrence on 10/25/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JL_URLProtocol) {
    JL_URLProtocolHTTP,
    JL_URLProtocolHTTPS
};

/**
 Extends NSURL to provide support for creating URLs with parameters.
 
 
 ##Typedefs
 
 ###JL_URLProtocol
 
 - `JL_URLProtocolHTTP`: The HTTP unsecured protocol, specified by prefixing a
 URL with the string `http://`.
 - `JL_URLProtocolHTTPS`: The HTTPS secured protocol, specified by prefixing a
 URL with the string `https://`.
 
 */
@interface NSURL (JL_Parameters)

/** @name Initialization */

/**
 Creates an NSURL by formatting and concatenating commonly dynamically joined
 URL components.
 
 Components are joined like so:
 `<protocol>domain/<endpoint>?key1=value1&key2=value2`
 
 @param protocol The protocol to use.
 @param domain The domain to place the request on. Do not end the domain with a
 forward slash.
 @param endpoint The endpoint to add to the end of the domain. Do not prefix the
 endpoint with a forward slash. Pass nil if the URL is simply the domain.
 @param parameters A dictionary of key-value pairs to append to the URL by adding
 a question mark (?) to the end of the URL and then separating each key from each
 value with an equal sign (=) and each pair with an ampersand (&). Pass nil if the
 URL does not take any parameters.
 
 @return A URL by joining the components passed in as method parameters.
 */
+ (instancetype)JL_URLWithProtocol:(JL_URLProtocol)protocol
                            domain:(NSString *)domain
                          endpoint:(NSString *)endpoint
                        parameters:(NSDictionary *)parameters;

@end
