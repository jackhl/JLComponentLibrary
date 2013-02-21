//  Created by Jack Lawrence on 10/7/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLRequestDispatch.h"

#import "JLRequestDispatchOperation.h"

@interface JLRequestDispatch ()

/* The concurrent operation queue that network requests are dispatched onto. */
@property (nonatomic, strong) NSOperationQueue *operationQueue;
/* The data cache. */
@property (nonatomic, strong) NSCache *resourceCache;

/*
 Retrieves the network dispatch singleton.
 
 @return The network dispatch singleton.
 */
+ (instancetype)sharedDispatch;

/*
 name sucks!
 needs to be commented
 */
+ (JLRequestCompletion)bindOrderedCompletion:(JLRequestOrderedCompletion)completion
                               toSerialQueue:(dispatch_queue_t)serialQueue
                             afterProcessing:(JLRequestProcessing)processing;

@end

@implementation JLRequestDispatch

+ (instancetype)sharedDispatch
{
    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        [self setOperationQueue:opQueue];
        NSCache *cache = [[NSCache alloc] init];
        [self setResourceCache:cache];
    }
    return self;
}

+ (void)clearCache {
    [[[self sharedDispatch] resourceCache] removeAllObjects];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

+ (void)cancelAllRequests
{
    [[[self sharedDispatch] operationQueue] cancelAllOperations];
}

+ (JLRequestCompletion)bindOrderedCompletion:(JLRequestOrderedCompletion)completion toSerialQueue:(dispatch_queue_t)serialQueue afterProcessing:(JLRequestProcessing)processing
{
    __block id processedData = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    if (serialQueue) {
        dispatch_async(serialQueue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (completion) {
                completion(processedData);
            }
        });
    }
    
    return ^(NSData *data, NSError *error) {
        if (processing) {
            processedData = processing(data, error);
        }
        dispatch_semaphore_signal(semaphore);
    };
}

+ (void)dispatchRequestForResourceAtURL:(NSURL *)url shouldCache:(BOOL)shouldCache processing:(JLRequestProcessing)processing serialQueue:(dispatch_queue_t)serialQueue orderedCompletion:(JLRequestOrderedCompletion)completion
{
    // would this crash in production (non-debug)?
#if DEBUG
    NSParameterAssert(serialQueue != nil);
#endif
    JLRequestCompletion blockedBlock = [self bindOrderedCompletion:completion toSerialQueue:serialQueue afterProcessing:processing];
    
    [self dispatchRequestForResourceAtURL:url shouldCache:shouldCache completion:blockedBlock];
}

+ (void)dispatchRequestForResourceAtURL:(NSURL *)url shouldCache:(BOOL)shouldCache completion:(JLRequestCompletion)completion
{
    NSData *dataObj = [[[self sharedDispatch] resourceCache] objectForKey:[url absoluteString]];
    if (dataObj && completion) {
        completion(dataObj, nil);
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[[self sharedDispatch] operationQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (shouldCache && data) {
                                       [[[self sharedDispatch] resourceCache] setObject:data forKey:[url absoluteString]];
                                   }
                                   if (completion) {
                                       completion(data, error);
                                   }
                               }];
    }
}

+ (JLRequestDispatchOperation *)dispatchManagableRequestForResourceAtURL:(NSURL *)url shouldCache:(BOOL)shouldCache timeoutInterval:(NSTimeInterval)timeout progress:(JLRequestProgress)progress processing:(JLRequestProcessing)processing serialQueue:(dispatch_queue_t)serialQueue orderedCompletion:(JLRequestOrderedCompletion)completion
{
    // would this crash in production (non-debug)?
#if DEBUG
    NSParameterAssert(serialQueue != nil);
#endif
    JLRequestCompletion blockedBlock = [self bindOrderedCompletion:completion toSerialQueue:serialQueue afterProcessing:processing];
    
    return [self dispatchManagableRequestForResourceAtURL:url shouldCache:shouldCache timeoutInterval:timeout progress:progress completion:blockedBlock];
}

+ (JLRequestDispatchOperation *)dispatchManagableRequestForResourceAtURL:(NSURL *)url shouldCache:(BOOL)shouldCache timeoutInterval:(NSTimeInterval)timeout progress:(JLRequestProgress)progress completion:(JLRequestCompletion)completion
{
    NSURLRequestCachePolicy policy = shouldCache?NSURLRequestReturnCacheDataElseLoad:NSURLRequestReloadIgnoringLocalCacheData;
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url cachePolicy:policy timeoutInterval:timeout];
    JLRequestDispatchOperation *dispatchOperation = [[JLRequestDispatchOperation alloc] initWithURLRequest:urlRequest progress:progress completion:completion];
    
    [[[self sharedDispatch] operationQueue] addOperation:dispatchOperation];
    
    return dispatchOperation;
}

@end
