//
//  OEGCommitQueue.m
//  Libogen
//
//  Created by Anders Carlsson on 2009-09-10.
//  Copyright 2009 Önders et Gonas. All rights reserved.
//

// ÖeG Commit Queue
// ================
// Sends POST requests to a web backend in a robust way. Suspends queue when offline, persists queue between app launches.
// Requests that fail due to connectivity issues get resent when online again, in the correct order.

#import "OEGCommitQueue.h"


@implementation OEGCommitQueue

@synthesize httpRequester;

- (id)initWithHTTPRequester:(OEGCommitRequester *)requester {
	if(self = [super init]) {
		httpRequester = [requester retain];
		oq = [[NSOperationQueue new] retain];
		[oq setMaxConcurrentOperationCount:1];
		[oq setSuspended:YES];
	}
	
	return self;
}

- (id)init {
	return [self initWithHTTPRequester:[[OEGCommitRequester alloc] init]];
}

- (void)dealloc {
	[httpRequester release];
	[oq release];
	[super dealloc];
}

/*- (void)addCommitToEndpoint:(NSString *)endpoint data:(NSDictionary *)data reAdding:(BOOL)reAdding delegate:(id<OEGCommitQueueDelegate>)delegate {
	OEGCommitOperation *op = [[OEGCommitOperation alloc] initWithQueue:self endpoint:endpoint data:data delegate:delegate];
	if(reAdding)
		[op setQueuePriority:NSOperationQueuePriorityHigh];		// this just works in all cases if we have max 1 parallell operations rite?
	[oq addOperation:op];
	[op release];
}*/

- (void)addCommitToEndpoint:(NSString *)endpoint data:(NSDictionary *)data delegate:(id<OEGCommitQueueDelegate>)delegate {
	//[self addCommitToEndpoint:endpoint data:data reAdding:NO delegate:delegate];
	OEGCommitOperation *op = [[OEGCommitOperation alloc] initWithQueue:self endpoint:endpoint data:data delegate:delegate];
	[oq addOperation:op];
	[op release];
}

- (void)reAddOperation:(OEGCommitOperation *)op {
	OEGCommitOperation *newOp = [op operationForRetry];
	NSLog(@"Retrying operation… %d retries left, timeout is %f", newOp.retries, newOp.timeout);
	[newOp setQueuePriority:NSOperationQueuePriorityHigh];		// this just works in all cases if we have max 1 parallell operations rite?
	[oq addOperation:newOp];
}

// This is a bit gay. Is for testing purposes. Wouldn't be necessary if we used OCMock instead maybe?
- (NSArray *)queuedOperations {
	return [oq operations];
}

- (void)start {
	[oq setSuspended:NO];
}

- (void)suspend {
	[oq setSuspended:YES];
}

- (NSData *)serializeQueue {
	[self suspend];
	
	NSData *serializedData;
	NSString *errorString;
	NSMutableArray *ops = [[NSMutableArray alloc] init];
	
	for(OEGCommitOperation* co in [self queuedOperations]) {
		[ops addObject:[co serialize]];
	}
	
	serializedData = [NSPropertyListSerialization dataFromPropertyList:ops format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];
	[ops release];
	if(errorString != nil) {
		NSLog(@"Queue operation serialization error: %@", errorString);
		[errorString release];	// special case for dataFromPropertyList
		return nil;
	}
	
	[oq cancelAllOperations];		// empty the queue after serializing
	
	return serializedData;
}

- (void)deserializeQueue:(NSData *)serializedQueue {
	NSString *errorString;
	NSArray *arr = [NSPropertyListSerialization propertyListFromData:serializedQueue
																									mutabilityOption:NSPropertyListImmutable
																														format:NULL
																									errorDescription:&errorString];
	if(errorString != nil) {
		NSLog(@"Queue operation deserialization error: %@", errorString);
		[errorString release];
	} else {
		for(NSDictionary *dict in arr) {
			[self addCommitToEndpoint:[dict objectForKey:@"endpoint"] data:[dict objectForKey:@"data"] delegate:nil];
		}
	}
}

@end
