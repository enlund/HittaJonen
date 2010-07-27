//
//  OEGCommitRequester.m
//  Libogen
//
//  Created by Anders Carlsson on 2009-09-11.
//  Copyright 2009 Önders et Gonas. All rights reserved.
//

#import "OEGCommitQueue.h"
#import "OEGCommitRequester.h"
#import "OEGCommitOperation.h"
#import "NSString+OEGUrlEncodingString.h"
#import "NSURLConnection+OEGMultipleAttempts.h"


@implementation OEGCommitRequester

- (void)makeRequestToEndpoint:(NSString *)endpoint data:(NSDictionary *)data delegate:(id<OEGCommitQueueDelegate>)newDelegate operation:(NSOperation *)callingOperation {
	// Determine if the data needs to be sent as multipart or not.
	// We require multipart objects to have value of NSDictionary format, with keys "filename", "mimetype" and "data" (key for obj irrelevant)
	// Other arguments, name-value pairs, are key = name, value = value (all NSStrings).
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	operation = [callingOperation retain];
	delegate = [newDelegate retain];
	
	BOOL multipart = NO;
	for(id<NSObject> thing in [data allValues]) {
		if([thing isKindOfClass:[NSDictionary class]]) {
			multipart = YES;
			break;
		}
	}
	
	NSURL *url = [NSURL URLWithString:endpoint];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:operation.timeout];
	
	if(multipart) {
		NSString *stringBoundary = @"-----------------------------178448449274243042114807987";
		[req setHTTPMethod:@"POST"];
		
		NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
		[req addValue:contentType forHTTPHeaderField:@"Content-type"];
		
		//adding the body:
		NSMutableData *postBody = [NSMutableData data];
		[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		for(NSString *key in [data allKeys]) {
			id<NSObject> value = [data objectForKey:key];
			if([value isKindOfClass:[NSDictionary class]]) {
				//NSLog(@"dictionary found yes");
				[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media\"; filename=\"%@\"\r\n", [(NSDictionary *)value objectForKey:@"filename"]] dataUsingEncoding:NSUTF8StringEncoding]];
				[postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", [(NSDictionary *)value objectForKey:@"mimetype"]] dataUsingEncoding:NSUTF8StringEncoding]];
				[postBody appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
				[postBody appendData:[(NSDictionary *)value objectForKey:@"data"]];
				[postBody appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			}
			if([value isKindOfClass:[NSString class]]) {
				//NSLog(@"string found yes");
				[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
				[postBody appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
				[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			}
		}
		
		//NSLog(@"postbody length %d", [postBody length]);
		
		[req setHTTPBody:postBody];
		[req setValue:@"ÖeG" forHTTPHeaderField:@"User-Agent"];
		[req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];		// to work around memory leak in sdk
		
		NSString *postLength = [NSString stringWithFormat:@"%d", [postBody length]];
		[req setValue:postLength forHTTPHeaderField:@"Content-Length"];
	} else {
		NSMutableString *post = [[NSMutableString alloc] init];
		
		int i = 0;
		for(NSString *key in [data allKeys]) {
			NSString *value = [data objectForKey:key];
			
			// add & to the end of all arguments except the last one.
			NSString *ampersand = @"";
			if(i != [data count])
				ampersand = @"&";
			
			[post appendFormat:@"%@=%@%@", [key urlEncodeValue], [value urlEncodeValue], ampersand];
			i++;
		}
		
		NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
		[post release];
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		
		[req setHTTPMethod:@"POST"];
		[req setValue:@"Basic ZW5sdW5kQGdtYWlsLmNvbTpzYW5kbWFubmVu" forHTTPHeaderField:@"Authorization"];
		[req setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[req setValue:@"ÖeG" forHTTPHeaderField:@"User-Agent"];
		[req setHTTPBody:postData];
		[req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	}
	
	//NSHTTPURLResponse *response = [[[NSHTTPURLResponse alloc] init] autorelease];
	//NSError *error = [[[NSError alloc] init] autorelease];
	
	receivedData = [[[NSMutableData alloc] init] retain];
	NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
	
	if(conn == nil) {
		[operation finishDidSucceed:YES];		// don't want to retry
	}
	
	[conn start];
	
	/*NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
	NSLog(@"Response status %d", [response statusCode]);
	NSLog(@"Response body = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if([error code] != 0) {
		NSLog(@"connection error in operation");
		return NO;
	} else {
		NSLog(@"Commit operation executed.");
		return YES;
	}*/
}

- (void)dealloc {
	[operation release];
	[receivedData release];
	[response release];
	[delegate release];
	[super dealloc];
}

#pragma mark Delegate methods for connection

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)newResponse {
	response = [newResponse retain];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	if(delegate != nil && [delegate respondsToSelector:@selector(sendingDataProcess:)]) {
		[delegate sendingDataProcess:(NSInteger)((float)totalBytesWritten/(float)totalBytesExpectedToWrite * 100)];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Response status %d", [(NSHTTPURLResponse *)response statusCode]);
	NSLog(@"Response body = %@", [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease]);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSLog(@"Commit operation executed.");
	if(delegate != nil && [delegate respondsToSelector:@selector(sendSuccess:)]) {
		[delegate sendSuccess:[(NSHTTPURLResponse *)response statusCode]];
	}
	
	[operation finishDidSucceed:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSLog(@"connection error in operation");
	
	if(operation.retries <= 0 && (delegate != nil && [delegate respondsToSelector:@selector(sendFailed:)])) {
		[delegate sendFailed:error];
	}
	
	[operation finishDidSucceed:NO];
	//[operation finishDidSucceed:YES];		// For Nattstad, we don't want to retry it
}

@end
