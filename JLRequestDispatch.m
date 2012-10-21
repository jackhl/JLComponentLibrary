//
//  RequestDispatch.m
//  Cascade
//
//  Created by Jack Lawrence on 10/7/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLRequestDispatch.h"

#import "JLRequestDispatchOperation.h"

NSString *const JLRequestDispatchNilArgumentError = @"JLRequestDispatchNilArgumentError";

NSString *const JLRequestDispatchInvalidArgumentError = @"JLRequestDispatchInvalidArgumentError";

@interface JLRequestDispatch ()

/* The concurrent operation queue that network requests are dispatched onto. */
@property (nonatomic, strong) NSOperationQueue *operationQueue;
/* The data cache. */
@property (nonatomic, strong) NSCache *resourceCache;

/*
 Retrieves the network dispatch singleton.
 
 @return The network dispatch singleton.
 */
+ (id)sharedDispatch;

/*
 Creates a string of key-value pairs from the passed in dictionary where each
 key is separated from each value with an `=` (equal) sign and each pair is separated
 by an & (ampersand).
 
 @param parameters A dictionary of key-value pairs to turn into a URL parameter string.
 
 @return A string containing the parameters.
 */
+ (NSString *)paramStringWithParameters:(NSDictionary *)parameters;

/*
 name sucks!
 needs to be commented
 */
+ (JLRequestCompletion)bindOrderedCompletion:(JLRequestOrderedCompletion)completion
                                         toSerialQueue:(dispatch_queue_t)serialQueue
                                       afterProcessing:(JLRequestProcessing)processing;

@end

@implementation JLRequestDispatch

+ (id)sharedDispatch
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

+ (NSString *)paramStringWithParameters:(NSDictionary *)parameters {
    if ([parameters count] == 0) return @"";
    
    NSMutableArray *paramStrings = [NSMutableArray arrayWithCapacity:[parameters count]];
    for (NSString *key in parameters) {
        [paramStrings addObject:[NSString stringWithFormat:@"%@=%@", key, [parameters valueForKey:key]]];
    }
    
    return [paramStrings componentsJoinedByString:@"&"];
}

+ (void)clearCache {
    [[[self sharedDispatch] resourceCache] removeAllObjects];
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

+ (void)dispatchRequestOnAPI:(NSString *)apiURL forEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)paramsOrNil completion:(JLRequestCompletion)completion
{
    [self dispatchRequestOnAPI:apiURL forEndpoint:endpoint withParameters:paramsOrNil shouldCache:NO completion:completion];
}

+ (void)dispatchRequestOnAPI:(NSString *)apiURL forEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)paramsOrNil processing:(JLRequestProcessing)processing serialQueue:(dispatch_queue_t)serialQueue orderedCompletion:(JLRequestOrderedCompletion)completion
{
    [self dispatchRequestOnAPI:apiURL forEndpoint:endpoint withParameters:paramsOrNil shouldCache:NO processing:processing serialQueue:serialQueue orderedCompletion:completion];
}

+ (void)dispatchRequestOnAPI:(NSString *)apiURL forEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)paramsOrNil shouldCache:(BOOL)shouldCache processing:(JLRequestProcessing)processing serialQueue:(dispatch_queue_t)serialQueue orderedCompletion:(JLRequestOrderedCompletion)completion
{
    JLRequestCompletion blockedBlock = [self bindOrderedCompletion:completion toSerialQueue:serialQueue afterProcessing:processing];
    
    [self dispatchRequestOnAPI:apiURL forEndpoint:endpoint withParameters:paramsOrNil shouldCache:shouldCache completion:blockedBlock];
}

