//
//  OEGCommitQueue.h
//  Libogen
//
//  Created by Anders Carlsson on 2009-09-10.
//  Copyright 2009 Önders et Gonas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OEGCommitOperation.h"
#import "OEGCommitRequester.h"


@interface OEGCommitQueue : NSObject {
	NSOperationQueue *oq;		// The actual operation queue
	OEGCommitRequester *httpRequester;		// object used to make http requests
}

@property (nonatomic, readonly) OEGCommitRequester *httpRequester;

- (id)initWithHTTPRequester:(OEGCommitRequester *)requester;
//- (void)addCommitToEndpoint:(NSString *)endpoint data:(NSDictionary *)data reAdding:(BOOL)reAdding delegate:(id<OEGCommitQueueDelegate>)delegate;
- (void)addCommitToEndpoint:(NSString *)endpoint data:(NSDictionary *)data delegate:(id<OEGCommitQueueDelegate>)delegate;
- (void)reAddOperation:(OEGCommitOperation *)op;
- (NSArray *)queuedOperations;
- (void)start;
- (void)suspend;
- (NSData *)serializeQueue;
- (void)deserializeQueue:(NSData *)serializedQueue;

@end


@protocol OEGCommitQueueDelegate <NSObject>

@optional
- (void)sendingDataProcess:(NSInteger)percent;
- (void)sendSuccess:(NSInteger)statusCode;
- (void)sendFailed:(NSError *)error;
- (NSTimeInterval)initialConnectionTimeoutForCommitOperation;
- (NSInteger)connectionRetriesForCommitOperation;

@end
