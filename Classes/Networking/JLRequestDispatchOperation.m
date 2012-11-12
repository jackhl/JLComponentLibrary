//  Created by Jack Lawrence on 10/14/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLRequestDispatchOperation.h"

@interface JLRequestDispatchOperation ()

@property (nonatomic, readwrite, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) JLRequestProgress progress;
@property (nonatomic, strong) JLRequestCompletion completion;

@end

@implementation JLRequestDispatchOperation {
    BOOL _isLoadingRequest;
    BOOL _isFinished;
    long long _expectedContentLength;
    NSURLResponse *_response;
}

- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest progress:(JLRequestProgress)progress completion:(JLRequestCompletion)completion {
#if DEBUG
    NSParameterAssert(urlRequest != nil);
#endif
    self = [super init];
    if (self) {
        [self setUrlRequest:urlRequest];
        [self setProgress:progress];
        [self setCompletion:completion];
        _expectedContentLength = JLRequestDispatchOperationUnknownLength;
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
        // Under iOS 5 and above NSURLConnection + NSOperation has a bug where the run loop that the call to -start is executed in
        // ends as soon as the method returns and therefore the delegate callbacks fail to re-enter to run loop the NSOperation resides
        // on. Therefore you must either force the current run loop to stay alive or schedule in the main run loop which never exits
        // and then dispatch calls off of the main thread in the delegate callbacks.
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
        _expectedContentLength = JLRequestDispatchOperationUnknownLength;
    }
    else {
        _expectedContentLength = (NSInteger)[response expectedContentLength];
    }
#warning TODO Decide if I'm going to send along the response or expected content length or both. Look at AFNetworking etc.
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self data] appendData:data];
    if ([self progress]) {
        // Consumers should always assume that progress blocks get dispatched onto
        // a different thread than the main thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
