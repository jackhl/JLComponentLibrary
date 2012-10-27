//
//  RequestDispatch.h
//  Cascade
//
//  Created by Jack Lawrence on 10/7/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JLRequestDispatchDefines.h"

@class JLRequestDispatchOperation;

/**
 Dispatches cachable threaded network requests with completion blocks.
 
 JLRequestDispatch is useful for "set it and forget it" network requests that need
 to execute discrete behavior on completion. JLRequestDispatch efficiently manages
 multiple concurrent threads as well as data caching among other nifty tools.
 
 While not strictly enforced, you should refrain from initializing your own instance
 of JLRequestDispatch and instead rely on the class methods provided.
 
 **To Do**:
 
 + Clean up NSError-related strings and enums as well as error-generating
 logic.
 + Grouped caches.
 + POST requests.
 + Dependency graphs.
 + Reachability.
 
 @note Block-based callbacks will never be called on the main thread so if you
 need to update UI you should dispatch a block with your UI updates onto the main
 thread.
 */
@interface JLRequestDispatch : NSObject

/** @name Request Dispatching */

/**
 Dispatches an asynchronous request for the resource at the specified URL.
 Executes a completion block when the request returns.
 
 @param url The URL to use in the network request.
 @param shouldCache Instructs the dispatcher whether or not it should cache (and
 attempt to retrieve from the cache) the data at the constructed URL.
 @param completion The completion block to invoke when the network request
 returns. Passes in the received data, if any, and an NSError object (nil if no
 error).
 */
+ (void)dispatchRequestForResourceAtURL:(NSURL *)url
                            shouldCache:(BOOL)shouldCache
                             completion:(JLRequestCompletion)completion;

/**
 Dispatches an asynchronous request for the resource at the specified URL.
 Executes a completion block when the request returns.
 
 Useful for when you want requests to execute concurrently but you want completion
 blocks to execute in the order you initiated the requests. For example, you could
 concurrently download and parse several paged JSON requests at the same time but
 add data to a UITableView in the request order. Note that the processing block
 executes in the background. It should do all of the heavy lifting to turn the
 received data into a form that can be quickly consumed in an ordered manner
 when the completion block executes, or it should handle the error or pass it along
 to the completion block.
 
 @param url The URL to use in the network request.
 @param shouldCache Instructs the dispatcher whether or not it should cache (and
 attempt to retrieve from the cache) the data at the constructed URL.
 @param processing The processing block to invoke when the network request
 returns. Passes in the received data, if any, and an NSError object (nil if no
 error). You should return the processed data from the block, ready to be passed
 into the completion block.
 @param serialQueue The serial dispatch queue to order completion blocks in. You
 are free to add your own blocks to the queue. You should pass in the same serial
 queue for every request in which the completion block must execute in the request
 order. Passing in a concurrent dispatch queue results in undefined behavior.
 @param completion The completion block to invoke when the network request
 returns and any previous blocks in the passed in serial queue have completed.
 Passes in the processed data.
 */
+ (void)dispatchRequestForResourceAtURL:(NSURL *)url
                            shouldCache:(BOOL)shouldCache
                             processing:(JLRequestProcessing)processing
                            serialQueue:(dispatch_queue_t)serialQueue
                      orderedCompletion:(JLRequestOrderedCompletion)completion;

/** @name Managable Request Dispatching */

/**
 Dispatches a managable asynchronous request for the resource at the specified
 URL. Periodically calls a progress block with the amount of data downloaded and
 executes a completion block when the request finishes. Allows management of
 progress, cancellation, and timeout.
 
 @param url The URL to use in the network request.
 @param shouldCache Instructs the dispatcher whether or not it should cache (and
 attempt to retrieve from the cache) the data at the constructed URL.
 @param timeout The amount of time to wait before the connection fails.
 @param progress The progress block to invoke periodically when the connection
 has received more data. Passes in the RequestDispatchOperation object, the
 current length of the NSData object, and the _expected_ final length of the
 object. If the final length is unknown or zero, passes
 RequestDispatchOperationUnknownLength.
 @param completion The completion block to invoke when the network request
 returns. Passes in the received data, if any, and an NSError object (nil if no
 error).
 
 @return The operation queued to execute the network request. Useful for when
 you want to cancel a request.
 */
+ (JLRequestDispatchOperation *)dispatchManagableRequestForResourceAtURL:(NSURL *)url
                                                             shouldCache:(BOOL)shouldCache
                                                         timeoutInterval:(NSTimeInterval)timeout
                                                                progress:(JLRequestProgress)progress
                                                              completion:(JLRequestCompletion)completion;

/**
 Dispatches a managable asynchronous request for the resource at the specified
 URL. Periodically calls a progress block with the amount of data downloaded and
 executes a completion block when the request finishes. Allows management of
 progress, cancellation, and timeout.
 
 Useful for when you want requests to execute concurrently but you want completion
 blocks to execute in the order you initiated the requests. For example, you could
 concurrently download and parse several paged JSON requests at the same time but
 add data to a UITableView in the request order. Note that the processing block
 executes in the background. It should do all of the heavy lifting to turn the
 received data into a form that can be quickly consumed in an ordered manner
 when the completion block executes, or it should handle the error or pass it along
 to the completion block.
 
 @param url The URL to use in the network request.
 @param shouldCache Instructs the dispatcher whether or not it should cache (and
 attempt to retrieve from the cache) the data at the constructed URL.
 @param timeout The amount of time to wait before the connection fails.
 @param progress The progress block to invoke periodically when the connection
 has received more data. Passes in the RequestDispatchOperation object, the
 current length of the NSData object, and the _expected_ final length of the
 object. If the final length is unknown or zero, passes
 RequestDispatchOperationUnknownLength.
 @param progress The progress block to invoke periodically when the connection
 has received more data. Passes in the RequestDispatchOperation object, the
 current length of the NSData object, and the _expected_ final length of the
 object. If the final length is unknown or zero, passes
 RequestDispatchOperationUnknownLength.
 @param processing The processing block to invoke when the network request
 returns. Passes in the received data, if any, and an NSError object (nil if no
 error). You should return the processed data from the block, ready to be passed
 into the completion block.
 @param serialQueue The serial dispatch queue to order completion blocks in. You
 are free to add your own blocks to the queue. You should pass in the same serial
 queue for every request in which the completion block must execute in the request
 order. Passing in a concurrent dispatch queue results in undefined behavior.
 @param completion The completion block to invoke when the network request
 returns. Passes in the received data, if any, and an NSError object (nil if no
 error).
 
 @return The operation queued to execute the network request. Useful for when
 you want to cancel a request.
 */

+ (JLRequestDispatchOperation *)dispatchManagableRequestForResourceAtURL:(NSURL *)url
                                                             shouldCache:(BOOL)shouldCache
                                                         timeoutInterval:(NSTimeInterval)timeout
                                                                progress:(JLRequestProgress)progress
                                                              processing:(JLRequestProcessing)processing
                                                             serialQueue:(dispatch_queue_t)serialQueue
                                                       orderedCompletion:(JLRequestOrderedCompletion)completion;

/** @name Cache Management */

/** Flushes the cache. */
+ (void)clearCache;

/** @name Request Management */

/** Cancels all scheduled and currently executing requests */
+ (void)cancelAllRequests;

@end
