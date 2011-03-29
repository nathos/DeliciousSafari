//
//  DXYahooOAuth.h
//  DeliciousSafari
//
//  Created by Doug on 12/7/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OAuthConsumer/OAuthConsumer.h>
#import "DXDeliciousDatabase.h"

@interface DXYahooOAuthManager : NSObject
{
	OAConsumer*	mConsumer;
	OAToken*	mRequestToken;
	DXDeliciousDatabase* mDatabase;
}

+ (DXYahooOAuthManager*)sharedOAuth;
- (id)initWithConsumerKey:(NSString*)consumerKey withSharedSecret:(NSString*)sharedSecret withDatabase:(DXDeliciousDatabase*)database;

- (void)obtainAuthorizationToken;
- (void)obtainAccessToken:(NSString*)verifier;
- (void)refreshAccessToken;

- (OAMutableURLRequest*)oaRequestFromURLRequest:(NSURLRequest*)urlRequest;

- (BOOL)isOAuthLoggedIn;
@end

// Notifications and userInfo keys related to Yahoo OAuth
extern NSString* kDXOAuth_AuthorizationErrorNotification;

extern NSString* kDXOAuth_ReceivedAuthorizationTokenNotification;
extern NSString* kDXOAuth_RequestURLKey;

extern NSString* kDXOAuth_ReceivedAccessTokenNotification;