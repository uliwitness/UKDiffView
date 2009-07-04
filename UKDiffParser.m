//
//  UKDiffParser.m
//  AngelDiff
//
//  Created by Uli Kusterer on 02.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "UKDiffParser.h"
#import "UKHelperMacros.h"


@implementation UKDiffParser

@synthesize differences;

-(id)	initWithDiffText: (NSString*)diffText
{
	if(( self = [super init] ))
	{
		self.differences = [NSMutableArray array];
		NSUInteger	currPos = 0, endPos = [diffText length];
		while( currPos < endPos )
		{
			unichar	currCh = [diffText characterAtIndex: currPos];
			if( currCh == '\n' || currCh == '\r' )	// Empty line? Skip.
			{
				currPos++;
				continue;
			}
			
			// Get info about operation:
			NSUInteger			num[4] = { 0, 0, 0, 0 },
								numIdx = 0;
			unichar				separators[4] = { 0, 0, 0, 0 };
			NSMutableString*	currStr = [NSMutableString string];
			while( currPos < endPos )
			{
				currCh = [diffText characterAtIndex: currPos++];
				if( isnumber( currCh ) )
					[currStr appendFormat: @"%C", currCh];
				else
				{
					num[numIdx] = [currStr integerValue];
					separators[numIdx] = currCh;
					numIdx++;
					[currStr deleteCharactersInRange: NSMakeRange( 0, [currStr length] )];
					
					if( currCh == '\n' || currCh == '\r' )
						break;
				}
			}
			
			NSRange			originalRange, destRange;
			originalRange.location = num[0] -1;
			NSUInteger		separatorIdx = 0;
			
			if( separators[0] == ',' )
			{
				originalRange.length = num[1] -originalRange.location;
				separatorIdx++;
			}
			else
				originalRange.length = 1;
			
			destRange.location = num[separatorIdx+1] -1;
			if( separators[separatorIdx+1] == ',' )
				destRange.length = num[separatorIdx+2] -destRange.location;
			else
				destRange.length = 1;
			
			// If it's a source line, ignore it for now:
			currCh = [diffText characterAtIndex: currPos];
			while( currCh == '<' && currPos < endPos )
			{
				do
				{
					currPos++;
					currCh = [diffText characterAtIndex: currPos];
				}
				while( currCh != '\n' && currCh != '\r' && currPos < endPos );
				if( currPos < (endPos-1) )
				{
					currPos++;
					currCh = [diffText characterAtIndex: currPos];
				}
			}
			if( currCh == '-' && currPos < endPos )	// Skip separator line.
			{
				do
				{
					currPos++;
					currCh = [diffText characterAtIndex: currPos];
				}
				while( currCh != '\n' && currCh != '\r' && currPos < endPos );
				if( currPos < (endPos-1) )
				{
					currPos++;
					currCh = [diffText characterAtIndex: currPos];
				}
			}
			
			NSMutableString*	newString = [NSMutableString string];
			while( currCh == '>' && currPos < endPos )
			{
				currCh = [diffText characterAtIndex: ++currPos];
				if( currCh != ' ' )	// There's a greater-than and a space, usually.
					currPos--;
				
				do
				{
					currPos++;
					currCh = [diffText characterAtIndex: currPos];
					[newString appendFormat: @"%C", currCh];
				}
				while( currCh != '\n' && currCh != '\r' && currPos < endPos );
				if( currPos < (endPos-1) )
				{
					currPos++;
					currCh = [diffText characterAtIndex: currPos];
				}
			}
			
			UKDiffEntry*	currDiff = [[[UKDiffEntry alloc] init] autorelease];
			
			[currDiff setOperation: separators[separatorIdx]];
			[currDiff setOriginalRange: originalRange];
			[currDiff setDestinationRange: destRange];
			[currDiff setNewText: newString];
			[differences addObject: currDiff];
		}
	}
	
	return self;
}


