//
//  UKDiffParser.h
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

