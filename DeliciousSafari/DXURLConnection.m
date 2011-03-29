//
//  DXURLConnection.m
//  DeliciousSafari
//
//  Created by Doug on 12/6/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import "DXURLConnection.h"


@implementation DXURLConnection

@synthesize isUsingOAuth=mIsUsingOAuth;

-(id)initWithRequest:theRequest delegate:(id)delegate withResponseSelector:(SEL)responseSelector withExpectingXMLResponse:(BOOL)expectsXMLResponse isUsingOAuth:(BOOL)useOAuth
{
	self = [super initWithRequest:theRequest delegate:delegate];
	
	if(self)
	{
		mResponseSelector = responseSelector;
		mExpectingXMLResponse = expectsXMLResponse;
		mReceivedData = [[NSMutableData alloc] init];
		mIsUsingOAuth = useOAuth;
		mURLRequest = [theRequest copy];
		mDelegate = delegate;
	}
	
	return self;
}

-(void)dealloc
{
	[mURLRequest release];
	[mReceivedData release];
	[super dealloc];
}

-(SEL)responseSelector
{
	return mResponseSelector;
}

-(BOOL)expectingXMLResponse
{
	return mExpectingXMLResponse;
}

-(NSMutableData*)receivedData
{
	return mReceivedData;
}

- (DXURLConnection*)newRetryConnection
{	
	DXURLConnection *result = [[DXURLConnection alloc] initWithRequest:mURLRequest
															  delegate:mDelegate
												  withResponseSelector:mResponseSelector
											  withExpectingXMLResponse:mExpectingXMLResponse
														  isUsingOAuth:mIsUsingOAuth];
	
	assert(result);
	
	return result;
}

@end
