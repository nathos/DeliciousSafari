//
//  BookmarkInfoViewController.m
//  Bookmarks
//
//  Created by Doug on 10/11/08.
//  Copyright 2008 Douglas Richardson. All rights reserved.
//

#import "BookmarkInfoViewController.h"
#import "ProgressOverlayView.h"
#import "EditNotesViewController.h"

#define LABEL_TAG 1
#define TEXTFIELD_TAG 2
#define TEXTFIELD_SPARE_TAG 5
#define SWITCH_TAG 3
#define CONTACTS_SWITCH_TAG 4

#define ROW_HEIGHT 60

#define LEFT_COLUMN_OFFSET 10.0
#define LEFT_COLUMN_WIDTH 110.0

#define RIGHT_COLUMN_OFFSET 14.0
#define RIGHT_COLUMN_WIDTH 284.0

#define MAIN_FONT_SIZE 18.0
#define LABEL_HEIGHT 26.0
#define TEXTFIELD_HEIGHT 22.0


static NSString *kRegularCellIdentifier = @"RegularCell";
static NSString *kSharedCellIdentifer = @"SharedCell";
static NSString *kTextEditCellIdentifier = @"TextEditCell";
static NSString *kTextEditCell2Identifier = @"TextEditCell2";

enum
{
	kTitleSection = 0,
	kDescriptionSection, /* URL */
	kAttributesSection,
	kTagsSection,
	kPopularTagsSection,
	kSectionCount
};

enum
{
	kTitleSectionRow = 0,
	kTitleSectionRowCount
};

enum
{
	kDescriptionSectionRow = 0,
	kDescriptionSectionRowCount
};

enum
{
	kAttributesNotesRow = 0,
	kAttributesDateRow,
	kAtributesSharedRow,
	kAttributesSectionRowCount
};

enum
{
	kDateSectionRow = 0,
	kDateSectionRowCount
};

enum
{
	kSharedSectionRow = 0,
	kSharedSectionRowCount
};

enum
{
	kTagsSectionRow = 0,
	kTagsSectionRowCount
};

enum
{
	kPopularTagsSectionRow = 0,
	kPopularTagsSectionRowCount
};

@interface BookmarkInfoViewController (private)
- (void)prepareForEdit;
- (void)prepareForCompletion;
- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier;
- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation BookmarkInfoViewController


