//
//  RequestDispatchOperation.m
//  Cascade
//
//  Created by Jack Lawrence on 10/14/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLRequestDispatchOperation.h"

@interface JLRequestDispatchOperation ()

@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) JLRequestProgress progress;
@property (nonatomic, strong) JLRequestCompletion completion;

@end

@implementation JLRequestDispatchOperation {
    BOOL _isLoadingRequest;
    BOOL _isFinished;
    long long _expectedContentLength;
}

- (id)initWithURLRequest:(NSURLRequest *)urlRequest progress:(JLRequestProgress)progress completion:(JLRequestCompletion)completion {
    self = [super init];
    if (self) {
        [self setUrlRequest:urlRequest];
        [self setProgress:progress];
        [self setCompletion:completion];
        _expectedContentLength = RequestDispatchOperationUnknownLength;
    }
    
    return self;
}

- (NSMutableData *)data {
    if (!_data) {
        [self setData:[NSMutableData data]];
    }
    
    return _data;
}

- (void)start {
    if (![self isCancelled]) {
        [self willChangeValueForKey:@"isExecuting"];
        _isLoadingRequest = YES;
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:[self urlRequest] delegate:self startImmediately:NO];
        [self setConnection:urlConnection];
        [[self connection] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [[self connection] start];
        [self didChangeValueForKey:@"isExecuting"];
    }
    else {
        [self willChangeValueForKey:@"isFinished"];
        _isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _isLoadingRequest;
}

- (BOOL)isFinished {
    return _isFinished;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self completion]) {
        // Consumers should always assume that completion blocks get dispatched onto
        // a different thread than the main thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
#warning If the operation is dealloced and [self completion] isn't block copied the completion block itself will be nil and we'll crash and burn.
            [self completion](nil, error);
        });
    }
    [self willChangeValueForKey:@"isExecuting"];
    _isLoadingRequest = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response expectedContentLength] == NSURLResponseUnknownLength) {
        _expectedContentLength = RequestDispatchOperationUnknownLength;
    }
    else {
        _expectedContentLength = (NSInteger)[response expectedContentLength];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self data] appendData:data];
    if ([self progress]) {
        // Consumers should always assume that progress blocks get dispatched onto
        // a different thread than the main thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
#warning I don't know if [self progress]/self/self.data/self.data.length/_expectedContentLength is getting block copied so it's possible that the request will finish, the operation will get dealloced, and then this block will fire and get nil for every parameter or the completion block itself will be nil and we'll crash and burn.
            [self progress](self, [[self data] length], _expectedContentLength);
        });
    }
}

- (void)cancel {
    [[self connection] cancel];
    [super cancel];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self completion]) {
        // Consumers should always assume that completion blocks get dispatched onto
        // a different thread than the main thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
#warning I don't know if [self data]/[self completion] is getting block copied so it's possible that the KVO notifications will execute, the operation will dealloc itself, and the completion block will get nil for [self data] or the completion block itself will be nil and we'll crash and burn.
            [self completion]([self data], nil);
        });
    }
    [self willChangeValueForKey:@"isExecuting"];
    _isLoadingRequest = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end
