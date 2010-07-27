//
//  OEGCommitOperation.m
//  Libogen
//
//  Created by Anders Carlsson on 2009-09-10.
//  Copyright 2009 Önders et Gonas. All rights reserved.
//

#import "OEGCommitOperation.h"
#import "OEGCommitQueue.h"


@implementation OEGCommitOperation

@synthesize endpoint, timeout, retries;

- (id)initWithQueue:(OEGCommitQueue *)newQueue endpoint:(NSString *)newEndpoint data:(NSDictionary *)newData delegate:(id<OEGCommitQueueDelegate>)newDelegate {
	if(self = [super init]) {
		queue = [newQueue retain];
		endpoint = [newEndpoint retain];
		data = [newData retain];
		delegate = [newDelegate retain];

		timeout = 20.0;
		retries = 0;
		if(delegate != nil && [delegate respondsToSelector:@selector(initialConnectionTimeoutForCommitOperation)]) {
			timeout = [delegate initialConnectionTimeoutForCommitOperation];
		}
		if(delegate != nil && [delegate respondsToSelector:@selector(connectionRetriesForCommitOperation)]) {
			retries = [delegate connectionRetriesForCommitOperation];
		}
	}
	
	return self;
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return _isExecuting;
}

- (BOOL)isFinished {
	return _isFinished;
}

- (void)dealloc {
	[queue release];
	[endpoint release];
	[data release];
	[delegate release];
	
	[super dealloc];
}

- (NSDictionary *)serialize {
	return [[[NSDictionary alloc] initWithObjectsAndKeys:endpoint, @"endpoint", data, @"data", nil] autorelease];
}

- (void)start {
	// Because we use the asynchronous NSURLConnection API, we can run on the main thread. That way the thread used by the NSURLConnection won't
	// unexpectedly disappear due to the queue's thread management.
	if(![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
		return;
	}
	
	[self willChangeValueForKey:@"isExecuting"];
	_isExecuting = YES;
	[self didChangeValueForKey:@"isExecuting"];
	
	// this object is exchangeable for testing purposes
	[queue.httpRequester makeRequestToEndpoint:endpoint data:data delegate:delegate operation:self];
}

- (void)finishDidSucceed:(BOOL)success {
	NSLog(@"operation finished. success: %d", success);
	
	[self willChangeValueForKey:@"isExecuting"];
	_isExecuting = NO;
	[self didChangeValueForKey:@"isExecuting"];
	
	if(!success && retries > 0) {
		//[queue suspend];
		//[queue addCommitToEndpoint:endpoint data:data reAdding:YES delegate:delegate];
		[queue reAddOperation:self];
	}
	
	[self willChangeValueForKey:@"isFinished"];
	_isFinished = YES;
	[self didChangeValueForKey:@"isFinished"];
}

- (OEGCommitOperation *)operationForRetry {
	// Returns a copy of this operation for re-addition to the queue
	OEGCommitOperation *retryOp = [[OEGCommitOperation alloc] initWithQueue:queue endpoint:endpoint data:data delegate:delegate];
	
	retryOp.timeout = self.timeout * 1.5;
	retryOp.retries = self.retries - 1;
	
	return [retryOp autorelease];
}

@end