- (id)initWithPost:(NSDictionary*)postDictionary
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if(self)
	{
		self.title = NSLocalizedString(@"Details", @"Info view nav bar title.");
		
		textField = [[UITextField alloc] initWithFrame:CGRectZero];
		textField.tag = TEXTFIELD_TAG;
		textField.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
		textField.textAlignment = UITextAlignmentLeft;
		textField.delegate = self;
		textField.returnKeyType = UIReturnKeyDone;	

		textField2 = [[UITextField alloc] initWithFrame:CGRectZero];
		textField2.tag = TEXTFIELD_SPARE_TAG;
		textField2.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
		textField2.textAlignment = UITextAlignmentLeft;
		textField2.delegate = self;
		textField2.returnKeyType = UIReturnKeyDone;	
		
		_shakeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		_shakeSwitch.tag = SWITCH_TAG;
		_shakeSwitch.on = NO;
		_shakeSwitch.enabled = NO;
		[_shakeSwitch addTarget:self action:@selector(shakeChanged) forControlEvents:UIControlEventAllTouchEvents];
		
		datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
		dateContainer = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		dateContainer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		dateContainer.opaque = NO;
		[dateContainer addTarget:self action:@selector(closeDate) forControlEvents:UIControlEventTouchUpInside];
		[dateContainer setAlpha:0.0];
		
		saveContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		saveContainer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		saveContainer.opaque = NO;
		[saveContainer setAlpha:0.0];
		

		[dateContainer addSubview:datePicker];		
		
		CGRect currentFrame = datePicker.frame;
		CGRect newFrame = CGRectMake(0, 480, currentFrame.size.width, currentFrame.size.height);
		datePicker.frame = newFrame;		
		
		deleteFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
		
		UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		deleteButton.frame = CGRectMake(8, 16, 303, 45);
		[deleteButton setTitle:@"Delete Bookmark" forState:UIControlStateNormal];
		[deleteButton setTitle:@"Delete Bookmark" forState:UIControlStateHighlighted];
		[deleteButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];

		[deleteFooter addSubview:deleteButton];
		
		self.tableView.tableFooterView = deleteFooter;
		[self prepareForEdit];
	}
	return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kSectionCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	switch(section)
	{
		case kDescriptionSection:
			return kDescriptionSectionRowCount;
			
		case kTitleSection:
			return kTitleSectionRowCount;
			
		case kAttributesSection:
			return kAttributesSectionRowCount;
				
		case kTagsSection:
			return kTagsSectionRowCount;
		
		case kPopularTagsSection:
			return kPopularTagsSectionRowCount;
	}
	
	return 0;	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = nil;
	
	if (indexPath.section == kAttributesSection && indexPath.row == kAtributesSharedRow)
	{
		cellIdentifier = kSharedCellIdentifer;
	}
	else if (indexPath.section == kTitleSection)
	{
		cellIdentifier = kTextEditCellIdentifier;		
	}
	else if (indexPath.section == kDescriptionSection)
	{
		cellIdentifier = kTextEditCell2Identifier;
	}
	else
		cellIdentifier = kRegularCellIdentifier;
	
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = [self tableviewCellWithReuseIdentifier:cellIdentifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.text = @"";

	if (indexPath.section == kAttributesSection)
	{		
		switch (indexPath.row)
		{
			case 0:
			{
				// NOTES
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				
				if (savedNotes == nil)
					cell.textLabel.text = (_shakeSwitch.enabled ? @"No Notes (Tap to Edit)" : @"No Notes");
				else
					cell.textLabel.text = savedNotes;
				
				cell.textLabel.textColor = (_shakeSwitch.enabled ? [UIColor blackColor] : [UIColor grayColor]);

				break;
			}
			case 1:
			{
				// DATE
				cell.accessoryType = UITableViewCellAccessoryNone;
				
				NSString *dateString = nil;
				NSDateFormatter *dateForm = [[[NSDateFormatter alloc] init] autorelease];
				[dateForm setDateStyle:NSDateFormatterFullStyle];
				[dateForm setTimeStyle:NSDateFormatterShortStyle];
				dateString = [dateForm stringFromDate:[NSDate date]];
				cell.textLabel.text = dateString;
				cell.textLabel.font = [UIFont systemFontOfSize:14.0];

				cell.textLabel.textColor = (_shakeSwitch.enabled ? [UIColor blackColor] : [UIColor grayColor]);

				break;
			}
			case 2:
			{
				// PRIVATE
				break;
			}
		}
	}
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (indexPath.section == kPopularTagsSection)
	{
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = @"No Tags Found on Delicious";
		cell.textLabel.textColor = [UIColor grayColor];
	}
	else if (indexPath.section == kTagsSection)
	{
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = @"Not Tagged Yet";
		cell.textLabel.textColor = [UIColor grayColor];
	}	
	
	[self configureCell:cell forIndexPath:indexPath];
	
    // Configure the cell
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	switch (indexPath.section)
	{
		case kAttributesSection:
		{
			if (indexPath.row == kAttributesNotesRow)
			{
				EditNotesViewController *noteEditor = [[EditNotesViewController alloc] init];
				[self.navigationController pushViewController:noteEditor animated:YES];
				[noteEditor setEditEnabled:_shakeSwitch.enabled];
				[noteEditor release];				
			}
			else if (indexPath.row == kAttributesDateRow)
			{		
				if ([dateContainer superview] == nil)
					[self.tableView.window addSubview:dateContainer];
				
				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
				
				[UIView beginAnimations:@"FadeIn" context:nil];
				[UIView setAnimationDuration:0.3];
				[UIView setAnimationBeginsFromCurrentState:YES];
				
				[dateContainer setAlpha:1.0];
				
				CGRect currentFrame = datePicker.frame;
				CGRect newFrame = CGRectMake(0, 480 - currentFrame.size.height, currentFrame.size.width, currentFrame.size.height);
				datePicker.frame = newFrame;
				
				[UIView commitAnimations];
			}			
			break;			
		}
		case kDescriptionSection:
		{
			if (_shakeSwitch.enabled)
				[textField2 becomeFirstResponder];
			break;
		}
		case kTitleSection:
		{
			if (_shakeSwitch.enabled)
				[textField becomeFirstResponder];
			break;
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *result = nil;
	
	switch(section)
	{
		case kTitleSection:
			result = @""; //NSLocalizedString(@"Title", @"Title section in bookmark info view.");
			break;

		case kDescriptionSection:
			result = @""; //NSLocalizedString(@"URL", @"Description section in bookmark info view.");
			break;

		case kAttributesSection:
			result = @"";// NSLocalizedString(@"Notes", @"Actions section in bookmark info view.");
			break;
						
		case kTagsSection:
			result = NSLocalizedString(@"Tags", @"Actions section in bookmark info view.");
			break;
			
		case kPopularTagsSection:
			result = NSLocalizedString(@"Popular Tags", @"Actions section in bookmark info view.");
			break;
	}
	
	return result;
}

-(void)prepareForCompletion
{	
	editOccurred = YES;
	
	UIBarButtonItem *newCancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				target:self
																				action:@selector(cancelEdit)] autorelease];
	UIBarButtonItem *newDone = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																			  target:self
																			  action:@selector(prepareForEdit)] autorelease];
	
	[self.navigationItem setLeftBarButtonItem:newCancel animated:YES];
	[self.navigationItem setRightBarButtonItem:newDone animated:YES];
	
	textField.textColor = [UIColor blackColor];
	textField2.textColor = [UIColor blackColor];

	_shakeSwitch.enabled = YES;
	
	textField.enabled = YES;
	textField2.enabled = YES;

	[self.tableView reloadData];
	
