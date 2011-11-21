//
//  UKDiffView.m
//  AngelDiff
//
//  Created by Uli Kusterer on 02.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "UKDiffView.h"
#import "UKDiffParser.h"
#import "UKHelperMacros.h"


// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

#define	ROUNDING_SIZE		(2.0f)
#define SIDE_MARGIN			(3.0f)
#define HORZ_MARGIN			(8.0f)
#define VERT_MARGIN			(4.0f)
#define DIVIDER_WIDTH		(16.0f)


// -----------------------------------------------------------------------------
//	UKCachedDiffEntry:
//		We use this class to cache the text engine elements and positions and
//		sizes of our display elements for faster scrolling and hit testing.
// -----------------------------------------------------------------------------

@implementation UKCachedDiffEntry

@synthesize rightDrawBox;
@synthesize leftTextStorage;
@synthesize rightTextStorage;
@synthesize currOp;
@synthesize attributes;
@synthesize apply;

+(id)	cachedEntryWithLeftString: (NSString*)leftStr rightString: (NSString*)rightStr attributes: (NSDictionary*)attrs applyFlag: (BOOL)apl
{
	return [[[[self class] alloc] initWithLeftString: leftStr rightString: rightStr attributes: attrs applyFlag: apl] autorelease];
}


-(id)	initWithLeftString: (NSString*)leftStr rightString: (NSString*)rightStr attributes: (NSDictionary*)attrs applyFlag: (BOOL)apl
{
	if(( self = [super init] ))
	{
		NSAttributedString*	leftAttrStr = [[[NSAttributedString alloc] initWithString: leftStr ? leftStr : @"" attributes: attrs] autorelease];
		leftTextStorage = [[NSTextStorage alloc] initWithAttributedString: leftAttrStr];
		NSLayoutManager*	layoutManager = [[NSLayoutManager alloc] init];
		NSTextContainer*	textContainer = [[NSTextContainer alloc] init];
		[layoutManager addTextContainer:textContainer];
		[textContainer release];
		[leftTextStorage addLayoutManager:layoutManager];
		[layoutManager release];
		
		NSAttributedString*	rightAttrStr = [[[NSAttributedString alloc] initWithString: rightStr ? rightStr : @"" attributes: attrs] autorelease];
		rightTextStorage = [[NSTextStorage alloc] initWithAttributedString: rightAttrStr];
		layoutManager = [[NSLayoutManager alloc] init];
		textContainer = [[NSTextContainer alloc] init];
		[layoutManager addTextContainer:textContainer];
		[textContainer release];
		[rightTextStorage addLayoutManager:layoutManager];
		[layoutManager release];
		
		apply = apl;
		
		self.attributes = attrs;
	}
	
	return self;
}

-(void)	dealloc
{
	self.leftTextStorage = nil;
	self.rightTextStorage = nil;
	self.attributes = nil;
	
	[super dealloc];
}


static CGFloat sOneLineHeight = -1;


-(NSRect)leftDrawBox {
    return leftDrawBox;
}

-(void)	setLeftDrawBox: (NSRect)box
{
	if( sOneLineHeight < 0 )
		sOneLineHeight = [@" " sizeWithAttributes: attributes].height;
	
	leftDrawBox = box;
	
	NSString*	str = [leftTextStorage string];
	unichar		lastCh = ([str length] > 0) ? [str characterAtIndex: [str length] -1] : '\n';
	BOOL		endsInLineBreak = lastCh == '\n' || lastCh == '\r';

	NSLayoutManager*	layoutManager = [[leftTextStorage layoutManagers] objectAtIndex: 0];
	NSTextContainer*	textContainer = [[layoutManager textContainers] objectAtIndex: 0];
	[textContainer setContainerSize: NSMakeSize(box.size.width, FLT_MAX)];
	/*(NSRange) */[layoutManager glyphRangeForTextContainer: textContainer]; // Cause re-layout.
	NSRect	textRect = [layoutManager usedRectForTextContainer: textContainer];
	leftDrawBox.size.height = textRect.size.height -(endsInLineBreak ? sOneLineHeight : 0);
}


-(NSRect)rightDrawBox {
    return rightDrawBox;
}

