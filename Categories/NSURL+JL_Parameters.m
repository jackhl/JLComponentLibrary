//  Created by Jack Lawrence on 10/25/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "NSURL+JL_Parameters.h"

@interface NSURL (JL_ParametersInternal)

/*
 Creates a string of key-value pairs from the passed in dictionary where each
 key is separated from each value with an `=` (equal) sign and each pair is separated
 by an & (ampersand).
 
 @param parameters A dictionary of key-value pairs to turn into a URL parameter
 string.
 
 @return A string containing the parameters.
 */
+ (NSString *)JL_paramStringWithParameters:(NSDictionary *)parameters;

@end

@implementation NSURL (JL_ParametersInternal)

+ (NSString *)JL_paramStringWithParameters:(NSDictionary *)parameters {
    if ([parameters count] == 0) return @"";
    
    NSMutableArray *paramStrings = [NSMutableArray arrayWithCapacity:[parameters count]];
    for (NSString *key in parameters) {
        [paramStrings addObject:[NSString stringWithFormat:@"%@=%@", key, [parameters valueForKey:key]]];
    }
    
    return [paramStrings componentsJoinedByString:@"&"];
}

@end

@implementation NSURL (JL_Parameters)

+ (instancetype)JL_URLWithProtocol:(JL_URLProtocol)protocol domain:(NSString *)domain endpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters
{
#if DEBUG
    NSParameterAssert(domain != nil);
    NSParameterAssert(protocol == JL_URLProtocolHTTP || protocol == JL_URLProtocolHTTPS);
#endif
    
    NSString *urlString = [NSString stringWithFormat:
                           @"%@%@%@%@%@%@",
                           (protocol == JL_URLProtocolHTTP)?@"http://":(protocol == JL_URLProtocolHTTPS)?@"https://":@"",
                           domain?domain:@"",
                           endpoint?@"/":@"",
                           endpoint?endpoint:@"",
                           ([parameters count] != 0)?@"?":@"",
                           [self JL_paramStringWithParameters:parameters]];
    return [NSURL URLWithString:urlString];
}

@end
