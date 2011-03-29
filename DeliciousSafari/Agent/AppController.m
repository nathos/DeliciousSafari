//
//  AppController.m
//  DeliciousSafari
//
//  Created by Doug on 8/29/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import "AppController.h"

static NSDictionary* dictionaryFromURLParameters(NSString* responseData);

@implementation AppController

-(id)init
{
	self = [super init];
	if(self)
	{
		_supportedApplicationArray = [[NSArray alloc] initWithObjects:@"com.apple.Safari", @"org.webkit.nightly.WebKit", nil];
		safariController = [SafariController sharedController];
	}
	return self;
}

-(void)dealloc
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[_supportedApplicationArray release];
	[super dealloc];
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(applicationLaunchedNotification:)
															   name:NSWorkspaceDidLaunchApplicationNotification
															 object:nil];
	
	NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
	[em setEventHandler:self 
			andSelector:@selector(getUrl:withReplyEvent:) 
		  forEventClass:kInternetEventClass 
			 andEventID:kAEGetURL];
}

-(void)applicationLaunchedNotification:(NSNotification*)notification
{
	NSRunningApplication *runningApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
	
	if(!runningApp)
		return;
	
	//NSLog(@"Observed application launch: %@, localized name: %@", runningApp.bundleIdentifier, runningApp.localizedName);
	
	if(runningApp.bundleIdentifier && [_supportedApplicationArray containsObject:runningApp.bundleIdentifier])
	{
		//NSLog(@"Try to load Delicioussafari in %@", runningApp.bundleIdentifier);
		safariController.applicationName = runningApp.localizedName;
		[safariController loadDeliciousSafariIntoApplication];
	}	
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	// Get the URL
	NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	
	//NSLog(@"Got urlStr = %@", urlStr);
	
	NSArray *components = [urlStr componentsSeparatedByString:@"?"];
	assert([components count] == 2);
	
	NSString *parametersStr = [components objectAtIndex:1];
	NSDictionary *params = dictionaryFromURLParameters(parametersStr);
	assert(params);
	
	NSString *token = [params objectForKey:@"oauth_token"];
	NSString *verifier = [params objectForKey:@"oauth_verifier"];
	
	//NSLog(@"Token: %@, Verifier: %@", token, verifier);
	
	if (token && verifier)
	{
		[safariController sendOAuthToken:token andVerifier:verifier];
	}
	else
	{
		NSLog(@"Couldn't send oauth token %p or verifier %p to DeliciousSafari because one was null.", token, verifier);
	}
}

@end


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