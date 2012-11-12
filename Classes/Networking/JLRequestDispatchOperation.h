//  Created by Jack Lawrence on 10/14/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JLRequestDispatchDefines.h"

#ifndef RequestDispatchOperation_h
#define RequestDispatchOperation_h

#define JLRequestDispatchOperationUnknownLength NSURLResponseUnknownLength

#endif

/**
 An NSOperation subclass that manages a single network request that is guaranteed
 to execute asynchronously.
 
 You are free to use this operation in the context of an NSOperationQueue or as a
 stand-alone asynchronous request executor. Call `-[NSOperation start]` if you are
 not using this object in the context of an NSOperationQueue.
 */
@interface JLRequestDispatchOperation : NSOperation <NSURLConnectionDataDelegate>

/** @name Properties */

/** The URL request to be executed. */
@property (nonatomic, readonly, strong) NSURLRequest *urlRequest;

/** @name Initialization */

/**
 Initializes the dispatch operation with a urlRequest, a periodic progress block,
 and a completion block.
 
 @param urlRequest The request to dispatch asynchronously.
 @param progress The progress block to invoke periodically when the connection
 has received more data. Passes in the RequestDispatchOperation object, the current
 length of the NSData object, and the _expected_ final length of the object. If
 the final length is unknown or zero, passes RequestDispatchOperationUnknownLength.
 @param completion The completion block to invoke when the network request returns.
 Passes in the received data, if any, and an NSError object (nil if no error).
 
 @return The initialized object.
 */
- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest
                          progress:(JLRequestProgress)progress
                        completion:(JLRequestCompletion)completion;

@end
