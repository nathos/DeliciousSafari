//
//  DXLoginController.h
//  DeliciousSafari
//
//  Created by Doug on 11/12/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DXLoginController : NSWindowController
{
	IBOutlet NSTextField*				mDeliciousUsername;		// For Delicious.com accounts
	IBOutlet NSSecureTextField*			mDeliciousPassword;		// For Delicious.com accounts
	IBOutlet NSTextField*				mDeliciousScreenname;	// For Yahoo ID accounts
	
	IBOutlet NSProgressIndicator*		mProgress;
	IBOutlet NSTextField*				mErrorMessage;
	
	IBOutlet NSView*					mAccountTypeView;		// Container view for account type header
	IBOutlet NSView*					mDeliciousLoginView;	// Container view for Delicious.com account
	IBOutlet NSView*					mYahooLoginView;		// Container view for Yahoo ID accounts
	
	IBOutlet NSButton*					mDeliciousAccountTypeButton;
	IBOutlet NSButton*					mYahooAccountTypeButton;
}

// Account type actions
- (IBAction)deliciousAccountTypePressed:(id)sender;
- (IBAction)yahooAccountTypePressed:(id)sender;

// Delicious Actions
- (IBAction)loginPressed:(id)sender;
- (IBAction)loginCancelPressed:(id)sender;

// Yahoo Actions
- (IBAction)authorizeDeliciousSafariPressed:(id)sender;

@end
