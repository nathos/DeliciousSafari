//
//  DXURLConnection.h
//  DeliciousSafari
//
//  Created by Doug on 12/6/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DXURLConnection : NSURLConnection
{
	NSMutableData *mReceivedData;
	SEL mResponseSelector;
	BOOL mExpectingXMLResponse;
	BOOL mIsUsingOAuth;
	NSURLRequest *mURLRequest;
	id mDelegate;
}

-(id)initWithRequest:theRequest delegate:(id)delegate withResponseSelector:(SEL)responseSelector withExpectingXMLResponse:(BOOL)expectsXMLResponse isUsingOAuth:(BOOL)useOAuth;

-(SEL)responseSelector;
-(BOOL)expectingXMLResponse;
-(NSMutableData*)receivedData;

@property(readonly) BOOL isUsingOAuth;

- (DXURLConnection*)newRetryConnection; // Create and start a new connection with the same parameters as this connection.

@end
