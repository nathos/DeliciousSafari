//
//  SafariController.h
//  DeliciousSafari
//
//  Created by Doug on 8/29/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SafariController : NSObject
{
	NSString *applicationName;
}

@property(copy) NSString* applicationName;

+(SafariController*)sharedController;

-(void)loadDeliciousSafariIntoApplication;
-(void)sendOAuthToken:(NSString*)token andVerifier:(NSString*)verifier;

@end
