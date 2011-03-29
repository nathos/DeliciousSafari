//
//  DXLoginController.m
//  DeliciousSafari
//
//  Created by Doug on 11/12/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import "DXLoginController.h"
#import "DXDeliciousAPIManager.h"
#import "DXDeliciousDatabase.h"
#import "DXUtilities.h"
#import "DXYahooOAuthManager.h"

typedef enum DXAccountType
{
	kAccountTypeDelicious,
	kAccountTypeYahoo
} DXAccountType;

@interface DXLoginController ()
- (void)loginWithFirstResponder:(NSResponder*)firstResponder;
- (void)updateCredentials;
- (void)setAccountType:(DXAccountType)accountType;
@end

@implementation DXLoginController

- (id)init
{
	self = [super initWithWindowNibName:@"DXLogin"];
	
	if(self)
	{		
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(delicioussLoginCompleteNotification:) name:kDeliciousLoginCompleteNotification object:nil];
		[center addObserver:self selector:@selector(deliciousBadCredentialsNotification:) name:kDeliciousBadCredentialsNotification object:nil];
		[center addObserver:self selector:@selector(deliciousConnectionFailedNotification:) name:kDeliciousConnectionFailedNotification object:nil];
		
		[center addObserver:self selector:@selector(oauthReceivedAuthorizationTokenNotification:) name:kDXOAuth_ReceivedAuthorizationTokenNotification object:nil];
		[center addObserver:self selector:@selector(oauthAuthorizationErrorNotification:) name:kDXOAuth_AuthorizationErrorNotification object:nil];
		[center addObserver:self selector:@selector(oauthRecievedAccessTokenNotification:) name:kDXOAuth_ReceivedAccessTokenNotification object:nil];
		
		NSDistributedNotificationCenter *distributedCenter = [NSDistributedNotificationCenter defaultCenter];
		[distributedCenter addObserver:self selector:@selector(oauthReceivedAuthTokenAndVerifierNotification:) name:@"DXOAuthTokenReceivedNotification" object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc called on DXLoginController");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)setAccountType:(DXAccountType)accountType
{
	[mDeliciousAccountTypeButton setState:accountType == kAccountTypeDelicious ? NSOnState : NSOffState];
	[mYahooAccountTypeButton setState:accountType == kAccountTypeYahoo ? NSOnState : NSOffState];
	
	NSWindow *win = [self window];
	NSView *cv = [win contentView];
	NSView *accountSpecificView = accountType == kAccountTypeDelicious ? mDeliciousLoginView : mYahooLoginView;
	
	if(accountSpecificView == mDeliciousLoginView)
		[mYahooLoginView removeFromSuperview];
	else if(accountSpecificView == mYahooLoginView)
		[mDeliciousLoginView removeFromSuperview];
	
	NSRect winFrame = [win frame];
	NSRect cvFrame = [cv frame];
	NSSize deliciousLoginSize = [accountSpecificView frame].size;
	NSSize accountTypeSize = [mAccountTypeView frame].size;
	
	NSSize winWithoutCVSize = NSMakeSize(winFrame.size.width - cvFrame.size.width, winFrame.size.height - cvFrame.size.height);
	
	NSSize newWinFrameSize = NSMakeSize(winWithoutCVSize.width + fmax(deliciousLoginSize.width, accountTypeSize.width),
										winWithoutCVSize.height + deliciousLoginSize.height + accountTypeSize.height);
										
	
	NSSize delta = NSMakeSize(newWinFrameSize.width - winFrame.size.width, newWinFrameSize.height - winFrame.size.height);
	
	
	NSRect newWinFrame;
	newWinFrame.size = newWinFrameSize;
	newWinFrame.origin = NSMakePoint(winFrame.origin.x - delta.width, winFrame.origin.y - delta.height);
	
	[win setFrame:newWinFrame display:YES animate:YES];
	
	[cv addSubview:mAccountTypeView];
	[cv addSubview:accountSpecificView];
	
	[mAccountTypeView setFrameOrigin:NSMakePoint(0, deliciousLoginSize.height)];
}

#pragma mark NSWindowDelegate methods
- (void)windowWillClose:(NSNotification *)notification
{
	if([self window] == [notification object])
	{
		[self autorelease];
	}
}

#pragma mark Actions

- (void)awakeFromNib
{	
	[mErrorMessage setHidden:YES];
	[mProgress setHidden:YES];
	
	[self setAccountType:kAccountTypeDelicious];
	
	[[self window] center];
}

- (IBAction)deliciousAccountTypePressed:(id)sender
{
	[self setAccountType:kAccountTypeDelicious];
}

- (IBAction)yahooAccountTypePressed:(id)sender
{
	[self setAccountType:kAccountTypeYahoo];
}

- (IBAction)loginPressed:(id)sender
{
	//NSLog(@"loginPressed");
	[mProgress setHidden:NO];
	[mProgress startAnimation:self];
	[mErrorMessage setHidden:YES];
	
	[self updateCredentials];
	
	DXDeliciousAPIManager *api = [DXDeliciousAPIManager sharedManager];
	[api clearSavedCredentials];
	[api updateRequest];
}

- (IBAction)loginCancelPressed:(id)sender
{
	[self close];
}

- (IBAction)authorizeDeliciousSafariPressed:(id)sender
{
	[[DXYahooOAuthManager sharedOAuth] obtainAuthorizationToken];
}

#pragma mark OAuth callbacks
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		OAToken* requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		NSLog(@"request token is %@", requestToken);
		
		NSString *authorizationURL = [@"https://api.login.yahoo.com/oauth/v2/request_auth?oauth_token=" stringByAppendingString:responseBody];
		NSLog(@"Going to auth URL: %@", authorizationURL);
		[[DXUtilities defaultUtilities] goToURL:authorizationURL];
	}
}