-(id)	initWithUnifiedDiffText: (NSString*)diffText
{
	if(( self = [super init] ))
	{
		self.differences = [NSMutableArray array];
		NSUInteger	currPos = 0, endPos = [diffText length];
		while( currPos < endPos )
		{
			UKLog(@"NEW ITERATION");
			unichar	currCh = [diffText characterAtIndex: currPos];
			if( currCh == '-' || currCh == '+' )
			{
				while( (currCh != '\n' && currCh != '\r') && currPos < endPos )
				{
					currCh = [diffText characterAtIndex: ++currPos];
				}
				UKLog(@"\tSkipping file marker line");
			}
			
			if( currCh == '\n' || currCh == '\r'  )	// Empty line? Skip.
			{
				UKLog(@"\tSkipping empty line");
				++currPos;
				continue;
			}
			
			// @@
			if( currCh != '@' )
			{
				[self autorelease];
				UKLog(@"NO @@ Marker found");
				return nil;
			}
				
			currCh = [diffText characterAtIndex: ++currPos];
			if( currCh != '@' )
			{
				[self autorelease];
				UKLog(@"NO @@ Marker found");
				return nil;
			}
	
			UKLog(@"\t@@ Markers found");
			
			currCh = [diffText characterAtIndex: ++currPos];
			while( currCh == ' ' || currCh == '\t' )
				currCh = [diffText characterAtIndex: ++currPos];
			
			// -nnn,nn
			if( currCh != '-' )
			{
				[self autorelease];
				UKLog(@"NO - found");
				return nil;
			}
			
			NSRange				leftRange;
			NSMutableString*	numStr = [NSMutableString string];
			while( currPos < endPos )
			{
				currCh = [diffText characterAtIndex: ++currPos];
				if( !isnumber( currCh ) )
					break;
				[numStr appendFormat: @"%C", currCh];
			}
			
			leftRange.location = [numStr integerValue] -1;
			UKLog(@"\tleftRange.location = %ld",leftRange.location);
			
			if( currCh != ',' )
			{
				leftRange.length = 1;
				currPos++;
			}
			else
			{
				[numStr deleteCharactersInRange: NSMakeRange( 0, [numStr length] )];
				while( currPos < endPos )
				{
					currCh = [diffText characterAtIndex: ++currPos];
					if( !isnumber( currCh ) )
						break;
					[numStr appendFormat: @"%C", currCh];
				}
				
				leftRange.length = [numStr integerValue];
			}
			UKLog(@"\tleftRange.length = %ld",leftRange.length);
			
			while( currCh == ' ' || currCh == '\t' )
				currCh = [diffText characterAtIndex: ++currPos];
			
			// +nnn,nn
			if( currCh != '+' )
			{
				[self autorelease];
				UKLog(@"\tNO + found");
				return nil;
			}
			
			NSRange				rightRange;
			numStr = [NSMutableString string];
			while( currPos < endPos )
			{
				currCh = [diffText characterAtIndex: ++currPos];
				if( !isnumber( currCh ) )
					break;
				[numStr appendFormat: @"%C", currCh];
			}
			
			rightRange.location = [numStr integerValue] -1;
			UKLog(@"\trightRange.location = %ld",rightRange.location);
			
			if( currCh != ',' )
			{
				rightRange.length = 1;
				currPos++;
			}
			else
			{
				[numStr deleteCharactersInRange: NSMakeRange( 0, [numStr length] )];
				while( currPos < endPos )
				{
					currCh = [diffText characterAtIndex: ++currPos];
					if( !isnumber( currCh ) )
						break;
					[numStr appendFormat: @"%C", currCh];
				}
				
				rightRange.length = [numStr integerValue];
			}
			UKLog(@"\trightRange.length = %ld",rightRange.length);
			
			while( currCh == ' ' || currCh == '\t' )
				currCh = [diffText characterAtIndex: ++currPos];
			
			if( currCh != '@' )
			{
				[self autorelease];
				UKLog(@"NO ending @@");
				return nil;
			}
			currCh = [diffText characterAtIndex: ++currPos];
			if( currCh != '@' )
			{
				[self autorelease];
				UKLog(@"NO ending @@");
				return nil;
			}
			
			currCh = [diffText characterAtIndex: ++currPos];
			while( (currCh == '\n' || currCh == '\r') && currPos < (endPos-1) )
				currCh = [diffText characterAtIndex: ++currPos];
			
			if( leftRange.location == 355 )
				NSLog(@"355");
			
			while( (currCh == ' ' || currCh == '-' || currCh == '+') && currPos < (endPos-1) )
			{
				leftRange.length = rightRange.length = 0;
				
				// Now skip those useless context lines:
				while( currCh == ' ' )
				{
					leftRange.location ++;
					rightRange.location ++;
					while( (currCh != '\n' && currCh != '\r') && currPos < (endPos-1) )
						currCh = [diffText characterAtIndex: ++currPos];
					while( (currCh == '\n' || currCh == '\r') && currPos < (endPos-1) )
						currCh = [diffText characterAtIndex: ++currPos];
					UKLog(@"Skipping context line");
				}
				
				// Obtain original lines:
				NSMutableString*		leftString = [NSMutableString string];
				while( currCh == '-' )
				{
					currCh = [diffText characterAtIndex: ++currPos];
					while( (currCh != '\n' && currCh != '\r') && currPos < (endPos-1) )
					{
						[leftString appendFormat: @"%C",currCh];
						currCh = [diffText characterAtIndex: ++currPos];
					}
					while( (currCh == '\n' || currCh == '\r') && currPos < (endPos-1) )
					{
						leftRange.length++;
						[leftString appendFormat: @"%C",currCh];
						currCh = [diffText characterAtIndex: ++currPos];
					}
					UKLog(@"Found - line");
				}
				
				// Obtain new lines:
				NSMutableString*		rightString = [NSMutableString string];
				while( currCh == '+' )
				{
					currCh = [diffText characterAtIndex: ++currPos];
					while( (currCh != '\n' && currCh != '\r') && currPos < (endPos-1) )
					{
						[rightString appendFormat: @"%C",currCh];
						currCh = [diffText characterAtIndex: ++currPos];
					}
					while( (currCh == '\n' || currCh == '\r') && currPos < (endPos-1) )
					{
						rightRange.length++;
						[rightString appendFormat: @"%C",currCh];
						currCh = [diffText characterAtIndex: ++currPos];
					}
					UKLog(@"Found + line");
				}
				
				UKDiffEntry*	currDiff = [[[UKDiffEntry alloc] init] autorelease];
				
				UKDiffOperation	op = UKDiffOperationChange;
				if( [leftString length] == 0 )
					op = UKDiffOperationAdd;
				else if( [rightString length] == 0 )
					op = UKDiffOperationDelete;
				[currDiff setOperation: op];
				[currDiff setOriginalRange: leftRange];
				[currDiff setDestinationRange: rightRange];
				[currDiff setNewText: rightString];
				[currDiff setOldText: leftString];
				[differences addObject: currDiff];
				
				UKLog( @"%@", currDiff );
				
				leftRange.location += leftRange.length;
				rightRange.location += rightRange.length;
				
				// Skip remaining context lines:
				while( currCh == ' ' || currCh == '\\' )
				{
					leftRange.location ++;
					rightRange.location ++;
					while( (currCh != '\n' && currCh != '\r') && currPos < (endPos-1) )
						currCh = [diffText characterAtIndex: ++currPos];
					while( (currCh == '\n' || currCh == '\r') && currPos < (endPos-1) )
						currCh = [diffText characterAtIndex: ++currPos];
					UKLog(@"Skipped trailing context line");
				}
			}
		}
	}
	
	UKLog(@"parsed");
	
	return self;
}