-(void)	setRightDrawBox: (NSRect)box
{
	if( sOneLineHeight < 0 )
		sOneLineHeight = [@" " sizeWithAttributes: attributes].height;
	
	rightDrawBox = box;
	
	NSString*	str = [rightTextStorage string];
	unichar		lastCh = ([str length] > 0) ? [str characterAtIndex: [str length] -1] : '\n';
	BOOL		endsInLineBreak = lastCh == '\n' || lastCh == '\r';
	
	NSLayoutManager*	layoutManager = [[rightTextStorage layoutManagers] objectAtIndex: 0];
	NSTextContainer*	textContainer = [[layoutManager textContainers] objectAtIndex: 0];
	[textContainer setContainerSize: NSMakeSize(box.size.width, FLT_MAX)];
	/*(NSRange) */[layoutManager glyphRangeForTextContainer: textContainer]; // Cause re-layout.
	NSRect	textRect = [layoutManager usedRectForTextContainer: textContainer];
	rightDrawBox.size.height = textRect.size.height -(endsInLineBreak ? sOneLineHeight : 0);
}


NSRect	UKBoxAroundPoint( NSPoint pos, CGFloat dist )
{
	NSRect		box = NSZeroRect;
	box.origin = pos;
	return NSInsetRect( box, -dist, -dist );
}


NSPoint	UKTopLeft( NSRect box )
{
	return NSMakePoint( NSMinX(box), NSMinY(box) );
}


NSPoint	UKTopRight( NSRect box )
{
	return NSMakePoint( NSMaxX(box), NSMinY(box) );
}


NSPoint	UKBottomLeft( NSRect box )
{
	return NSMakePoint( NSMinX(box), NSMaxY(box) );
}


NSPoint	UKBottomRight( NSRect box )
{
	return NSMakePoint( NSMaxX(box), NSMaxY(box) );
}


NSPoint	UKOffsetPoint( NSPoint pos, CGFloat x, CGFloat y )
{
	pos.x += x;
	pos.y += y;
	
	return pos;
}


-(NSBezierPath*)	pathWithConnectedBox: (NSRect)leftBox toBox: (NSRect)rightBox
{
	leftBox.origin.x -= SIDE_MARGIN;
	leftBox.size.width += SIDE_MARGIN;
	rightBox.size.width += SIDE_MARGIN;
	
	NSBezierPath*	thePath = [NSBezierPath bezierPath];
	NSRect			topLeft, topRight, botRight, botLeft;
	CGFloat			leftRounding = (leftBox.size.height >= ROUNDING_SIZE) ? ROUNDING_SIZE : 0.0f,
					rightRounding = (rightBox.size.height >= ROUNDING_SIZE) ? ROUNDING_SIZE : 0.0f;
	
	topLeft = UKBoxAroundPoint(UKTopLeft(leftBox), leftRounding );
	topRight = UKBoxAroundPoint(UKTopRight(rightBox), rightRounding );
	botRight = UKBoxAroundPoint(UKBottomRight(rightBox), rightRounding );
	botLeft = UKBoxAroundPoint(UKBottomLeft(leftBox), leftRounding );
	
	[thePath moveToPoint: UKBottomLeft(topLeft)];
	[thePath appendBezierPathWithArcWithCenter: UKBottomRight(topLeft)
					radius: topLeft.size.height
					startAngle: 180.0f
					endAngle: 270.0f
					clockwise: NO];
	[thePath lineToPoint: UKOffsetPoint(UKTopRight(leftBox), 0, -leftRounding)];
	[thePath lineToPoint: UKOffsetPoint(UKTopLeft(rightBox), 0, -rightRounding)];
	[thePath lineToPoint: UKTopLeft(topRight)];
	[thePath appendBezierPathWithArcWithCenter: UKBottomLeft(topRight)
				radius: topRight.size.height
				startAngle: 270.0f
				endAngle: 0.0f
				clockwise: NO];
	[thePath lineToPoint: UKOffsetPoint(UKTopRight(botRight), 0, rightRounding)];
	[thePath appendBezierPathWithArcWithCenter: UKTopLeft(botRight)
				radius: botRight.size.height
				startAngle: 0.0f
				endAngle: 90.0f
				clockwise: NO];
	[thePath lineToPoint: UKOffsetPoint(UKBottomLeft(rightBox), 0, rightRounding)];
	[thePath lineToPoint: UKOffsetPoint(UKBottomRight(leftBox), 0, leftRounding)];
	[thePath lineToPoint: UKBottomRight(botLeft)];
	[thePath appendBezierPathWithArcWithCenter: UKTopRight(botLeft)
				radius: botLeft.size.height
				startAngle: 90.0f
				endAngle: 180.0f
				clockwise: NO];
	[thePath closePath];
	
	NSAffineTransform*	trans = [NSAffineTransform transform];
	[trans translateXBy: 0.5f yBy: 0.5f];
	[thePath transformUsingAffineTransform: trans];
	
	return thePath;
}


