//
//  UKDiffView.h
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

#import <Cocoa/Cocoa.h>
#import "UKDiffParser.h"


@interface UKCachedDiffEntry : NSObject
{
	NSRect				leftDrawBox;
	NSRect				rightDrawBox;
	NSTextStorage*		leftTextStorage;
	NSTextStorage*		rightTextStorage;
	UKDiffOperation		currOp;
	NSDictionary*		attributes;
	BOOL				apply;
}

@property (assign) NSRect				leftDrawBox;
@property (assign) NSRect				rightDrawBox;
@property (retain) NSTextStorage*		leftTextStorage;
@property (retain) NSTextStorage*		rightTextStorage;
@property (assign) UKDiffOperation		currOp;
@property (retain) NSDictionary*		attributes;
@property (assign) BOOL					apply;

+(id)	cachedEntryWithLeftString: (NSString*)leftStr rightString: (NSString*)rightStr attributes: (NSDictionary*)attrs applyFlag: (BOOL)apl;
-(id)	initWithLeftString: (NSString*)leftStr rightString: (NSString*)rightStr attributes: (NSDictionary*)attrs applyFlag: (BOOL)apl;

-(void)	drawSelected: (BOOL)selState;

-(NSBezierPath*)	pathWithConnectedBox: (NSRect)leftBox toBox: (NSRect)rightBox;

@end



@interface UKDiffView : NSView
{
	UKDiffParser*	diffParser;
	NSMutableArray*	cachedDrawings;
	NSInteger		selectedRow;
}

@property (retain) UKDiffParser*	diffParser;
@property (retain) NSMutableArray*	cachedDrawings;
@property (assign) NSInteger		selectedRow;

-(NSSize)			bestSize;

-(void)				updateDrawingCacheCompletely: (BOOL)recreate;

@end

// Layout utility functions
NSRect	UKBoxAroundPoint( NSPoint pos, CGFloat dist );
NSPoint	UKTopLeft( NSRect box );
NSPoint	UKTopRight( NSRect box );
NSPoint	UKBottomLeft( NSRect box );
NSPoint	UKBottomRight( NSRect box );
NSPoint	UKOffsetPoint( NSPoint pos, CGFloat x, CGFloat y );