-(void)	dealloc
{
	DESTROY(differences);
	
	[super dealloc];
}


-(NSArray*)	linesArrayForText: (NSString*)str
{
	NSMutableArray*		lines = [NSMutableArray array];
	NSMutableString*	currStr = [NSMutableString string];
	NSUInteger		x = 0, len = [str length];
	for( x = 0; x < len; x++ )
	{
		unichar currCh = [str characterAtIndex: x];
		[currStr appendFormat: @"%C",currCh];
		if( currCh == '\n' || currCh == '\r' )
		{
			[lines addObject: currStr];
			currStr = [NSMutableString string];
		}
	}
	
	if( [currStr length] > 0 )
		[lines addObject: currStr];
	
	return lines;
}


-(NSString*)	stringByApplyingChangesToOriginalText: (NSString*)origText
{
	NSArray*			originalLines = [self linesArrayForText: origText];
	NSUInteger			currOriginalLine = 0, maxOriginalLines = [originalLines count];
	NSMutableString*	outStr = [NSMutableString string];
	
	for( UKDiffEntry* currDiff in differences )
	{
		UKDiffOperation	operation = [currDiff operation];
		NSRange			originalRange = [currDiff originalRange];
		NSString*		newString = [currDiff newText];
		
		if( operation == UKDiffOperationUnchanged )	// Ignore those, we do that ourselves.
			continue;
		
		while( originalRange.location > currOriginalLine )
		{
			NSString*	theLine = [originalLines objectAtIndex: currOriginalLine++];
			[outStr appendString: theLine];
		}
		
		if( operation == UKDiffOperationChange )
		{
			[outStr appendString: newString];
			currOriginalLine += originalRange.length;
		}
		else if( operation == UKDiffOperationDelete )
		{
			currOriginalLine += originalRange.length;
		}
		else if( operation == UKDiffOperationAdd )
		{
			while( (originalRange.location +originalRange.length) > currOriginalLine )
			{
				NSString*	theLine = [originalLines objectAtIndex: currOriginalLine++];
				[outStr appendString: theLine];
			}
			[outStr appendString: newString];
		}
	}
	
	while( maxOriginalLines > currOriginalLine )
		[outStr appendString: [originalLines objectAtIndex: currOriginalLine++]];
	
	return outStr;
}


