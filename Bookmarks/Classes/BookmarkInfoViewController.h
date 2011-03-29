//
//  BookmarkInfoViewController.h
//  Bookmarks
//
//  Created by Doug on 10/11/08.
//  Copyright 2008 Douglas Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressOverlayView;

@interface BookmarkInfoViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
	NSDictionary *_postDictionary;
	UIView *deleteFooter;
	UISwitch *_shakeSwitch;
	UIDatePicker *datePicker;
	UIControl *dateContainer;
	UIView *saveContainer;
	BOOL editOccurred;
	ProgressOverlayView *stopView;
	NSString *savedNotes;
	UITextField *textField;
	UITextField *textField2;
}

- (id)initWithPost:(NSDictionary*)postDictionary;

@end
