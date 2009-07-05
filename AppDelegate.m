//
//  AppDelegate.m
//  AngelDiff
//
//  Created by Uli Kusterer on 02.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "AppDelegate.h"
#import "UKDiffParser.h"
#import "UKDiffView.h"
#import "UKHelperMacros.h"


@implementation AppDelegate

@synthesize currPath;

-(void)	dealloc
{
	DESTROY(currPath);
	
	[super dealloc];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
#pragma unused(sender)
	self.currPath = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension: @"txt"];
	NSString*	stringOne = [NSString stringWithContentsOfFile: self.currPath];
	NSString*	diffPath = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension: @"udiff"];
	BOOL		uniDiff = YES;
	if( ![[NSFileManager defaultManager] fileExistsAtPath: diffPath] )
	{
		diffPath = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension: @"diff"];
		uniDiff = NO;
	}
	NSString*	differences = [NSString stringWithContentsOfFile: diffPath];
	
	UKDiffParser*	dp = nil;
	if( uniDiff )
		dp = [[[UKDiffParser alloc] initWithUnifiedDiffText: differences] autorelease];
	else
		dp = [[[UKDiffParser alloc] initWithDiffText: differences] autorelease];
	[dp applyOriginalText: stringOne];
	
	[diffView setDiffParser: dp];
	NSRect	box = [diffView frame];
	box.size = [diffView bestSize];
	[diffView setFrame: box];
	[diffView setNeedsDisplay: YES];
	
	return YES;
}


-(void)	exportMerged: (id)sender
{
#pragma unused(sender)

	NSString*	merged = [[diffView diffParser] mergedString];
	[merged writeToFile: [[currPath stringByDeletingPathExtension] stringByAppendingPathExtension: @"merged.txt"] atomically: NO encoding: NSUTF8StringEncoding error: nil];
}

@end
