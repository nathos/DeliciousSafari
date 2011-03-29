//
//  FlowLayoutView.m
//  Bookmarks
//
//  Created by Doug on 10/12/08.
//  Copyright 2008 Douglas Richardson. All rights reserved.
//

#import "FlowLayoutView.h"

@interface FlowLayoutView (private)
-(void)layout;
@end

@implementation FlowLayoutView

@synthesize horizontalPadding, verticalPadding;

-(void)addSubview:(UIView*)aView
{
	[super addSubview:aView];
	[self layout];
}

-(void)layout
{
	// Starting from the first control, draw it and maintain a width and height.
	// Keep moving to the right + padding until you can't draw a control, then wrap. Wrap
	// using the max control height in the row we just finished + padding.
	
	CGSize myFrameSize = self.frame.size;
	
	float currentX = 0, currentY = 0;
	float maxHeightForCurrentRow = 0;
	int objectCountForRow = 0;
	
	for(UIView* view in self.subviews)
	{
		CGRect frame = view.frame;
		
		if(objectCountForRow > 0 && currentX + frame.size.width >= myFrameSize.width)
		{
			currentY += maxHeightForCurrentRow + verticalPadding;
			currentX = 0;
			objectCountForRow = 0;
		}
		else
			objectCountForRow++;
		
		frame.origin = CGPointMake(currentX, currentY);
		view.frame = frame;
		
		currentX += horizontalPadding + frame.size.width;
		if(frame.size.height > maxHeightForCurrentRow)
			maxHeightForCurrentRow = frame.size.height;
	}
}

-(void)setFrame:(CGRect)newFrame
{
	//NSLog(@"setFrame called");
	[super setFrame:newFrame];
	[self layout];
}

#if 0
-(void)removeAllSubviews
{
	// TODO: Remove this method if not needed.
	for(UIView *view in self.subviews)
		[view removeFromSuperview];
	
	[self layout];
}
#endif

@end
