//
//  JLURLStringTransformer.m
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 1/10/13.
//  Copyright (c) 2013 Jack Lawrence. All rights reserved.
//

#import "JLURLStringTransformer.h"

@implementation JLURLStringTransformer

+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return [NSURL class];
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:value];
    }
    return nil;
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSURL class]]) {
        return [(NSURL *)value absoluteString];
    }
    return nil;
}

@end
