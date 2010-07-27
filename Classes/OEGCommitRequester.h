//
//  OEGCommitRequester.h
//  Libogen
//
//  Created by Anders Carlsson on 2009-09-11.
//  Copyright 2009 Önders et Gonas. All rights reserved.
//

#import <Foundation/Foundation.h>


@class OEGCommitOperation;
@protocol OEGCommitQueueDelegate;


@interface OEGCommitRequester : NSObject {
	NSMutableData *receivedData;
	NSURLResponse *response;
	OEGCommitOperation *operation;
	
	id<OEGCommitQueueDelegate> delegate;
}

- (void)makeRequestToEndpoint:(NSString *)endpoint data:(NSDictionary *)data delegate:(id<OEGCommitQueueDelegate>)newDelegate operation:(NSOperation *)callingOperation;

@end
