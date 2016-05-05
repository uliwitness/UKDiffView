//
//  NSView+ScrollToRect.m
//  AngelDiff
//
//  Created by Jan on 21.11.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "NSView+ScrollToRect.h"


@implementation NSView (ScrollToRect)

- (void)scrollRectToTop:(NSRect)rect;
{
	[self scrollRectToTop:rect withOffset:0.0f];
}

- (void)scrollRectToTop:(NSRect)rect withOffset:(CGFloat)percentageOfHeight;
{
	CGFloat height = NSHeight([self visibleRect]);
	
	if (height > 0.0f) {
		rect.size.height = height;
	}
	
	if (percentageOfHeight > 0.0f) {
		rect.origin.y = MAX(0.0f, rect.origin.y - height * percentageOfHeight);
	}
	
	[self scrollRectToVisible:rect];
}



@end
