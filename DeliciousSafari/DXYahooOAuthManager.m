//
//  DXYahooOAuth.m
//  DeliciousSafari
//
//  Created by Doug on 12/7/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import "DXYahooOAuthManager.h"
#import "DXUtilities.h"

NSString* kDXOAuth_AuthorizationErrorNotification = @"YahooOAuth_AuthorizationError";
NSString* kDXOAuth_ReceivedAuthorizationTokenNotification = @"YahooOAuth_ReceivedAuthToken";
NSString* kDXOAuth_RequestURLKey = @"AuthRequestURL";
NSString* kDXOAuth_ReceivedAccessTokenNotification = @"YahooOAuth_ReceivedAccessToken";

static DXYahooOAuthManager* _sharedYahooOAuth;

static NSString* MyOAuthConsumerKey(void);
static NSString* MyOAuthSharedSecret(void);
static NSDictionary* dictionaryFromURLParameters(NSString* responseData);

#define kYahooAPIRealm @"yahooapis.com"


@interface DXYahooOAuthManager()

- (void)postAuthErrorNotification;

@property(retain) OAToken* requestToken;
@property(retain) OAConsumer* consumer;
@end


@implementation DXYahooOAuthManager

@synthesize requestToken=mRequestToken, consumer=mConsumer;

+ (void)initialize
{
	static BOOL isInitialized = NO;
	
	if (!isInitialized)
	{
		isInitialized = YES;
		_sharedYahooOAuth = [[DXYahooOAuthManager alloc] initWithConsumerKey:MyOAuthConsumerKey()
															withSharedSecret:MyOAuthSharedSecret()
																withDatabase:[DXDeliciousDatabase defaultDatabase]];
	}
}

+ (DXYahooOAuthManager*)sharedOAuth
{
	return _sharedYahooOAuth;
}

- (id)initWithConsumerKey:(NSString*)consumerKey withSharedSecret:(NSString*)sharedSecret withDatabase:(DXDeliciousDatabase*)database
{
	self = [super init];
	
	if (self)
	{
		mConsumer = [[OAConsumer alloc] initWithKey:MyOAuthConsumerKey() secret:MyOAuthSharedSecret()];
		mDatabase = [database retain];
	}
	
	return self;
}

- (void)dealloc
{
	[mConsumer release];
	[mRequestToken release];
	[mDatabase release];
	[super dealloc];
}

- (void)obtainAuthorizationToken
{
	NSURL *url = [NSURL URLWithString:@"https://api.login.yahoo.com/oauth/v2/get_request_token"];
	
	OAPlaintextSignatureProvider *plaintextProvider = [[OAPlaintextSignatureProvider new] autorelease];
	
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:mConsumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:kYahooAPIRealm
                                                          signatureProvider:plaintextProvider]; // use the default method, HMAC-SHA1
	
    [request setHTTPMethod:@"POST"];
	[request setOAuthParameterName:@"oauth_callback" withValue:@"delicioussafari:oauth"];
	
	
#warning Convert this to an asynchornous request but make sure OAAsynchronousDataFetcher does memory management properly.
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestAuthorizationTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestAuthorizationTokenTicket:didFailWithError:)];
	
	[fetcher release];
	[request release];
}

- (void)requestAuthorizationTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"OAuth authorization error: %@", error);
	[self postAuthErrorNotification];
}


- (void)requestAuthorizationTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	MAIN_THREAD_CHECK();
	
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		self.requestToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
		
		NSLog(@"Got a request token from Yahoo: %@", self.requestToken);
		
		NSDictionary *oauthResultDict = dictionaryFromURLParameters(responseBody);
		
		NSString *requestAuthURLString = [[oauthResultDict objectForKey:@"xoauth_request_auth_url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		assert(requestAuthURLString);
		NSURL *requestAuthURL = [NSURL URLWithString:requestAuthURLString];
		assert(requestAuthURL);
		
		//NSLog(@"request auth: %@", [requestAuthURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
		
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kDXOAuth_ReceivedAuthorizationTokenNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:requestAuthURL, kDXOAuth_RequestURLKey, nil]];
	}
	else
	{
		NSLog(@"OAuth authorization error");
		[self postAuthErrorNotification];
	}

}


- (void)obtainAccessToken:(NSString*)verifier
{
	assert(self.requestToken);
	
    NSURL *url = [NSURL URLWithString:@"https://api.login.yahoo.com/oauth/v2/get_token"];
	
	OAPlaintextSignatureProvider *plaintextProvider = [[OAPlaintextSignatureProvider new] autorelease];
	
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:mConsumer
                                                                      token:self.requestToken
                                                                      realm:kYahooAPIRealm   // our service provider doesn't specify a realm
                                                          signatureProvider:plaintextProvider];
	
    [request setHTTPMethod:@"POST"];	
	[request setOAuthParameterName:@"oauth_verifier" withValue:verifier];
	
	
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestAccessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestAccessTokenTicket:didFailWithError:)];
	
	[fetcher release];
	[request release];
}


- (void)requestAccessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"OAuth error requesting access token ticket: %@", error);
	[self postAuthErrorNotification];
}


- (void)requestAccessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{		
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		
		OAToken* accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
		
		NSDictionary* parameters = dictionaryFromURLParameters(responseBody);
		
		NSString* sessionHandle = [parameters objectForKey:@"oauth_session_handle"];
		assert(sessionHandle);
		
		if (!sessionHandle)
		{
			NSLog(@"Didn't get OAuth session handle from Yahoo. This is most unexpected.");
		}
		
		NSLog(@"Got access token       : %@", accessToken);
		NSLog(@"Got access token key   : %@", accessToken.key);
		NSLog(@"Got access token secret: %@", accessToken.secret);
		NSLog(@"Got session handler    : %@", sessionHandle);
		
		[mDatabase setOAuthAccessToken:accessToken];
		[mDatabase setOAuthSessionHandle:sessionHandle];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kDXOAuth_ReceivedAccessTokenNotification object:self];
	}
	else
	{
		NSLog(@"Error getting access token");
		[self postAuthErrorNotification];
	}
}