//	[self.tableView setEditing:YES animated:YES];
}

- (void)cancelEdit
{
	editOccurred = NO;
	
	[self prepareForEdit];
}

- (void)prepareForEdit
{
	if (editOccurred)
		[self performSelectorOnMainThread:@selector(saveWithOverlay) withObject:nil waitUntilDone:YES];
	
	if (!editOccurred)
	{
		UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																					 target:self
																					 action:@selector(prepareForCompletion)] autorelease];
		
		[self.navigationItem setLeftBarButtonItem:nil animated:YES];	
		[self.navigationItem setRightBarButtonItem:editButton animated:YES];
		
		_shakeSwitch.enabled = NO;	
		
		textField.textColor = [UIColor grayColor];
		textField2.textColor = [UIColor grayColor];

		[textField resignFirstResponder];
		textField.enabled = NO;

		[textField2 resignFirstResponder];
		textField2.enabled = NO;

		[self.tableView reloadData];
	}
		
//	[self.tableView setEditing:NO animated:YES];
}

- (void)dealloc {
	[_shakeSwitch release];
	[datePicker release];
	[dateContainer release];
	[saveContainer release];
    [super dealloc];
}


- (IBAction)deleteClicked:(id)sender
{
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete Bookmark", nil) otherButtonTitles:nil] autorelease];
	[actionSheet showInView:[self.tableView superview]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[self performSelector:@selector(finishDelete) withObject:nil afterDelay:0.5];
	}
}

