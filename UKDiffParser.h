//
//  UKDiffParser.h
//  AngelDiff
//
//  Created by Uli Kusterer on 02.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


@class UKDiffEntry;

// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

enum
{
	UKDiffOperationChange = 'c',	// newText replaces oldText.
	UKDiffOperationDelete = 'd',	// oldText or nothing.
	UKDiffOperationAdd = 'a',		// nothing or newText.
	UKDiffOperationUnchanged = 0	// oldText and newText are the same. destinationRange is unset.
};
typedef unichar	UKDiffOperation;


// -----------------------------------------------------------------------------
//	UKDiffParser:
//		Parses a diff in string form and can then turn a source text into the
//		destination text by applying this diff.
// -----------------------------------------------------------------------------

@interface UKDiffParser : NSObject
{
	NSMutableArray*				differences;
}

@property (retain) NSMutableArray*			differences;

-(id)	initWithDiffText: (NSString*)diffText;			// The diff to apply.
-(id)	initWithUnifiedDiffText: (NSString*)diffText;	// The diff to apply.

-(void)			applyOriginalText: (NSString*)origText;	// The text to apply the diff to.

-(NSString*)	originalString;	// Must have called applyOriginalText: once before using this.
-(NSString*)	destinationString;	// Must have called applyOriginalText: once before using this.
-(NSString*)	mergedString;	// Must have called applyOriginalText: once before using this.

// Use these e.g for a view that displays a diff:
-(NSUInteger)	count;
-(UKDiffEntry*)	entryAtIndex: (NSUInteger)idx;

// Going away:
-(NSString*)	stringByApplyingChangesToOriginalText: (NSString*)origText;

@end


// -----------------------------------------------------------------------------
//	UKDiffEntry:
//		Class used for storing a parsed version of the source, destination and
//		their differences.
// -----------------------------------------------------------------------------

@interface UKDiffEntry : NSObject
{
	UKDiffOperation	operation;
	NSRange			originalRange;
	NSRange			destinationRange;
	NSString*		newText;
	NSString*		oldText;
	BOOL			apply;		// YES if we should apply this change, NO if we should leave the original text in the output.
}

@property (assign) UKDiffOperation	operation;
@property (assign) NSRange			originalRange;
@property (assign) NSRange			destinationRange;
@property (retain) NSString*		newText;
@property (retain) NSString*		oldText;
@property (assign) BOOL				apply;

@end

