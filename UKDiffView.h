//
//  UKDiffView.h
//  AngelDiff
//
//  Created by Uli Kusterer on 02.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
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
