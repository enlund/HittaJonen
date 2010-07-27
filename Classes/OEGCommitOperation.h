//
//  OEGCommitOperation.h
//  Libogen
//
//  Created by Anders Carlsson on 2009-09-10.
//  Copyright 2009 Önders et Gonas. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OEGCommitQueue;
@protocol OEGCommitQueueDelegate;


@interface OEGCommitOperation : NSOperation {
	NSString *endpoint;		// http address
	NSDictionary *data;		// post data
	OEGCommitQueue *queue;	// we use this to re-add ourselves if the operation failed
	id<OEGCommitQueueDelegate> delegate;
	
	NSTimeInterval timeout;
	NSInteger retries;
	
	BOOL _isExecuting, _isFinished;
}

@property (nonatomic, readonly) NSString *endpoint;		// for testing purposes
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, assign) NSInteger retries;

- (id)initWithQueue:(OEGCommitQueue *)newQueue endpoint:(NSString *)newEndpoint data:(NSDictionary *)newData delegate:(id<OEGCommitQueueDelegate>)delegate;
- (void)start;
- (void)finishDidSucceed:(BOOL)success;
- (NSDictionary *)serialize;
- (OEGCommitOperation *)operationForRetry;

@end