- (void)refreshAccessToken
{
	OAToken *accessToken = [mDatabase oauthAccessToken];
	NSString *sessionHandle = [mDatabase oauthSessionHandle];
	
	assert(accessToken);
	assert(sessionHandle);
	
    NSURL *url = [NSURL URLWithString:@"https://api.login.yahoo.com/oauth/v2/get_token"];
	
	OAPlaintextSignatureProvider *plaintextProvider = [[OAPlaintextSignatureProvider new] autorelease];
	
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:mConsumer
                                                                      token:accessToken
                                                                      realm:kYahooAPIRealm   // our service provider doesn't specify a realm
                                                          signatureProvider:plaintextProvider];
	
    [request setHTTPMethod:@"POST"];	
	NSLog(@"The session handle is %@", sessionHandle);
	[request setOAuthParameterName:@"oauth_session_handle" withValue:sessionHandle];
	
	
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(refreshAccessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(refreshAccessTokenTicket:didFailWithError:)];
	
	[fetcher release];
	[request release];
}

- (void)refreshAccessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"OAuth error refreshing access token ticket: %@", error);
	[self postAuthErrorNotification];
}


- (void)refreshAccessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	[self requestAccessTokenTicket:ticket didFinishWithData:data];
}

- (void)postAuthErrorNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kDXOAuth_AuthorizationErrorNotification
														object:self];
}

- (OAMutableURLRequest*)oaRequestFromURLRequest:(NSURLRequest*)urlRequest
{
	OAConsumer *consumer = self.consumer;
	OAToken *accessToken = [mDatabase oauthAccessToken];
	
	if (consumer == nil || accessToken == nil)
	{
		return nil;
	}
	
	OAMutableURLRequest* result = [[[OAMutableURLRequest alloc] initWithURL:[urlRequest URL]
																   consumer:consumer token:accessToken
																	  realm:kYahooAPIRealm
														  signatureProvider:nil] autorelease];
	
	[result setTimeoutInterval:[urlRequest timeoutInterval]];
	[result setHTTPMethod:[urlRequest HTTPMethod]];
	[result setCachePolicy:[urlRequest cachePolicy]];
	
	for(NSString* httpHeaderKey in [urlRequest allHTTPHeaderFields])
	{
		NSString *httpHeaderValue = [urlRequest valueForHTTPHeaderField:httpHeaderKey];
		
		if (httpHeaderValue)
		{
			[result setValue:httpHeaderValue forHTTPHeaderField:httpHeaderKey];
		}
	}
	
	[result prepare];
	
	return result;
}

- (BOOL)isOAuthLoggedIn
{
	return [mDatabase isUsingOAuth] && [mDatabase isLoggedIn];
}

@end


#ifdef DELICIOUSSAFARI_PLUGIN_TARGET

// No need for obfuscation in the iPhone app. However, this technique is pretty easy to get around, since the OAuthConsumer
// framework is open source and it's easy to figure out where to set a breakpoint after this is already assembled.

static NSString* kOAuthConsumerKeyPart5 = @"Ody0tJnM9Y29uc3VtZXJzZWNyZXQmeD0yZQ";
static NSString* kOAuthSharedSecretPart4 = @"3a3cc8b9e2";
static NSString* kOAuthConsumerKeyPart2 = @"lSExBaWdBJmQ9WVdrOU";
static NSString* kOAuthConsumerKeyPart3 = @"5YQjNZbkp1";
static NSString* kOAuthSharedSecretPart1 = @"9cb536";
static NSString* kOAuthSharedSecretPart2 = @"e24df62b";
static NSString* kOAuthConsumerKeyPart4 = @"TjJrbWNHbzlNVEUyTURJNU1Ea3l";
static NSString* kOAuthConsumerKeyPart1 = @"dj0yJmk9Y0tkRVh";
static NSString* kOAuthSharedSecretPart5 = @"138d85f5c";
static NSString* kOAuthConsumerKeyPart6 = @"--";
static NSString* kOAuthSharedSecretPart3 = @"50597f0";

static NSString* MyOAuthConsumerKey(void)
{
	return [NSString stringWithFormat:@"%@%@%@%@%@%@",
			kOAuthConsumerKeyPart1,
			kOAuthConsumerKeyPart2,
			kOAuthConsumerKeyPart3,
			kOAuthConsumerKeyPart4,
			kOAuthConsumerKeyPart5,
			kOAuthConsumerKeyPart6];
}

static NSString* MyOAuthSharedSecret(void)
{
	return [NSString stringWithFormat:@"%@%@%@%@%@",
			kOAuthSharedSecretPart1,
			kOAuthSharedSecretPart2,
			kOAuthSharedSecretPart3,
			kOAuthSharedSecretPart4,
			kOAuthSharedSecretPart5];
}

#endif

static NSDictionary* dictionaryFromURLParameters(NSString* responseData)
{
	NSArray *pairs = [responseData componentsSeparatedByString:@"&"];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	for (NSString *pair in pairs) {
		NSArray *elements = [pair componentsSeparatedByString:@"="];
		
		assert([elements count] == 2);
		
		if ([elements count] >= 2) {
			[result setObject:[elements objectAtIndex:1] forKey:[elements objectAtIndex:0]];
		}		
	}
	
	return result;
}