-(void)	drawSelected: (BOOL)selState
{
	// Draw a coloured box around the text to indicate the kind of operation:
	if( currOp != UKDiffOperationUnchanged )
	{
		NSColor*	mainColor = nil;
		NSColor*	fillColor = nil;
		if( currOp == UKDiffOperationChange )
			mainColor = [NSColor blueColor];
		else if( currOp == UKDiffOperationDelete )
		{
			mainColor = [NSColor redColor];
			rightDrawBox.size.height = 0;
		}
		else if( currOp == UKDiffOperationAdd )
		{
			mainColor = [NSColor greenColor];
			leftDrawBox.size.height = 0;
		}
		fillColor = [mainColor colorWithAlphaComponent: 0.1f];
		
		NSBezierPath*	thePath = [self pathWithConnectedBox: leftDrawBox toBox: rightDrawBox];
		
		[fillColor setFill];
		[thePath fill];
		if( selState )
		{
			[mainColor setStroke];
			[thePath setLineWidth: 2.0f];
		}
		else
		{
			[fillColor setStroke];
			[thePath setLineWidth: 1.0f];
		}
		[thePath stroke];
		
		[[NSColor blackColor] set];

		static NSImage*	sChooseLeftImg = nil;
		if( !sChooseLeftImg )
			sChooseLeftImg = [NSImage imageNamed: @"UKDiffViewChooseLeft"];
		static NSImage*	sChooseRightImg = nil;
		if( !sChooseRightImg )
			sChooseRightImg = [NSImage imageNamed: @"UKDiffViewChooseRight"];
		NSImage*		img = apply ? sChooseRightImg : sChooseLeftImg;
		[img drawAtPoint: UKTopRight(leftDrawBox) fromRect: NSZeroRect operation: NSCompositeSourceAtop fraction: 1.0f];
	}
	
	NSLayoutManager*	layoutManager = [[leftTextStorage layoutManagers] objectAtIndex: 0];
	NSTextContainer*	textContainer = [[layoutManager textContainers] objectAtIndex: 0];
	NSRange glyphRange = [layoutManager glyphRangeForTextContainer: textContainer];
	[layoutManager drawGlyphsForGlyphRange: glyphRange atPoint: leftDrawBox.origin];

	layoutManager = [[rightTextStorage layoutManagers] objectAtIndex: 0];
	textContainer = [[layoutManager textContainers] objectAtIndex: 0];
	glyphRange = [layoutManager glyphRangeForTextContainer: textContainer];
	[layoutManager drawGlyphsForGlyphRange: glyphRange atPoint: rightDrawBox.origin];
}

@end



// -----------------------------------------------------------------------------
//	UKDiffView:
// -----------------------------------------------------------------------------

@implementation UKDiffView

@synthesize cachedDrawings;
@synthesize selectedRow;

- (id)initWithFrame:(NSRect)frame
{
    if(( self = [super initWithFrame: frame] ))
	{
        self.cachedDrawings = [NSMutableArray array];
		selectedRow = -1;
    }
    return self;
}


-(void)	dealloc
{
	self.diffParser = nil;
	self.cachedDrawings = nil;
	
	[super dealloc];
}


-(NSSize)	bestSize
{
	CGFloat	maxY = NSMaxY([[cachedDrawings lastObject] leftDrawBox]);
	CGFloat	maxY2 = NSMaxY([[cachedDrawings lastObject] rightDrawBox]);
	NSSize	bestSize = [self bounds].size;
	if( maxY > maxY2 )
		bestSize.height = maxY + VERT_MARGIN;
	else
		bestSize.height = maxY2 +VERT_MARGIN;
	return bestSize;
}


-(void)	drawRect:(NSRect)dirtyRect
{
	NSRect		visBox = [self visibleRect];
	visBox = NSIntersectionRect( visBox, dirtyRect );
	NSInteger	idx = 0;

	for( UKCachedDiffEntry* cached in cachedDrawings )
	{
		if( NSIntersectsRect( NSInsetRect([cached leftDrawBox], -3, -3), visBox )
			|| NSIntersectsRect( NSInsetRect([cached rightDrawBox], -3, -3), visBox ) )
			[cached drawSelected: selectedRow == idx];
		idx++;
	}
}


-(void)	mouseDown: (NSEvent*)evt
{
	NSPoint			pos = [self convertPoint: [evt locationInWindow] fromView: nil];
	NSInteger		idx = 0;
	
	selectedRow = -1;
	
	for( UKCachedDiffEntry* cached in cachedDrawings )
	{
		if( NSPointInRect( pos, [cached leftDrawBox] )
			|| NSPointInRect( pos, [cached rightDrawBox] ) )
		{
			selectedRow = idx;
		}
		
		idx++;
	}
	
	[self setNeedsDisplay: YES];
}


-(void)	keyDown: (NSEvent*)evt
{
	[self interpretKeyEvents: [NSArray arrayWithObject: evt]];
}