+ (void)dispatchRequestOnAPI:(NSString *)apiURL forEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)paramsOrNil shouldCache:(BOOL)shouldCache completion:(JLRequestCompletion)completion {
    if (!apiURL) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:JLRequestDispatchNilArgumentError
                                                code:0
                                            userInfo:@{NSLocalizedDescriptionKey: @"You must provide a non-nil API URL key."}]);
        }
    }
    else if (!endpoint) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:JLRequestDispatchNilArgumentError
                                                code:0
                                            userInfo:@{NSLocalizedDescriptionKey: @"You must provide a non-nil endpoint."}]);
        }
    }
    else {
        NSString *urlString = [NSString stringWithFormat:
                               @"%@%@%@%@",
                               apiURL,
                               endpoint,
                               ([paramsOrNil count] != 0)?@"?":@"",
                               [self paramStringWithParameters:paramsOrNil]];
        
        NSData *dataObj = [[[self sharedDispatch] resourceCache] objectForKey:urlString];
        if (dataObj && completion) {
            completion(dataObj, nil);
        }
        else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[[self sharedDispatch] operationQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       if (shouldCache) {
                                           [[[self sharedDispatch] resourceCache] setObject:data forKey:urlString];
                                       }
                                       if (completion) {
                                           completion(data, error);
                                       }
                                   }];
        }
    }
}

+ (void)dispatchRequestForResourceAtURL:(NSURL *)url completion:(JLRequestCompletion)completion
{
    [self dispatchRequestForResourceAtURL:url shouldCache:NO completion:completion];
}

+ (void)dispatchRequestForResourceAtURL:(NSURL *)url shouldCache:(BOOL)shouldCache processing:(JLRequestProcessing)processing serialQueue:(dispatch_queue_t)serialQueue orderedCompletion:(JLRequestOrderedCompletion)completion
{
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
        [NSURLConnection sendAsynchronousRequest:request queue:[[self sharedDispatch] operationQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (shouldCache) {
                                       [[[self sharedDispatch] resourceCache] setObject:data forKey:[url absoluteString]];
                                   }
                                   if (completion) {
                                       completion(data, error);
                                   }
                               }];
    }
}

+ (JLRequestDispatchOperation *)dispatchManagableRequestOnAPI:(NSString *)apiURL forEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)paramsOrNil shouldCache:(BOOL)shouldCache timeoutInterval:(NSTimeInterval)timeout progress:(JLRequestProgress)progress processing:(JLRequestProcessing)processing serialQueue:(dispatch_queue_t)serialQueue orderedCompletion:(JLRequestOrderedCompletion)completion
{
    JLRequestCompletion blockedBlock = [self bindOrderedCompletion:completion toSerialQueue:serialQueue afterProcessing:processing];
    
    return [self dispatchManagableRequestOnAPI:apiURL forEndpoint:endpoint withParameters:paramsOrNil shouldCache:shouldCache timeoutInterval:timeout progress:progress completion:blockedBlock];
}

+ (JLRequestDispatchOperation *)dispatchManagableRequestOnAPI:(NSString *)apiURL forEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)paramsOrNil shouldCache:(BOOL)shouldCache timeoutInterval:(NSTimeInterval)timeout progress:(JLRequestProgress)progress completion:(JLRequestCompletion)completion
{
    NSString *urlString = [NSString stringWithFormat:
                           @"%@%@%@%@",
                           apiURL,
                           endpoint,
                           ([paramsOrNil count] != 0)?@"?":@"",
                           [self paramStringWithParameters:paramsOrNil]];
    NSURLRequestCachePolicy policy = shouldCache?NSURLRequestReturnCacheDataElseLoad:NSURLRequestReloadIgnoringLocalCacheData;
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:policy timeoutInterval:timeout];
    JLRequestDispatchOperation *dispatchOperation = [[JLRequestDispatchOperation alloc] initWithURLRequest:urlRequest progress:progress completion:completion];
    
    [[[self sharedDispatch] operationQueue] addOperation:dispatchOperation];
    
    return dispatchOperation;
}

+ (JLRequestDispatchOperation *)dispatchManagableRequestForResourceAtURL:(NSURL *)url shouldCache:(BOOL)shouldCache timeoutInterval:(NSTimeInterval)timeout progress:(JLRequestProgress)progress processing:(JLRequestProcessing)processing serialQueue:(dispatch_queue_t)serialQueue orderedCompletion:(JLRequestOrderedCompletion)completion
{
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