- (void)finishDelete
{
	// should delete the bookmark here
	// also pre-update the tags above this so it's correct
	// also needs to be aware of the case where the tag would disappear at that point
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{	
	if (indexPath.section == kAttributesSection)
	{
		UILabel *labelView = (UILabel*)[cell viewWithTag:LABEL_TAG];
		labelView.textColor = (_shakeSwitch.enabled ? [UIColor blackColor] : [UIColor grayColor]);
		labelView.font = [UIFont boldSystemFontOfSize:16];
		labelView.text = NSLocalizedString(@"Private Bookmark", nil);
		_shakeSwitch.on = NO;		
	}
	else if (indexPath.section == kTitleSection)
	{
		UITextField *ourTextField = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
		ourTextField.placeholder = NSLocalizedString(@"Title", nil);
		ourTextField.text = @"Your Special Bookmark Title";
		ourTextField.clearButtonMode = UITextFieldViewModeWhileEditing;		
	}
	else if (indexPath.section == kDescriptionSection)
	{
		UITextField *ourTextField = (UITextField*)[cell viewWithTag:TEXTFIELD_SPARE_TAG];
		ourTextField.placeholder = NSLocalizedString(@"URL", nil);
		ourTextField.text = @"www.exampleURL.com";
		ourTextField.clearButtonMode = UITextFieldViewModeWhileEditing;		
	}
}

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier
{	
	CGRect rect = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
	
	if ([identifier isEqualToString:kSharedCellIdentifer])
	{
		UISwitch *switchToUse = _shakeSwitch;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		NSInteger shakeSwitchOrigin = (cell.bounds.size.width - switchToUse.frame.size.width - 35);
		
		rect = CGRectMake(LEFT_COLUMN_OFFSET, (cell.bounds.size.height - LABEL_HEIGHT) / 2.0,
						  shakeSwitchOrigin - 10, LABEL_HEIGHT);
		
		UILabel *label = [[UILabel alloc] initWithFrame:rect];
		label.tag = LABEL_TAG;
		label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
		label.adjustsFontSizeToFitWidth = YES;
		[cell.contentView addSubview:label];
		label.highlightedTextColor = [UIColor whiteColor];
		[label release];
		
		rect = switchToUse.frame;
		rect.origin.x = shakeSwitchOrigin;
		rect.origin.y = (cell.bounds.size.height - 28.0) / 2.0;
		
		[switchToUse setFrame:rect];
		[cell.contentView addSubview:switchToUse];		
	}
	else if ([identifier isEqualToString:kTextEditCellIdentifier])
	{
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
		rect = CGRectMake(RIGHT_COLUMN_OFFSET, (cell.bounds.size.height - TEXTFIELD_HEIGHT) / 2.0, RIGHT_COLUMN_WIDTH, TEXTFIELD_HEIGHT);
		[textField setFrame:rect];
		
		[textField setTag:TEXTFIELD_TAG];
		[cell.contentView addSubview:textField];		
	}
	else if ([identifier isEqualToString:kTextEditCell2Identifier])
	{
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		rect = CGRectMake(RIGHT_COLUMN_OFFSET, (cell.bounds.size.height - TEXTFIELD_HEIGHT) / 2.0, RIGHT_COLUMN_WIDTH, TEXTFIELD_HEIGHT);
		[textField2 setFrame:rect];
		
		[textField2 setTag:TEXTFIELD_SPARE_TAG];
		[cell.contentView addSubview:textField2];		
	}

	return cell;
}

- (void)shakeChanged
{
	NSLog(@"shake changed");
}

- (void)closeDate
{
	[UIView beginAnimations:@"FadeOut" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	CGRect currentFrame = datePicker.frame;
	CGRect newFrame = CGRectMake(0, 480, currentFrame.size.width, currentFrame.size.height);
	datePicker.frame = newFrame;
	
	[dateContainer setAlpha:0.0];
	
	[UIView commitAnimations];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)saveWithOverlay
{
	[textField resignFirstResponder];
	textField.enabled = NO;

	[textField2 resignFirstResponder];
	textField2.enabled = NO;

	if ([saveContainer superview] == nil)
	{
		if (stopView == nil)
		{
			stopView = [[ProgressOverlayView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
			[saveContainer addSubview:stopView];
			stopView.frame = CGRectMake(160 - 100, 480 - 300, 200, 150);
		}
		[self.tableView.window addSubview:saveContainer];		
	}
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	
	[UIView beginAnimations:@"SaveFadeIn" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	[saveContainer setAlpha:1.0];
		
	[UIView commitAnimations];
	
	[stopView performSelector:@selector(showOverlay) withObject:nil afterDelay:0.2]; // need to implement
	
	[self performSelector:@selector(saveCompleted) withObject:nil afterDelay:2.0];
}

- (void)saveCompleted
{	
	[UIView beginAnimations:@"SaveFadeOut" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	[saveContainer setAlpha:0.0];
	
	[UIView commitAnimations];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];	
	
	UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																				 target:self
																				 action:@selector(prepareForCompletion)] autorelease];
	
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];	
	[self.navigationItem setRightBarButtonItem:editButton animated:YES];
	
	_shakeSwitch.enabled = NO;	
	
	textField.textColor = [UIColor grayColor];
	textField2.textColor = [UIColor grayColor];
		
	[self.tableView reloadData];
	
	[stopView performSelectorOnMainThread:@selector(endOverlay) withObject:nil waitUntilDone:NO]; // need to implement
}

#pragma mark UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)inTextField
{	
	[inTextField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)inTextField
{
	if(inTextField == textField)
	{
	}
	else if(inTextField == textField2)
	{
	}
}

@end
