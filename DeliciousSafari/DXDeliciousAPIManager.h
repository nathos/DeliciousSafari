//
//  DXDeliciousAPIManager.h
//  Bookmarks
//
//  Created by Doug on 10/14/08.
//  Copyright 2008 Douglas Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXDeliciousAPI.h"
#import "DXDeliciousDatabase.h"

@interface DXDeliciousAPIManager : DXDeliciousAPI <DXDeliciousAPIDelegate> {
	NSDate *_savedLastUpdatedTime;
	BOOL _isUpdating;
	BOOL _isUserLoggedIn;
	DXDeliciousDatabase *_database;
	NSString *_password;
}

+(DXDeliciousAPIManager*)sharedManager;

-(id)initWithUserAgent:(NSString*)userAgent withDatabase:(DXDeliciousDatabase*)database;

@property BOOL isUpdating;

#ifdef DELICIOUSSAFARI_IPHONE_TARGET
@property BOOL isUserLoggedIn;
#endif

@property (nonatomic, retain) DXDeliciousDatabase* database;
@property (copy) NSString* password;

-(void)logout;

@end


// Notifications related to del.icio.us messages
extern NSString* kDeliciousBadCredentialsNotification;
extern NSString* kDeliciousConnectionFailedNotification;
extern NSString* kDeliciousPostsUpdatedNotification;

extern NSString* kDeliciousPostAddResponseNotification;
extern NSString* kDeliciousPostAddResponse_DidSucceedKey;
extern NSString* kDeliciousPostAddResponse_PostDictionaryKey;

extern NSString* kDeliciousURLInfoResponseNotification;
extern NSString* kDeliciousURLInfoResponse_URLInfoKey;

// Keys for optional notification userInfo dictionaries.
extern NSString* kDeliciousConnectionFailedNotification_NSErrorKey;

// Higher level notifications.
extern NSString* kDeliciousLoginCompleteNotification;