- (void)requestTokenTicket:(OAServiceTicket*)ticket didFailWithError:(NSError*)error
{
	NSLog(@"failed to get token: %@", error);
}

#pragma mark Private methods

- (void)updateCredentials
{
	[DXDeliciousAPIManager sharedManager].password = [mDeliciousPassword stringValue];
	[[DXDeliciousDatabase defaultDatabase] setUsername:[mDeliciousUsername stringValue]];
}

- (void)loginWithFirstResponder:(NSResponder*)firstResponder
{
	[mDeliciousUsername setStringValue:[[DXDeliciousDatabase defaultDatabase] username]];
	[mDeliciousPassword setStringValue:@""];
	[mProgress stopAnimation:self];
	[mProgress setHidden:YES];
	[mErrorMessage setHidden:YES];
	
	[[self window] makeFirstResponder:firstResponder];
	
	[self showWindow:self];
}

- (void)login
{
	[self loginWithFirstResponder:mDeliciousUsername];
}


#pragma mark DXDeliciousAPIManager Notification Handlers

- (void)delicioussLoginCompleteNotification:(NSNotification*)notification
{
	if([[self window] isVisible])
	{
		[mProgress stopAnimation:self];
		[[DXDeliciousDatabase defaultDatabase] setUsername:[mDeliciousUsername stringValue]];
		[[DXDeliciousAPIManager sharedManager] startProcessingPendingBookmarks];
		[self close];
	}
}

- (void)deliciousBadCredentialsNotification:(NSNotification*)notification
{
	NSString *invalidUsernameOrPassword = DXLocalizedString(@"Invalid username or password", @"Invalid username or password error message.");
	
	[mProgress stopAnimation:self];
	[mProgress setHidden:YES];
	[mErrorMessage setStringValue:invalidUsernameOrPassword];
	[mErrorMessage setHidden:NO];
}

- (void)deliciousConnectionFailedNotification:(NSNotification*)notification
{
	//NSLog(@"deliciousAPIConnectionFailedWithError - currentSheet is the login window.");
	
	[mProgress stopAnimation:self];
	[mProgress setHidden:YES];
	
	if([mErrorMessage isHidden])
	{
		NSString *connectionFailedFormat = DXLocalizedString(@"Connection failed: %@", @"Connection failed format string.");
		
		// If this error hasn't already been handled somewhere else then show the generic error message now.
		NSError *error = [[notification userInfo] objectForKey:kDeliciousConnectionFailedNotification_NSErrorKey];
		[mErrorMessage setStringValue:[NSString stringWithFormat:connectionFailedFormat, [error localizedDescription]]];
		[mErrorMessage setHidden:NO];
	}
}


#pragma mark DXYahooOAuth Notification Handlers

- (void)oauthReceivedAuthorizationTokenNotification:(NSNotification*)notification
{
	NSURL *requestAuthURL = [[notification userInfo] objectForKey:kDXOAuth_RequestURLKey];
	[[NSWorkspace sharedWorkspace] openURL:requestAuthURL];
}

- (void)oauthAuthorizationErrorNotification:(NSNotification*)notification
{
	MAIN_THREAD_CHECK();
	
	NSString *oauthError = DXLocalizedString(@"Could not authorize DeliciousSafari to access Delicious.", @"Invalid username or password error message.");
	
	[mProgress stopAnimation:self];
	[mProgress setHidden:YES];
	[mErrorMessage setStringValue:oauthError];
	[mErrorMessage setHidden:NO];
}

- (void)oauthReceivedAuthTokenAndVerifierNotification:(NSNotification*)notification
{
	// This notification is sent from DSAgent, which has the URL handler for the delicioussafari schema.
	// Yahoo calls back the URL, which is delicioussafari:oauth... which runs the DSAgent getURL code which
	// posts the distributed notification that is handled here.
	
	MAIN_THREAD_CHECK();
	
	NSString *token = [[notification userInfo] objectForKey:@"token"];
	NSString *verifier = [[notification userInfo] objectForKey:@"verifier"];
	
	if (!token || !verifier)
	{
		NSLog(@"Token %p or verifier %p is 0");
		return;
	}
	
	[[DXYahooOAuthManager sharedOAuth] obtainAccessToken:verifier];
}

- (void)oauthRecievedAccessTokenNotification:(NSNotification*)notification
{
	MAIN_THREAD_CHECK();
	
	NSLog(@"Received access token. Let's start going some deliciousness");
	
	[[DXDeliciousDatabase defaultDatabase] setUsername:[mDeliciousScreenname stringValue]];
	
	[[self window] makeKeyAndOrderFront:self];
	[[DXDeliciousAPIManager sharedManager] updateRequest];
}

@end