-(void)	moveRight: (id)sender
{
#pragma unused(sender)

	if( selectedRow >= 0 )
	{
		UKDiffEntry*	currEntry = [diffParser entryAtIndex: selectedRow];
		[currEntry setApply: YES];
		UKCachedDiffEntry*	cached = [cachedDrawings objectAtIndex: selectedRow];
		[cached setApply: YES];
		[self setNeedsDisplay: YES];
	}
}


-(void)	moveLeft: (id)sender
{
#pragma unused(sender)

	if( selectedRow >= 0 )
	{
		UKDiffEntry*	currEntry = [diffParser entryAtIndex: selectedRow];
		[currEntry setApply: NO];
		UKCachedDiffEntry*	cached = [cachedDrawings objectAtIndex: selectedRow];
		[cached setApply: NO];
		[self setNeedsDisplay: YES];
	}
}


-(void)	moveUp: (id)sender
{
#pragma unused(sender)

	NSInteger	x = selectedRow -1;
	
	for( ; x >= 0; x-- )
	{
		UKCachedDiffEntry*	currEntry = [cachedDrawings objectAtIndex: x];
		if( [currEntry currOp] != UKDiffOperationUnchanged )
		{
			selectedRow = x;
			[self setNeedsDisplay: YES];
			[self scrollRectToVisible: [currEntry leftDrawBox]];
			[self scrollRectToVisible: [currEntry rightDrawBox]];
			break;
		}
	}
}


-(void)	moveDown: (id)sender
{
#pragma unused(sender)

	NSInteger	x = selectedRow +1,
				count = [cachedDrawings count];
	
	for( ; x < count; x++ )
	{
		UKCachedDiffEntry*	currEntry = [cachedDrawings objectAtIndex: x];
		if( [currEntry currOp] != UKDiffOperationUnchanged )
		{
			selectedRow = x;
			[self setNeedsDisplay: YES];
			[self scrollRectToVisible: [currEntry leftDrawBox]];
			[self scrollRectToVisible: [currEntry rightDrawBox]];
			break;
		}
	}
}


-(BOOL)	acceptsFirstResponder
{
	return YES;
}


-(BOOL)	becomeFirstResponder
{
	return YES;
}


-(BOOL)	resignFirstResponder
{
	return YES;
}


- (UKDiffParser *)diffParser {
    return [[diffParser retain] autorelease];
}

-(void)	setDiffParser: (UKDiffParser*)dp
{
	ASSIGN(diffParser,dp);
	[self updateDrawingCacheCompletely: YES];
	[self setNeedsDisplay: YES];
}


-(void)	setFrame: (NSRect)box
{
	[super setFrame: box];
	[self updateDrawingCacheCompletely: NO];
	box.size = [self bestSize];
	[super setFrame: box];
}


-(void) updateDrawingCacheCompletely: (BOOL)recreate
{
	NSDictionary*	attrs = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSFont userFixedPitchFontOfSize: 10.0f], NSFontAttributeName,
								nil];
	NSUInteger		x = 0,
					count = [diffParser count];
	NSRect			box = NSInsetRect( [self bounds], HORZ_MARGIN, VERT_MARGIN );
    CGFloat			halfWidth = truncf( box.size.width / 2 ) -DIVIDER_WIDTH;
	NSRect			leftBox = box, rightBox;
	leftBox.size.width = halfWidth;
	rightBox = leftBox;
	rightBox.origin.x = NSMaxX(box) -halfWidth;
	
	if( recreate )
		[cachedDrawings removeAllObjects];
	
	for( x = 0; x < count; x++ )
	{
		UKDiffEntry*		currDiff = [diffParser entryAtIndex: x];
		UKCachedDiffEntry*	cached = nil;
		
		if( recreate )
		{
			cached = [UKCachedDiffEntry cachedEntryWithLeftString: [currDiff oldText]
												rightString: [currDiff newText]
												attributes: attrs
												applyFlag: [currDiff apply]];
			[cached setCurrOp: [currDiff operation]];
			[cachedDrawings addObject: cached];
		}
		else
			cached = [cachedDrawings objectAtIndex: x];
		
		[cached setLeftDrawBox: leftBox];
		leftBox = [cached leftDrawBox];
		[cached setRightDrawBox: rightBox];
		rightBox = [cached rightDrawBox];

		CGFloat	maxHeight = (rightBox.size.height > leftBox.size.height) ? rightBox.size.height : leftBox.size.height;
		leftBox.origin.y += maxHeight;
		rightBox.origin.y += maxHeight;
	}
}


-(BOOL) isFlipped
{
	return YES;
}

@end
