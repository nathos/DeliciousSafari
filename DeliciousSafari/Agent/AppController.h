//
//  AppController.h
//  DeliciousSafari
//
//  Created by Doug on 8/29/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SafariController.h"

@interface AppController : NSObject
{
	NSArray *_supportedApplicationArray;
	SafariController *safariController;
}

@end
