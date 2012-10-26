//
//  NSURL+JL_Parameters.h
//  Cascade
//
//  Created by Jack Lawrence on 10/25/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum JL_URLProtocol {
    JL_URLProtocolHTTP,
    JL_URLProtocolHTTPS
} JL_URLProtocol;

@interface NSURL (JL_Parameters)

+ (id)JL_URLWithProtocol:(JL_URLProtocol)protocol domain:(NSString *)domain endpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters;

@end