-(void)	applyOriginalText: (NSString*)origText
{
	NSArray*			originalLines = [self linesArrayForText: origText];
	NSUInteger			currOriginalLine = 0, maxOriginalLines = [originalLines count];
	NSUInteger			prevOriginalLine = 0;
	NSMutableArray*		newDifferences = [NSMutableArray array];
	
	if( [originalLines count] == 0 )
		return;
	
	for( UKDiffEntry* currDiff in differences )
	{
		NSRange			originalRange = [currDiff originalRange];
		UKDiffOperation	operation = [currDiff operation];
		
		if( operation == UKDiffOperationUnchanged )	// Drop any leftover unchanged entries from a previous run.
			continue;
		
		// Generate an entry for any unchanged text between this difference and the previous one:
		NSUInteger		lastLineNeeded = originalRange.location;
		if( operation == UKDiffOperationAdd )
			lastLineNeeded += originalRange.length;
		
		prevOriginalLine = currOriginalLine;
		NSMutableString*	currStr = [NSMutableString string];
		while( lastLineNeeded > currOriginalLine )
		{
			NSString*	theLine = [originalLines objectAtIndex: currOriginalLine++];
			[currStr appendString: theLine];
		}
		
		if( [currStr length] > 0 )
		{
			UKDiffEntry*	newDiff = [[[UKDiffEntry alloc] init] autorelease];
			
			[newDiff setOperation: UKDiffOperationUnchanged];
			[newDiff setOriginalRange: NSMakeRange(prevOriginalLine,currOriginalLine -prevOriginalLine)];
			[newDiff setOldText: currStr];
			[newDiff setNewText: currStr];
			[newDifferences addObject: newDiff];
		}
		
		// Now create an entry for the current change:
		if( operation == UKDiffOperationAdd )
			[newDifferences addObject: currDiff];	// Add object is already done, doesn't need an 'oldText'.
		else	// Change or delete:
		{
			// Capture old text and add it to this diff item:
			NSMutableString*	currStr = [NSMutableString string];
			while( (originalRange.location +originalRange.length) > currOriginalLine )
			{
				NSString*	theLine = [originalLines objectAtIndex: currOriginalLine++];
				[currStr appendString: theLine];
			}
			
			[currDiff setOldText: currStr];
			[newDifferences addObject: currDiff];
		}
	}
	
	// Append any remaining unchanged text at end of diffs:
	NSMutableString*	finalStr = [NSMutableString string];
	prevOriginalLine = currOriginalLine;
	while( maxOriginalLines > currOriginalLine )
		[finalStr appendString: [originalLines objectAtIndex: currOriginalLine++]];
	if( [finalStr length] > 0 )
	{
		UKDiffEntry*	newDiff = [[[UKDiffEntry alloc] init] autorelease];
		
		[newDiff setOperation: UKDiffOperationUnchanged];
		[newDiff setOriginalRange: NSMakeRange(prevOriginalLine,currOriginalLine -prevOriginalLine)];
		[newDiff setOldText: finalStr];
		[newDiff setNewText: finalStr];
		[newDifferences addObject: newDiff];
	}
	
	// Replace old differences array with new one containing both texts:
	self.differences = newDifferences;
}


-(NSString*)	originalString	// Must have called applyOriginalText: once before using this.
{
	NSMutableString*	outStr = [NSMutableString string];
	
	for( UKDiffEntry* currDiff in differences )
	{
		NSString*	currStr = [currDiff oldText];
		if( currStr )
			[outStr appendString: currStr];
	}
	
	return outStr;
}


-(NSString*)	destinationString	// Must have called applyOriginalText: once before using this.
{
	NSMutableString*	outStr = [NSMutableString string];
	
	for( UKDiffEntry* currDiff in differences )
	{
		NSString*	currStr = [currDiff newText];
		if( currStr )
			[outStr appendString: currStr];
	}
	
	return outStr;
}


-(NSString*)	mergedString	// Must have called applyOriginalText: once before using this.
{
	NSMutableString*	outStr = [NSMutableString string];
	
	for( UKDiffEntry* currDiff in differences )
	{
		NSString*	currStr = [currDiff apply] ? [currDiff newText] : [currDiff oldText];
		if( currStr )
			[outStr appendString: currStr];
	}
	
	return outStr;
}



-(NSUInteger)	count
{
	return [differences count];
}


-(UKDiffEntry*)	entryAtIndex: (NSUInteger)idx
{
	return [differences objectAtIndex: idx];
}


@end



@implementation UKDiffEntry

@synthesize	operation;
@synthesize	originalRange;
@synthesize	destinationRange;
@synthesize	newText;
@synthesize	oldText;
@synthesize apply;

-(id)	init
{
	if(( self = [super init] ))
	{
		apply = YES;
	}
	return self;
}

-(NSString*)	description
{
	return [NSString stringWithFormat: @"%@ { operation = %c originalRange = { %ld, %ld }, destinationRange = { %ld, %ld }, apply = %s }",
					NSStringFromClass([self class]), operation, originalRange.location, originalRange.length,
					destinationRange.location, destinationRange.length, (apply? "YES":"NO")];
}

@end
